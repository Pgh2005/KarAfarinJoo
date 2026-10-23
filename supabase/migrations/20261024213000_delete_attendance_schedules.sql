begin;

grant delete on public.class_attendance_schedules to authenticated;

drop policy if exists "Class owners can delete attendance schedules"
  on public.class_attendance_schedules;
create policy "Class owners can delete attendance schedules"
on public.class_attendance_schedules
for delete
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
);

delete from public.class_attendance_schedules
where not is_active;

notify pgrst, 'reload schema';

commit;
