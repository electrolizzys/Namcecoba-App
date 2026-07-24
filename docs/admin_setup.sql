-- Admin role + RLS for Namtsetsoba admin panel.
-- Run in Supabase SQL editor after deploying the admin-create-venue edge function.

-- Allow profiles.role = 'admin' (no schema change if role is already text).
-- Example: update profiles set role = 'admin' where email = 'you@example.com';

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'admin'
  );
$$;

-- Profiles: admins can read all
drop policy if exists "Admins read all profiles" on public.profiles;
create policy "Admins read all profiles"
  on public.profiles for select
  using (public.is_admin() or id = auth.uid());

-- Orders: admins can read all
drop policy if exists "Admins read all orders" on public.orders;
create policy "Admins read all orders"
  on public.orders for select
  using (public.is_admin());

-- Baskets: admins can read all (if not already public)
drop policy if exists "Admins read all baskets" on public.baskets;
create policy "Admins read all baskets"
  on public.baskets for select
  using (public.is_admin());

-- Stores: admins can insert/update
drop policy if exists "Admins insert stores" on public.stores;
create policy "Admins insert stores"
  on public.stores for insert
  with check (public.is_admin());

drop policy if exists "Admins update stores" on public.stores;
create policy "Admins update stores"
  on public.stores for update
  using (public.is_admin())
  with check (public.is_admin());
