create or replace function public.remove_student_from_class(
  p_class_id text,
  p_student_id text
)
returns void
language plpgsql
security definer
set search_path = pg_catalog, public, auth
as $function$
declare
  deleted_memberships integer;
begin
  if auth.uid() is null then
    raise exception 'Authentication is required to remove a class member.'
      using errcode = '42501';
  end if;

  if not exists (
    select 1
    from public.profiles
    where id::text = auth.uid()::text
      and role = 'professor'
  ) then
    raise exception 'Only professors may remove class members.'
      using errcode = '42501';
  end if;

  perform 1
  from public.classes
  where id::text = p_class_id
    and teacher_id::text = auth.uid()::text
  for update;

  if not found then
    raise exception 'Class not found or not owned by the current professor.'
      using errcode = '42501';
  end if;

  delete from public.class_members
  where class_id::text = p_class_id
    and student_id::text = p_student_id;

  get diagnostics deleted_memberships = row_count;

  if deleted_memberships = 0 then
    raise exception 'Student is not a member of this class.'
      using errcode = 'P0002';
  end if;
end;
$function$;

revoke all on function public.remove_student_from_class(text, text) from public;
revoke all on function public.remove_student_from_class(text, text) from anon;
grant execute on function public.remove_student_from_class(text, text)
  to authenticated;

notify pgrst, 'reload schema';
