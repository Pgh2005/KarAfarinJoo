begin;

create table public.class_attendance_request_challenges (
  session_id uuid primary key
    references public.class_attendance_sessions(id) on delete cascade,
  code_hash text not null,
  expires_at timestamp without time zone not null,
  generated_by text not null,
  generated_at timestamptz not null default now()
);

alter table public.class_attendance_request_challenges enable row level security;
revoke all on public.class_attendance_request_challenges
  from public, anon, authenticated;

create or replace function public.issue_class_attendance_code(p_session_id uuid)
returns text
language plpgsql
security definer
set search_path = pg_catalog, public, auth
as $function$
declare
  attendance_session public.class_attendance_sessions%rowtype;
  local_now timestamp without time zone :=
    timezone('Asia/Tehran', statement_timestamp());
  attendance_code text;
begin
  if auth.uid() is null then
    raise exception 'Authentication is required.'
      using errcode = '42501';
  end if;

  select *
  into attendance_session
  from public.class_attendance_sessions
  where id = p_session_id
  for update;

  if not found or not exists (
    select 1
    from public.classes as class
    join public.profiles as professor
      on professor.id::text = auth.uid()::text
      and professor.role = 'professor'
    where class.id::text = attendance_session.class_id
      and class.teacher_id::text = auth.uid()::text
      and class.is_active
  ) then
    raise exception 'Only the professor who owns this class can issue an attendance code.'
      using errcode = '42501';
  end if;

  if attendance_session.session_date <> local_now::date
    or local_now < attendance_session.starts_at - interval '15 minutes'
    or local_now > attendance_session.ends_at then
    raise exception 'An attendance code can only be issued during the request window.'
      using errcode = '22023';
  end if;

  attendance_code := upper(
    substr(replace(gen_random_uuid()::text, '-', ''), 1, 16)
  );

  insert into public.class_attendance_request_challenges (
    session_id,
    code_hash,
    expires_at,
    generated_by,
    generated_at
  )
  values (
    attendance_session.id,
    md5(attendance_code),
    attendance_session.ends_at,
    auth.uid()::text,
    now()
  )
  on conflict (session_id)
  do update set
    code_hash = excluded.code_hash,
    expires_at = excluded.expires_at,
    generated_by = excluded.generated_by,
    generated_at = excluded.generated_at;

  return attendance_code;
end;
$function$;

drop function if exists public.request_class_attendance(uuid);

create function public.request_class_attendance(
  p_session_id uuid,
  p_code text
)
returns void
language plpgsql
security definer
set search_path = pg_catalog, public, auth
as $function$
declare
  attendance_session public.class_attendance_sessions%rowtype;
  local_now timestamp without time zone :=
    timezone('Asia/Tehran', statement_timestamp());
  valid_code boolean;
begin
  if auth.uid() is null or not exists (
    select 1
    from public.profiles
    where id::text = auth.uid()::text
      and role = 'student'
  ) then
    raise exception 'Only authenticated students can request attendance.'
      using errcode = '42501';
  end if;

  select *
  into attendance_session
  from public.class_attendance_sessions
  where id = p_session_id
  for update;

  if not found or attendance_session.session_date <> local_now::date then
    raise exception 'This attendance session is not available.'
      using errcode = 'P0002';
  end if;

  if not exists (
    select 1
    from public.class_members as member
    where member.class_id::text = attendance_session.class_id
      and member.student_id::text = auth.uid()::text
      and exists (
        select 1
        from public.classes as class
        where class.id::text = member.class_id::text
          and class.is_active
      )
  ) then
    raise exception 'Only current class members can request attendance.'
      using errcode = '42501';
  end if;

  if local_now < attendance_session.starts_at - interval '15 minutes'
    or local_now > attendance_session.ends_at then
    raise exception 'Attendance requests are only accepted from 15 minutes before class until it ends.'
      using errcode = '22023';
  end if;

  select challenge.code_hash = md5(upper(trim(coalesce(p_code, ''))))
    and challenge.expires_at >= local_now
  into valid_code
  from public.class_attendance_request_challenges as challenge
  where challenge.session_id = attendance_session.id;

  if coalesce(valid_code, false) is not true then
    raise exception 'A valid in-class attendance code is required.'
      using errcode = '22023';
  end if;

  insert into public.class_attendance_records (
    class_id, session_id, student_id, status
  )
  values (
    attendance_session.class_id,
    attendance_session.id,
    auth.uid()::text,
    'pending'
  );
exception
  when unique_violation then
    raise exception 'An attendance request already exists for this session.'
      using errcode = '23505';
end;
$function$;

revoke all on function public.issue_class_attendance_code(uuid)
  from public, anon, authenticated;
revoke all on function public.request_class_attendance(uuid, text)
  from public, anon, authenticated;
grant execute on function public.issue_class_attendance_code(uuid)
  to authenticated;
grant execute on function public.request_class_attendance(uuid, text)
  to authenticated;

notify pgrst, 'reload schema';

commit;
