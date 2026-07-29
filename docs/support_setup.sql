-- Support messages from customers/venues → admin notifications.
-- Run this once in the Supabase SQL editor.
--
-- After it runs, Help Center → Contact support will create an Alerts
-- notification for every profile with role = 'admin'.

-- Allow the new notification category (safe if no check constraint exists).
do $$
begin
  alter table public.notifications drop constraint if exists notifications_type_check;
exception
  when undefined_table then null;
  when undefined_object then null;
end $$;

create or replace function public.submit_support_request(p_message text)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  trimmed text := trim(p_message);
  sender_id uuid := auth.uid();
  sender_name text;
  sender_email text;
  sender_role text;
  admin_count integer := 0;
begin
  if sender_id is null then
    raise exception 'Not authenticated';
  end if;

  if trimmed is null or char_length(trimmed) < 3 then
    raise exception 'Message is required';
  end if;

  if char_length(trimmed) > 2000 then
    raise exception 'Message is too long';
  end if;

  select
    coalesce(nullif(p.username, ''), nullif(p.email, ''), 'User'),
    coalesce(p.email, ''),
    coalesce(p.role, 'customer')
  into sender_name, sender_email, sender_role
  from public.profiles p
  where p.id = sender_id;

  insert into public.notifications (user_id, title, body, type, reference_id, is_read)
  select
    p.id,
    'Support from ' || sender_name,
    left('[' || sender_role || '] ' || sender_email || E'\n\n' || trimmed, 1800),
    'support',
    sender_id,
    false
  from public.profiles p
  where p.role = 'admin';

  get diagnostics admin_count = row_count;

  if admin_count = 0 then
    raise exception 'No admin accounts found';
  end if;

  return admin_count;
end;
$$;

revoke all on function public.submit_support_request(text) from public;
grant execute on function public.submit_support_request(text) to authenticated;
