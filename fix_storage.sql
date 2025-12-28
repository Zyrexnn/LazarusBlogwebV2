-- 1. Create the bucket (safe to run even if exists)
insert into storage.buckets (id, name, public)
values ('article-images', 'article-images', true)
on conflict (id) do nothing;

-- 2. Drop existing policies to start fresh (and avoid conflicts)
drop policy if exists "Public Access" on storage.objects;
drop policy if exists "Admin Upload" on storage.objects;
drop policy if exists "Admin Search/Update/Delete" on storage.objects;
-- Cleanup old potential policies
drop policy if exists "Images are publicly accessible" on storage.objects;
drop policy if exists "Authenticated users can upload images" on storage.objects;

-- 3. Create Policies

-- Allow PUBLIC Read Access
create policy "Public Access"
  on storage.objects for select
  using ( bucket_id = 'article-images' );

-- Allow AUTHENTICATED (Admin) Insert Access
create policy "Admin Upload"
  on storage.objects for insert
  to authenticated
  with check ( bucket_id = 'article-images' );

-- Allow AUTHENTICATED (Admin) Update/Delete Access
create policy "Admin Search/Update/Delete"
  on storage.objects for all
  to authenticated
  using ( bucket_id = 'article-images' )
  with check ( bucket_id = 'article-images' );
