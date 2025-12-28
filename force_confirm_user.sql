-- FORCE CONFIRM ADMIN USER
-- Jalankan script ini di Supabase SQL Editor untuk memaksa user admin menjadi "confirmed"
-- Ini akan mem-bypass error "Email not confirmed".

update auth.users
set email_confirmed_at = now()
where email = 'admin@lazarus.blog';

-- Cek hasilnya (harus ada 1 row yang updated)
select email, email_confirmed_at from auth.users where email = 'admin@lazarus.blog';
