-- Jalankan di Supabase Dashboard > SQL Editor > New query > Run.

-- 1) Tabel -----------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  name text not null default 'Pengguna',
  phone text,
  address text,
  created_at timestamptz not null default now()
);

create table if not exists public.pickups (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  types text not null,            -- contoh: "Plastik, Kertas"
  primary_type text not null,     -- id jenis utama: plastik, kertas, ...
  kg numeric(6,1) not null,
  points int not null default 0,
  status text not null check (status in ('Selesai', 'Dibatalkan')),
  address text,
  pickup_date text,
  pickup_slot text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.wallet_tx (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  title text not null,
  amount int not null,            -- positif = poin masuk, negatif = pencairan
  created_at timestamptz not null default now()
);

-- 2) Row Level Security: setiap pengguna hanya bisa akses datanya sendiri
alter table public.profiles enable row level security;
alter table public.pickups enable row level security;
alter table public.wallet_tx enable row level security;

drop policy if exists "profil: baca sendiri" on public.profiles;
drop policy if exists "profil: ubah sendiri" on public.profiles;
drop policy if exists "pickup: baca sendiri" on public.pickups;
drop policy if exists "pickup: tambah sendiri" on public.pickups;
drop policy if exists "transaksi: baca sendiri" on public.wallet_tx;
drop policy if exists "transaksi: tambah sendiri" on public.wallet_tx;

create policy "profil: baca sendiri" on public.profiles for select using (auth.uid() = id);
create policy "profil: ubah sendiri" on public.profiles for update using (auth.uid() = id);

create policy "pickup: baca sendiri" on public.pickups for select using (auth.uid() = user_id);
create policy "pickup: tambah sendiri" on public.pickups for insert with check (auth.uid() = user_id);

create policy "transaksi: baca sendiri" on public.wallet_tx for select using (auth.uid() = user_id);
create policy "transaksi: tambah sendiri" on public.wallet_tx for insert with check (auth.uid() = user_id);

-- 3) Otomatis buat profil saat ada akun baru
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, name, phone)
  values (
    new.id,
    coalesce(nullif(new.raw_user_meta_data ->> 'name', ''), 'Pengguna'),
    new.raw_user_meta_data ->> 'phone'
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
