begin;

alter table public.class_members
  alter column request_id drop not null;

update public.class_join_requests as request
set
  status = 'pending',
  reviewed_by = null,
  reviewed_at = null,
  rejection_reason = null
where request.status = 'approved'
  and not exists (
    select 1
    from public.class_members as member
    where member.class_id::text = request.class_id::text
      and member.student_id::text = request.student_id::text
  );

update public.class_members as member
set request_id = null
from public.class_join_requests as request
where member.request_id::text = request.id::text
  and request.status in ('approved', 'rejected');

delete from public.class_join_requests
where status in ('approved', 'rejected');

create or replace function public.review_class_join_request(
  p_request_id text,
  p_decision text
)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_class_id text;
  v_student_id text;
  v_teacher_id text;
begin
  if auth.uid() is null then
    raise exception 'Authentication is required';
  end if;

  if p_decision is null or p_decision not in ('approved', 'rejected') then
    raise exception 'Invalid request decision';
  end if;

  if not exists (
    select 1
    from public.profiles
    where id::text = auth.uid()::text
      and role = 'professor'
  ) then
    raise exception 'Only professors may review join requests';
  end if;

  select
    request.class_id::text,
    request.student_id::text,
    class.teacher_id::text
  into
    v_class_id,
    v_student_id,
    v_teacher_id
  from public.class_join_requests as request
  join public.classes as class
    on class.id::text = request.class_id::text
  where request.id::text = p_request_id
    and request.status = 'pending'
  for update of request;

  if not found then
    raise exception 'This request has already been reviewed or is no longer valid';
  end if;

  if v_teacher_id is distinct from auth.uid()::text then
    raise exception 'Only the class owner can review this request';
  end if;

  if p_decision = 'approved' then
    insert into public.class_members (
      class_id,
      student_id,
      approved_by,
      request_id,
      joined_at
    )
    values (
      v_class_id,
      v_student_id,
      auth.uid()::text,
      null,
      now()
    );
  end if;

  update public.class_members
  set request_id = null
  where request_id::text = p_request_id;

  delete from public.class_join_requests
  where id::text = p_request_id
    and status = 'pending';

  if not found then
    raise exception 'The request could not be removed after review';
  end if;
end;
$$;

revoke all on function public.review_class_join_request(text, text)
  from public, anon, authenticated;
grant execute on function public.review_class_join_request(text, text)
  to authenticated;

notify pgrst, 'reload schema';

commit;
