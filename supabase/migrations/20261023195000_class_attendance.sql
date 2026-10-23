begin;

create table public.class_attendance_schedules (
  id bigint generated always as identity primary key,
  class_id text not null,
  weekday smallint not null check (weekday between 1 and 7),
  starts_at time not null,
  ends_at time not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint class_attendance_schedules_time_check check (ends_at > starts_at),
  constraint class_attendance_schedules_class_weekday_key unique (class_id, weekday)
);

create table public.class_attendance_sessions (
  id uuid primary key default gen_random_uuid(),
  class_id text not null,
  schedule_id bigint references public.class_attendance_schedules(id)
    on delete set null,
  session_date date not null,
  starts_at timestamp without time zone not null,
  ends_at timestamp without time zone not null,
  created_at timestamptz not null default now(),
  constraint class_attendance_sessions_time_check check (ends_at > starts_at),
  constraint class_attendance_sessions_class_date_key unique (class_id, session_date)
);

create table public.class_attendance_records (
  id uuid primary key default gen_random_uuid(),
  class_id text not null,
  session_id uuid not null references public.class_attendance_sessions(id)
    on delete cascade,
  student_id text not null,
  status text not null default 'pending'
    check (status in ('pending', 'approved', 'rejected', 'absent')),
  requested_at timestamptz not null default now(),
  reviewed_by text,
  reviewed_at timestamptz,
  constraint class_attendance_records_session_student_key
    unique (session_id, student_id)
);

create index class_attendance_sessions_class_date_idx
  on public.class_attendance_sessions (class_id, session_date desc);
create index class_attendance_records_class_session_idx
  on public.class_attendance_records (class_id, session_id);
create index class_attendance_records_student_idx
  on public.class_attendance_records (student_id, session_id);

alter table public.class_attendance_schedules enable row level security;
alter table public.class_attendance_sessions enable row level security;
alter table public.class_attendance_records enable row level security;

revoke all on public.class_attendance_schedules from anon, authenticated;
revoke all on public.class_attendance_sessions from anon, authenticated;
revoke all on public.class_attendance_records from anon, authenticated;

grant select, insert, update on public.class_attendance_schedules to authenticated;
grant select on public.class_attendance_sessions to authenticated;
grant select on public.class_attendance_records to authenticated;
grant usage, select on sequence public.class_attendance_schedules_id_seq
  to authenticated;

create policy "Class members and owners can read attendance schedules"
on public.class_attendance_schedules
for select
to authenticated
using (
  exists (
    select 1
    from public.classes as class
    where class.id::text = class_attendance_schedules.class_id
      and (
        class.teacher_id::text = auth.uid()::text
        or exists (
          select 1
          from public.class_members as member
          where member.class_id::text = class.id::text
            and member.student_id::text = auth.uid()::text
        )
      )
  )
);

create policy "Class owners can manage attendance schedules"
on public.class_attendance_schedules
for insert
to authenticated
with check (
  exists (
    select 1
    from public.classes as class
    join public.profiles as professor
      on professor.id::text = auth.uid()::text
      and professor.role = 'professor'
    where class.id::text = class_attendance_schedules.class_id
      and class.teacher_id::text = auth.uid()::text
  )
);

create policy "Class owners can update attendance schedules"
on public.class_attendance_schedules
for update
to authenticated
using (
  exists (
    select 1
    from public.classes as class
    join public.profiles as professor
      on professor.id::text = auth.uid()::text
      and professor.role = 'professor'
    where class.id::text = class_attendance_schedules.class_id
      and class.teacher_id::text = auth.uid()::text
  )
)
with check (
  exists (
    select 1
    from public.classes as class
    join public.profiles as professor
      on professor.id::text = auth.uid()::text
      and professor.role = 'professor'
    where class.id::text = class_attendance_schedules.class_id
      and class.teacher_id::text = auth.uid()::text
  )
);

create policy "Class members and owners can read attendance sessions"
on public.class_attendance_sessions
for select
to authenticated
using (
  exists (
    select 1
    from public.classes as class
    where class.id::text = class_attendance_sessions.class_id
      and (
        class.teacher_id::text = auth.uid()::text
        or exists (
          select 1
          from public.class_members as member
          where member.class_id::text = class.id::text
            and member.student_id::text = auth.uid()::text
        )
      )
  )
);

create policy "Students can read their attendance and class owners can review"
on public.class_attendance_records
for select
to authenticated
using (
  student_id = auth.uid()::text
  or exists (
    select 1
    from public.classes as class
    join public.profiles as professor
      on professor.id::text = auth.uid()::text
      and professor.role = 'professor'
    where class.id::text = class_attendance_records.class_id
      and class.teacher_id::text = auth.uid()::text
  )
);

alter table public.class_student_grades
  add column attendance_dates date[] not null default '{}'::date[];

revoke insert, update on public.class_student_grades from authenticated;
grant insert (
  class_id,
  student_id,
  slogan,
  exam,
  growth_plan,
  products,
  business_17,
  book,
  talent,
  business_6,
  class_participation,
  slogan_life,
  slogan_business,
  growth_plan_table,
  growth_plan_class_improvement,
  products_table,
  products_new,
  products_presentation,
  business_17_table,
  business_17_quality,
  business_17_presentation,
  book_presentation,
  book_sentences,
  book_question,
  talent_test,
  talent_intelligence,
  business_6_trader,
  business_6_related,
  extracurricular,
  participation_sessions,
  updated_by,
  updated_at
)
on public.class_student_grades to authenticated;
grant update (
  class_id,
  student_id,
  slogan,
  exam,
  growth_plan,
  products,
  business_17,
  book,
  talent,
  business_6,
  class_participation,
  slogan_life,
  slogan_business,
  growth_plan_table,
  growth_plan_class_improvement,
  products_table,
  products_new,
  products_presentation,
  business_17_table,
  business_17_quality,
  business_17_presentation,
  book_presentation,
  book_sentences,
  book_question,
  talent_test,
  talent_intelligence,
  business_6_trader,
  business_6_related,
  extracurricular,
  participation_sessions,
  updated_by,
  updated_at
)
on public.class_student_grades to authenticated;

create or replace function public.validate_class_student_grade_details()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $function$
declare
  entry jsonb;
  date_value text;
  parsed_date date;
  score_value numeric;
  manual_participation numeric := 0;
  attendance_points numeric := cardinality(new.attendance_dates);
  seen_dates date[] := array[]::date[];
begin
  if exists (
    select 1
    from unnest(new.attendance_dates) as dates(attendance_date)
    group by attendance_date
    having count(*) > 1
  ) then
    raise exception 'Attendance dates must be unique.'
      using errcode = '23514';
  end if;

  if new.participation_sessions is not null then
    if jsonb_typeof(new.participation_sessions) is distinct from 'array' then
      raise exception 'Participation sessions must be a JSON array.'
        using errcode = '23514';
    end if;

    for entry in
      select value
      from jsonb_array_elements(new.participation_sessions) as session(value)
    loop
      if jsonb_typeof(entry) is distinct from 'object' then
        raise exception 'Each participation session must be an object.'
          using errcode = '23514';
      end if;

      date_value := entry ->> 'date';
      if date_value is null
        or date_value !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' then
        raise exception 'Participation dates must use YYYY-MM-DD format.'
          using errcode = '23514';
      end if;

      begin
        parsed_date := date_value::date;
      exception
        when others then
          raise exception 'Invalid participation date: %.', date_value
            using errcode = '23514';
      end;

      if parsed_date::text <> date_value then
        raise exception 'Invalid participation date: %.', date_value
          using errcode = '23514';
      end if;

      if parsed_date = any(seen_dates) then
        raise exception 'Only one participation score is allowed per date.'
          using errcode = '23514';
      end if;
      seen_dates := array_append(seen_dates, parsed_date);

      if jsonb_typeof(entry -> 'score') is distinct from 'number' then
        raise exception 'Participation scores must be numbers.'
          using errcode = '23514';
      end if;

      score_value := (entry ->> 'score')::numeric;
      if score_value < 0 then
        raise exception 'Participation scores cannot be negative.'
          using errcode = '23514';
      end if;

      manual_participation := manual_participation + score_value;
    end loop;
  else
    manual_participation := coalesce(new.class_participation, 0);
  end if;

  if attendance_points > 20 then
    raise exception 'Attendance points cannot exceed 20.'
      using errcode = '23514';
  end if;

  if manual_participation + attendance_points > 20 then
    raise exception 'Class activity and attendance points cannot total more than 20.'
      using errcode = '23514';
  end if;

  return new;
end;
$function$;

drop trigger if exists validate_class_student_grade_details_before_save
  on public.class_student_grades;
create trigger validate_class_student_grade_details_before_save
before insert or update of participation_sessions, class_participation, attendance_dates
on public.class_student_grades
for each row
execute function public.validate_class_student_grade_details();

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
    class_id,
    schedule_id,
    session_date,
    starts_at,
    ends_at
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

create or replace function public.request_class_attendance(p_session_id uuid)
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
    attendance_session.class_id, attendance_session.id,
    auth.uid()::text, 'pending'
  );
exception
  when unique_violation then
    raise exception 'An attendance request already exists for this session.'
      using errcode = '23505';
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

  perform pg_advisory_xact_lock(
    hashtextextended(
      attendance_record.class_id || ':' || attendance_record.student_id,
      0
    )
  );

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
    class_id,
    session_id,
    student_id,
    status,
    reviewed_by,
    reviewed_at
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

create or replace function public.get_my_class_attendance_score(p_class_id text)
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

create trigger sync_class_attendance_score_after_review
after insert or update of status on public.class_attendance_records
for each row
execute function public.sync_class_attendance_score();

create or replace function public.cleanup_class_attendance_before_delete()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public
as $function$
begin
  delete from public.class_attendance_sessions
  where class_id = old.id::text;

  delete from public.class_attendance_schedules
  where class_id = old.id::text;

  return old;
end;
$function$;

revoke all on function public.get_or_create_today_attendance_session(text)
  from public, anon, authenticated;
revoke all on function public.request_class_attendance(uuid)
  from public, anon, authenticated;
revoke all on function public.review_class_attendance(uuid, text)
  from public, anon, authenticated;
revoke all on function public.set_class_attendance(uuid, text, text)
  from public, anon, authenticated;
revoke all on function public.get_my_class_attendance_score(text)
  from public, anon, authenticated;
revoke all on function public.sync_class_attendance_score()
  from public, anon, authenticated;
revoke all on function public.cleanup_class_attendance_before_delete()
  from public, anon, authenticated;

grant execute on function public.get_or_create_today_attendance_session(text)
  to authenticated;
grant execute on function public.request_class_attendance(uuid)
  to authenticated;
grant execute on function public.review_class_attendance(uuid, text)
  to authenticated;
grant execute on function public.set_class_attendance(uuid, text, text)
  to authenticated;
grant execute on function public.get_my_class_attendance_score(text)
  to authenticated;

drop trigger if exists cleanup_class_attendance_before_delete on public.classes;
create trigger cleanup_class_attendance_before_delete
before delete on public.classes
for each row
execute function public.cleanup_class_attendance_before_delete();

notify pgrst, 'reload schema';

commit;
