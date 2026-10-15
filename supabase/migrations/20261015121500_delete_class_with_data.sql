create or replace function public.delete_class_with_data(p_class_id uuid)
returns void
language plpgsql
security definer
set search_path = pg_catalog, public, auth
as $function$
begin
  if auth.uid() is null then
    raise exception 'Authentication is required to delete a class.'
      using errcode = '42501';
  end if;

  if not exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and role = 'professor'
  ) then
    raise exception 'Only professors may delete classes.'
      using errcode = '42501';
  end if;

  perform 1
  from public.classes
  where id = p_class_id
    and teacher_id = auth.uid()
  for update;

  if not found then
    raise exception 'Class not found or not owned by the current professor.'
      using errcode = '42501';
  end if;

  delete from public.business_selection_criteria as criterion
  using public.business_selections as selection
  where criterion.selection_id = selection.id
    and selection.class_id = p_class_id;

  delete from public.product_priority_criteria as criterion
  using public.product_priorities as priority
  where criterion.priority_id = priority.id
    and priority.class_id = p_class_id;

  delete from public.personal_info_responses
  where class_id = p_class_id;

  delete from public.talent_responses
  where class_id = p_class_id;

  delete from public.values_responses
  where class_id = p_class_id;

  delete from public.business_selections
  where class_id = p_class_id;

  delete from public.product_priorities
  where class_id = p_class_id;

  delete from public.growth_tables
  where class_id = p_class_id;

  delete from public.class_join_requests
  where class_id = p_class_id;

  delete from public.class_members
  where class_id = p_class_id;

  delete from public.classes
  where id = p_class_id
    and teacher_id = auth.uid();
end;
$function$;

revoke all on function public.delete_class_with_data(uuid) from public;
revoke all on function public.delete_class_with_data(uuid) from anon;
grant execute on function public.delete_class_with_data(uuid) to authenticated;
