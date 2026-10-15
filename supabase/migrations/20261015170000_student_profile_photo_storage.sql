begin;

insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'student-profile-photos',
  'student-profile-photos',
  false,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set
  name = excluded.name,
  public = false,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create or replace function public.set_student_profile_photo(p_avatar_path text)
returns void
language plpgsql
security definer
set search_path = pg_catalog, public, auth
as $function$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'Authentication is required to update a profile photo.'
      using errcode = '42501';
  end if;

  if p_avatar_path is null
    or p_avatar_path !~ ('^' || v_user_id::text || '/[0-9]+-profile$') then
    raise exception 'Invalid profile photo path.'
      using errcode = '22023';
  end if;

  update public.profiles
  set
    avatar_url = p_avatar_path,
    updated_at = now()
  where id::text = v_user_id::text
    and role = 'student';

  if not found then
    raise exception 'Only students with a profile may update a profile photo.'
      using errcode = '42501';
  end if;
end;
$function$;

revoke all on function public.set_student_profile_photo(text)
  from public, anon, authenticated;
grant execute on function public.set_student_profile_photo(text)
  to authenticated;

create policy "Students and class teachers can read profile photos"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'student-profile-photos'
  and (
    (storage.foldername(name))[1] = auth.uid()::text
    or exists (
      select 1
      from public.class_members as member
      join public.classes as class
        on class.id::text = member.class_id::text
      where member.student_id::text = (storage.foldername(name))[1]
        and class.teacher_id::text = auth.uid()::text
    )
  )
);

create policy "Students can upload their own profile photos"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'student-profile-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
  and exists (
    select 1
    from public.profiles
    where id::text = auth.uid()::text
      and role = 'student'
  )
);

create policy "Students can update their own profile photos"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'student-profile-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
  and exists (
    select 1
    from public.profiles
    where id::text = auth.uid()::text
      and role = 'student'
  )
)
with check (
  bucket_id = 'student-profile-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
  and exists (
    select 1
    from public.profiles
    where id::text = auth.uid()::text
      and role = 'student'
  )
);

create policy "Students can delete their own profile photos"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'student-profile-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
  and exists (
    select 1
    from public.profiles
    where id::text = auth.uid()::text
      and role = 'student'
  )
);

commit;
