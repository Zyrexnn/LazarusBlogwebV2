-- FIX PERMISSIONS (Reset & Re-apply)
-- Jalankan ini di Supabase SQL Editor untuk memperbaiki permission error

-- 1. Enable RLS
alter table public.articles enable row level security;
alter table public.likes enable row level security;

-- 2. Hapus yang lama (Clean slate)
drop policy if exists "Authenticated users can insert articles" on public.articles;
drop policy if exists "Authenticated users can update articles" on public.articles;
drop policy if exists "Authenticated users can delete articles" on public.articles;
drop policy if exists "Public articles are viewable by everyone." on public.articles;
drop policy if exists "Public can insert likes" on public.likes;
drop policy if exists "Public can read likes" on public.likes;

-- 3. Buat Ulang Policy Artikel
-- PUBLIC bisa BACA
create policy "Public articles are viewable by everyone."
  on public.articles for select
  using ( true );

-- AUTHENTICATED (Admin) bisa insert/update/delete
create policy "Authenticated users can insert articles"
  on public.articles for insert
  to authenticated
  with check ( true ); 

create policy "Authenticated users can update articles"
  on public.articles for update
  to authenticated
  using ( true );

create policy "Authenticated users can delete articles"
  on public.articles for delete
  to authenticated
  using ( true );

-- 4. Buat Ulang Policy Likes
create policy "Public can insert likes"
  on public.likes for insert
  to anon, authenticated
  with check ( true );

create policy "Public can read likes"
  on public.likes for select
  to anon, authenticated
  using ( true );
