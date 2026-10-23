create table if not exists public.user_feedback (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  category text not null check (category in ('issue', 'suggestion', 'other')),
  title text not null check (char_length(trim(title)) between 1 and 120),
  message text not null check (char_length(trim(message)) between 1 and 3000),
  status text not null default 'open' check (status in ('open', 'in_progress', 'resolved')),
  created_at timestamptz not null default now()
);

alter table public.user_feedback enable row level security;

revoke all on public.user_feedback from anon, authenticated;
grant insert (user_id, category, title, message)
  on public.user_feedback to authenticated;

create policy "Users can submit their own feedback"
  on public.user_feedback
  for insert
  to authenticated
  with check (auth.uid() = user_id);
