begin;

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

  insert into public.class_attendance_sessions as existing_session (
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
  on conflict (class_id, session_date) do update
  set
    schedule_id = excluded.schedule_id,
    starts_at = excluded.starts_at,
    ends_at = excluded.ends_at
  where not exists (
    select 1
    from public.class_attendance_records as record
    where record.session_id = existing_session.id
  );

  select *
  into attendance_session
  from public.class_attendance_sessions as session
  where session.class_id = p_class_id
    and session.session_date = local_date;

  if not found then
    return null;
  end if;

  if not exists (
    select 1
    from public.class_attendance_schedules as schedule
    where schedule.class_id = p_class_id
      and schedule.weekday = local_weekday
      and schedule.is_active
  ) and not exists (
    select 1
    from public.class_attendance_records as record
    where record.session_id = attendance_session.id
  ) then
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

notify pgrst, 'reload schema';

commit;
