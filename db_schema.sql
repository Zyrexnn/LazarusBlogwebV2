-- LazarusBlogV2 Database Schema

-- 0. Enable pgvector extension (Required for 'vector' type)
create extension if not exists vector;

-- 1. Create Articles Table
create table if not exists public.articles (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  content text not null,
  image_url text,
  category text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  embedding vector(1536) -- For AI features
);

-- 2. Create Likes Table
create table if not exists public.likes (
  id uuid default gen_random_uuid() primary key,
  article_id uuid references public.articles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Enable RLS (Security)
alter table public.articles enable row level security;
alter table public.likes enable row level security;

-- 4. Policies for Articles

-- Allow everyone to READ articles
create policy "Public articles are viewable by everyone."
  on public.articles for select
  using ( true );

-- Allow ONLY Authenticated Users (Admin) to CREATE/UPDATE/DELETE
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

-- 5. Policies for Likes

-- Allow everyone (Anon + Auth) to LIKE
create policy "Public can insert likes"
  on public.likes for insert
  to anon, authenticated
  with check ( true );

-- Allow everyone to count likes
create policy "Public can read likes"
  on public.likes for select
  to anon, authenticated
  using ( true );

-- 6. Storage Config (Images)
insert into storage.buckets (id, name, public) 
values ('article-images', 'article-images', true)
on conflict (id) do nothing;

create policy "Images are publicly accessible"
  on storage.objects for select
  using ( bucket_id = 'article-images' );

create policy "Authenticated users can upload images"
  on storage.objects for insert
  to authenticated
  with check ( bucket_id = 'article-images' );

-- IMPORTANT INSTRUCTIONS FOR USER:
-- 1. Run this entire script in Supabase SQL Editor.
-- 2. Go to Authentication -> Users.
-- 3. Create a new user:
--    Email:    admin@lazarus.blog
--    Password: lazarus_secret_0721
