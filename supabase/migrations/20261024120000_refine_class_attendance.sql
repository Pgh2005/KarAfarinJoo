begin;

alter table public.class_attendance_records
  drop constraint if exists class_attendance_records_status_check;
alter table public.class_attendance_records
  add constraint class_attendance_records_status_check
  check (status in ('pending', 'approved', 'rejected', 'absent'));

create or replace function public.get_or_create_today_attendance_session(
  p_class_id text
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, auth
as $function$
declare
  local_now timestamp without time zone :=
    timezone('Asia/Tehran', statement_timestamp());
  local_date date;
  local_weekday smallint;
  attendance_session public.class_attendance_sessions%rowtype;
begin
  if auth.uid() is null then
    raise exception 'Authentication is required.'
      using errcode = '42501';
  end if;

  if not exists (
    select 1
    from public.classes as class
    where class.id::text = p_class_id
      and (
        (
          class.teacher_id::text = auth.uid()::text
          and exists (
            select 1
            from public.profiles as professor
            where professor.id::text = auth.uid()::text
              and professor.role = 'professor'
          )
        )
        or exists (
          select 1
          from public.class_members as member
          where member.class_id::text = class.id::text
            and member.student_id::text = auth.uid()::text
        )
      )
  ) then
    raise exception 'Only a class member or its professor may access attendance.'
      using errcode = '42501';
  end if;

  local_date := local_now::date;
  local_weekday := extract(isodow from local_now)::smallint;

  insert into public.class_attendance_sessions (
    class_id, schedule_id, session_date, starts_at, ends_at
  )
  select
    schedule.class_id,
    schedule.id,
    local_date,
    local_date + schedule.starts_at,
    local_date + schedule.ends_at
  from public.class_attendance_schedules as schedule
  where schedule.class_id = p_class_id
    and schedule.weekday = local_weekday
    and schedule.is_active
    and exists (
      select 1
      from public.classes as class
      where class.id::text = schedule.class_id
        and class.is_active
    )
  on conflict (class_id, session_date) do nothing;

  select *
  into attendance_session
  from public.class_attendance_sessions as session
  where session.class_id = p_class_id
    and session.session_date = local_date;

  if not found then
    return null;
  end if;

  return jsonb_build_object(
    'id', attendance_session.id,
    'class_id', attendance_session.class_id,
    'session_date', attendance_session.session_date,
    'starts_at', attendance_session.starts_at,
    'ends_at', attendance_session.ends_at,
    'session_ended', local_now >= attendance_session.ends_at,
    'request_open',
      local_now >= attendance_session.starts_at - interval '15 minutes'
      and local_now <= attendance_session.ends_at
  );
end;
$function$;

create or replace function public.review_class_attendance(
  p_record_id uuid,
  p_status text
)
returns void
language plpgsql
security definer
set search_path = pg_catalog, public, auth
as $function$
declare
  attendance_record public.class_attendance_records%rowtype;
  attendance_session public.class_attendance_sessions%rowtype;
  local_now timestamp without time zone :=
    timezone('Asia/Tehran', statement_timestamp());
begin
  if auth.uid() is null
    or p_status is null
    or p_status not in ('approved', 'rejected', 'absent') then
    raise exception 'A valid attendance decision is required.'
      using errcode = '22023';
  end if;

  select *
  into attendance_record
  from public.class_attendance_records
  where id = p_record_id
  for update;

  if not found or not exists (
    select 1
    from public.classes as class
    join public.profiles as professor
      on professor.id::text = auth.uid()::text
      and professor.role = 'professor'
    where class.id::text = attendance_record.class_id
      and class.teacher_id::text = auth.uid()::text
  ) then
    raise exception 'Only the professor who owns this class can review attendance.'
      using errcode = '42501';
  end if;

  if p_status = 'absent' then
    select *
    into attendance_session
    from public.class_attendance_sessions
    where id = attendance_record.session_id;

    if local_now < attendance_session.ends_at then
      raise exception 'Absence can only be recorded after class ends.'
        using errcode = '22023';
    end if;
  end if;

  perform pg_advisory_xact_lock(
    hashtextextended(
      attendance_record.class_id || ':' || attendance_record.student_id,
      0
    )
  );

  update public.class_attendance_records
  set
    status = p_status,
    reviewed_by = auth.uid()::text,
    reviewed_at = now()
  where id = attendance_record.id;
end;
$function$;

create or replace function public.set_class_attendance(
  p_session_id uuid,
  p_student_id text,
  p_status text
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
begin
  if auth.uid() is null
    or p_status is null
    or p_status not in ('approved', 'absent') then
    raise exception 'A valid attendance status is required.'
      using errcode = '22023';
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
  ) then
    raise exception 'Only the professor who owns this class can edit attendance.'
      using errcode = '42501';
  end if;

  if not exists (
    select 1
    from public.class_members as member
    where member.class_id::text = attendance_session.class_id
      and member.student_id::text = p_student_id
  ) then
    raise exception 'Only class members can receive an attendance record.'
      using errcode = 'P0002';
  end if;

  if p_status = 'absent' and local_now < attendance_session.ends_at then
    raise exception 'Absence can only be recorded after class ends.'
      using errcode = '22023';
  end if;

  perform pg_advisory_xact_lock(
    hashtextextended(attendance_session.class_id || ':' || p_student_id, 0)
  );

  insert into public.class_attendance_records (
    class_id, session_id, student_id, status, reviewed_by, reviewed_at
  )
  values (
    attendance_session.class_id,
    attendance_session.id,
    p_student_id,
    p_status,
    auth.uid()::text,
    now()
  )
  on conflict (session_id, student_id)
  do update set
    status = excluded.status,
    reviewed_by = excluded.reviewed_by,
    reviewed_at = excluded.reviewed_at;
end;
$function$;

drop function if exists public.get_my_class_attendance_score(text);
create function public.get_my_class_attendance_score(p_class_id text)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, auth
as $function$
declare
  attendance_dates date[];
begin
  if auth.uid() is null then
    raise exception 'Authentication is required.'
      using errcode = '42501';
  end if;

  if not exists (
    select 1
    from public.class_members as member
    where member.class_id::text = p_class_id
      and member.student_id::text = auth.uid()::text
  ) then
    if exists (
      select 1
      from public.classes as class
      join public.profiles as professor
        on professor.id::text = auth.uid()::text
        and professor.role = 'professor'
      where class.id::text = p_class_id
        and class.teacher_id::text = auth.uid()::text
    ) then
      return '[]'::jsonb;
    end if;
    raise exception 'Only a class member or its professor may read attendance points.'
      using errcode = '42501';
  end if;

  select grade.attendance_dates
  into attendance_dates
  from public.class_student_grades as grade
  where grade.class_id = p_class_id
    and grade.student_id = auth.uid()::text;

  return to_jsonb(coalesce(attendance_dates, '{}'::date[]));
end;
$function$;

create or replace function public.sync_class_attendance_score()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public, auth
as $function$
declare
  approved_dates date[];
  reviewer_id text;
begin
  perform pg_advisory_xact_lock(
    hashtextextended(new.class_id || ':' || new.student_id, 0)
  );

  if tg_op = 'INSERT' and new.status <> 'approved' then
    return new;
  end if;

  if tg_op = 'UPDATE'
    and (
      new.status is not distinct from old.status
      or (new.status <> 'approved' and old.status <> 'approved')
    ) then
    return new;
  end if;

  select coalesce(
    array_agg(attendance_session.session_date order by attendance_session.session_date),
    '{}'::date[]
  )
  into approved_dates
  from public.class_attendance_records as record
  join public.class_attendance_sessions as attendance_session
    on attendance_session.id = record.session_id
  where record.class_id = new.class_id
    and record.student_id = new.student_id
    and record.status = 'approved';

  reviewer_id := coalesce(new.reviewed_by, auth.uid()::text, 'attendance-system');

  insert into public.class_student_grades (
    class_id, student_id, attendance_dates, updated_by
  )
  values (
    new.class_id, new.student_id, approved_dates, reviewer_id
  )
  on conflict (class_id, student_id)
  do update set
    attendance_dates = excluded.attendance_dates,
    updated_by = excluded.updated_by,
    updated_at = now();

  return new;
end;
$function$;

drop trigger if exists sync_class_attendance_score_after_review
  on public.class_attendance_records;
create trigger sync_class_attendance_score_after_review
after insert or update of status on public.class_attendance_records
for each row
execute function public.sync_class_attendance_score();

revoke all on function public.set_class_attendance(uuid, text, text)
  from public, anon, authenticated;
grant execute on function public.set_class_attendance(uuid, text, text)
  to authenticated;

revoke all on function public.get_my_class_attendance_score(text)
  from public, anon, authenticated;
grant execute on function public.get_my_class_attendance_score(text)
  to authenticated;

notify pgrst, 'reload schema';

commit;
