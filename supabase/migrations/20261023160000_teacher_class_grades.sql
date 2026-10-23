begin;

create table public.class_student_grades (
  class_id text not null,
  student_id text not null,
  slogan numeric(5, 2) check (slogan between 0 and 2),
  exam numeric(5, 2) check (exam between 0 and 20),
  growth_plan numeric(5, 2) check (growth_plan between 0 and 10),
  products numeric(5, 2) check (products between 0 and 17),
  business_17 numeric(5, 2) check (business_17 between 0 and 17),
  book numeric(5, 2) check (book between 0 and 14),
  talent numeric(5, 2) check (talent between 0 and 4),
  business_6 numeric(5, 2) check (business_6 between 0 and 6),
  class_participation numeric(5, 2)
    check (class_participation between 0 and 20),
  updated_by text not null,
  updated_at timestamptz not null default now(),
  constraint class_student_grades_pkey primary key (class_id, student_id)
);

alter table public.class_student_grades enable row level security;

grant select, insert, update on public.class_student_grades to authenticated;
revoke all on public.class_student_grades from anon;

create policy "Class owners can read their students' grades"
on public.class_student_grades
for select
to authenticated
using (
  exists (
    select 1
    from public.classes as class
    join public.profiles as professor
      on professor.id::text = auth.uid()::text
      and professor.role = 'professor'
    join public.class_members as member
      on member.class_id::text = class.id::text
      and member.student_id::text = class_student_grades.student_id
    where class.id::text = class_student_grades.class_id
      and class.teacher_id::text = auth.uid()::text
  )
);

create policy "Class owners can insert their students' grades"
on public.class_student_grades
for insert
to authenticated
with check (
  updated_by = auth.uid()::text
  and exists (
    select 1
    from public.classes as class
    join public.profiles as professor
      on professor.id::text = auth.uid()::text
      and professor.role = 'professor'
    join public.class_members as member
      on member.class_id::text = class.id::text
      and member.student_id::text = class_student_grades.student_id
    where class.id::text = class_student_grades.class_id
      and class.teacher_id::text = auth.uid()::text
  )
);

create policy "Class owners can update their students' grades"
on public.class_student_grades
for update
to authenticated
using (
  exists (
    select 1
    from public.classes as class
    join public.profiles as professor
      on professor.id::text = auth.uid()::text
      and professor.role = 'professor'
    join public.class_members as member
      on member.class_id::text = class.id::text
      and member.student_id::text = class_student_grades.student_id
    where class.id::text = class_student_grades.class_id
      and class.teacher_id::text = auth.uid()::text
  )
)
with check (
  updated_by = auth.uid()::text
  and exists (
    select 1
    from public.classes as class
    join public.profiles as professor
      on professor.id::text = auth.uid()::text
      and professor.role = 'professor'
    join public.class_members as member
      on member.class_id::text = class.id::text
      and member.student_id::text = class_student_grades.student_id
    where class.id::text = class_student_grades.class_id
      and class.teacher_id::text = auth.uid()::text
  )
);

create or replace function public.delete_class_student_grades()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public
as $function$
begin
  delete from public.class_student_grades
  where class_id = old.id::text;

  return old;
end;
$function$;

revoke all on function public.delete_class_student_grades() from public;
revoke all on function public.delete_class_student_grades() from anon, authenticated;

create trigger delete_class_student_grades_before_class_delete
before delete on public.classes
for each row
execute function public.delete_class_student_grades();

commit;
