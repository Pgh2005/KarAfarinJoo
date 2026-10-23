begin;

drop function if exists public.request_class_attendance(uuid, text);
drop function if exists public.request_class_attendance(uuid);
drop function if exists public.issue_class_attendance_code(uuid);
drop table if exists public.class_attendance_request_challenges;

create function public.request_class_attendance(p_session_id uuid)
returns void
language plpgsql
security definer
set search_path = pg_catalog, public, auth
as $function$
declare
  attendance_session public.class_attendance_sessions%rowtype;
  local_now timestamp without time zone :=
    timezone('Asia/Tehran', statement_timestamp());
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

revoke all on function public.request_class_attendance(uuid)
  from public, anon, authenticated;
grant execute on function public.request_class_attendance(uuid)
  to authenticated;

notify pgrst, 'reload schema';

commit;
