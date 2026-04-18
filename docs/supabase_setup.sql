-- ============================================
-- Namtsetsoba — Full Database Setup
-- Run this in: Supabase Dashboard → SQL Editor
-- ============================================

-- 1. TABLES
-- ============================================

create table if not exists stores (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  address text not null,
  latitude double precision not null,
  longitude double precision not null,
  category text not null,
  rating double precision not null default 0,
  is_verified boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists baskets (
  id uuid primary key default gen_random_uuid(),
  store_id uuid not null references stores(id) on delete cascade,
  title text not null,
  description text,
  original_price numeric not null,
  discounted_price numeric not null,
  pickup_start_time timestamptz not null,
  pickup_end_time timestamptz not null,
  items_description text,
  remaining_count int not null default 1,
  created_at timestamptz not null default now()
);

create table if not exists orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  basket_id uuid not null references baskets(id),
  status text not null default 'confirmed',
  pickup_code text not null,
  total_paid numeric not null,
  created_at timestamptz not null default now()
);

-- 2. ROW LEVEL SECURITY
-- ============================================

alter table stores enable row level security;
alter table baskets enable row level security;
alter table orders enable row level security;

-- Stores: anyone can read
create policy "Public read stores"
  on stores for select
  using (true);

-- Baskets: anyone can read, authenticated users can insert/update/delete
create policy "Public read baskets"
  on baskets for select
  using (true);

create policy "Authenticated users can create baskets"
  on baskets for insert
  to authenticated
  with check (true);

create policy "Authenticated users can update baskets"
  on baskets for update
  to authenticated
  using (true);

create policy "Authenticated users can delete baskets"
  on baskets for delete
  to authenticated
  using (true);

-- Orders: users can only see and create their own
create policy "Users read own orders"
  on orders for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Users create own orders"
  on orders for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Users update own orders"
  on orders for update
  to authenticated
  using (auth.uid() = user_id);

-- 3. INDEXES (for fast queries)
-- ============================================

create index if not exists idx_baskets_store_id on baskets(store_id);
create index if not exists idx_baskets_remaining on baskets(remaining_count);
create index if not exists idx_baskets_pickup_end on baskets(pickup_end_time);
create index if not exists idx_orders_user_id on orders(user_id);
create index if not exists idx_orders_basket_id on orders(basket_id);

-- 4. SEED DATA — Georgian stores in Tbilisi
-- ============================================

insert into stores (name, address, latitude, longitude, category, rating, is_verified) values
  ('Bread House',       'Rustaveli Ave 12, Tbilisi',        41.6941, 44.8015, 'Bakery',     4.7, true),
  ('Machakhela',        'Aghmashenebeli Ave 28, Tbilisi',   41.7088, 44.7837, 'Restaurant', 4.5, true),
  ('Nikora',            'Chavchavadze Ave 5, Tbilisi',      41.7105, 44.7750, 'Grocery',    4.2, true),
  ('Stamba Cafe',       'Chubinashvili St 14, Tbilisi',     41.7070, 44.7920, 'Cafe',       4.8, true),
  ('Entree',            'Rustaveli Ave 22, Tbilisi',        41.6968, 44.8000, 'Cafe',       4.6, true),
  ('Pasanauri',         'Marjanishvili St 3, Tbilisi',      41.7110, 44.7880, 'Restaurant', 4.4, true),
  ('Sweet Palace',      'Pekini Ave 41, Tbilisi',           41.7220, 44.7680, 'Pastry',     4.3, true),
  ('Sakhachapure N1',   'Vake, Tbilisi',                    41.7150, 44.7600, 'Bakery',     4.1, true),
  ('Fresco',            'Saburtalo, Tbilisi',               41.7250, 44.7550, 'Grocery',    4.0, true),
  ('Lolita',            'Vera, Tbilisi',                    41.7020, 44.7900, 'Pastry',     4.9, true);

-- 5. SEED DATA — Sample baskets (pickup times relative to now)
-- ============================================

insert into baskets (store_id, title, description, original_price, discounted_price,
                     pickup_start_time, pickup_end_time, items_description, remaining_count)
select
  s.id,
  b.title,
  b.description,
  b.original_price,
  b.discounted_price,
  now() + b.start_offset,
  now() + b.end_offset,
  b.items_description,
  b.remaining_count
from (values
  ('Bread House',     'Surprise Bread Basket',  'A mix of today''s fresh bread, pastries, and baked goods from our artisan bakery.',
   15.00, 5.99, interval '2 hours', interval '4 hours',
   'Assorted bread loaves, croissants, and pastries', 3),

  ('Machakhela',      'Georgian Feast Box',     'Leftover dishes from today''s lunch menu including khinkali and salads.',
   25.00, 8.99, interval '3 hours', interval '5 hours',
   'Khinkali, salad, bread, and a surprise side dish', 2),

  ('Nikora',          'Fresh Groceries Pack',   'Mixed fruits, vegetables, and dairy products nearing their best-by date.',
   20.00, 6.99, interval '1 hour', interval '3 hours',
   'Fruits, veggies, yogurt, and cheese', 5),

  ('Stamba Cafe',     'Afternoon Treats',       'Premium coffee-shop pastries and one complimentary coffee.',
   18.00, 6.49, interval '4 hours', interval '6 hours',
   'Croissant, muffin, cookie, and drip coffee', 4),

  ('Entree',          'Cafe Lunch Surprise',    'Today''s unsold lunch specials packaged fresh.',
   22.00, 7.99, interval '2 hours', interval '5 hours',
   'Sandwich, soup, and a dessert', 1),

  ('Pasanauri',       'Dinner Rescue Box',      'Tonight''s specials that won''t make it to tomorrow.',
   30.00, 10.99, interval '5 hours', interval '7 hours',
   'Main course, bread, and salad', 3),

  ('Sweet Palace',    'Sweet Surprise',         'Assorted cakes and pastries from today''s display.',
   28.00, 9.49, interval '1 hour', interval '2 hours',
   'Cake slices, eclairs, and macarons', 2),

  ('Sakhachapure N1', 'Khachapuri Bundle',      'Fresh khachapuri varieties baked this morning.',
   12.00, 4.49, interval '3 hours', interval '5 hours',
   'Imeruli and Megruli khachapuri', 6)
) as b(store_name, title, description, original_price, discounted_price,
       start_offset, end_offset, items_description, remaining_count)
join stores s on s.name = b.store_name;

-- 6. ADD WORKING HOURS TO STORES
-- ============================================

alter table stores add column if not exists open_time text not null default '09:00';
alter table stores add column if not exists close_time text not null default '21:00';

update stores set open_time = '07:00', close_time = '20:00' where name = 'Bread House';
update stores set open_time = '10:00', close_time = '23:00' where name = 'Machakhela';
update stores set open_time = '08:00', close_time = '22:00' where name = 'Nikora';
update stores set open_time = '09:00', close_time = '21:00' where name = 'Stamba Cafe';
update stores set open_time = '08:00', close_time = '22:00' where name = 'Entree';
update stores set open_time = '11:00', close_time = '23:00' where name = 'Pasanauri';
update stores set open_time = '09:00', close_time = '20:00' where name = 'Sweet Palace';
update stores set open_time = '08:00', close_time = '19:00' where name = 'Sakhachapure N1';
update stores set open_time = '08:00', close_time = '23:00' where name = 'Fresco';
update stores set open_time = '10:00', close_time = '21:00' where name = 'Lolita';

-- 7. FUNCTIONS
-- ============================================

create or replace function decrement_basket_count(basket_uuid uuid)
returns void as $$
begin
  update baskets
  set remaining_count = remaining_count - 1
  where id = basket_uuid and remaining_count > 0;
end;
$$ language plpgsql security definer;
