-- Minto / قُرب — Phase 2 schema
-- profiles + numeric_id assignment + RLS

set check_function_bodies = off;

------------------------------------------------------------
-- profiles
------------------------------------------------------------
create table if not exists public.profiles (
  id           uuid primary key references auth.users(id) on delete cascade,
  numeric_id   integer unique not null,
  status       text not null default 'active' check (status in ('active','banned')),
  city_code    text,
  created_at   timestamptz not null default now(),
  last_seen_at timestamptz not null default now()
);

create index if not exists profiles_status_idx on public.profiles(status);

------------------------------------------------------------
-- generate_numeric_id() — random 5-digit (10000–99999) with retry,
-- falls back to 6-digit if the 5-digit space gets crowded.
------------------------------------------------------------
create or replace function public.generate_numeric_id()
returns integer
language plpgsql
volatile
security definer
set search_path = public, pg_temp
as $$
declare
  candidate int;
  attempt   int := 0;
begin
  loop
    candidate := 10000 + floor(random() * 90000)::int;
    exit when not exists (select 1 from public.profiles where numeric_id = candidate);
    attempt := attempt + 1;
    if attempt >= 100 then
      -- fall back to 6-digit range
      candidate := 100000 + floor(random() * 900000)::int;
      exit;
    end if;
  end loop;
  return candidate;
end;
$$;

------------------------------------------------------------
-- on_auth_user_created — runs after every signup (including anonymous)
-- creates the matching profile row with a unique numeric_id.
------------------------------------------------------------
create or replace function public.on_auth_user_created()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  insert into public.profiles (id, numeric_id)
  values (new.id, public.generate_numeric_id());
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_trg on auth.users;
create trigger on_auth_user_created_trg
  after insert on auth.users
  for each row execute function public.on_auth_user_created();

------------------------------------------------------------
-- touch_last_seen — update last_seen_at on the current user
------------------------------------------------------------
create or replace function public.touch_last_seen()
returns void
language sql
security definer
set search_path = public, pg_temp
as $$
  update public.profiles
     set last_seen_at = now()
   where id = auth.uid();
$$;

------------------------------------------------------------
-- my_profile — convenience getter for the current user's profile
------------------------------------------------------------
create or replace function public.my_profile()
returns public.profiles
language sql
stable
security invoker
set search_path = public, pg_temp
as $$
  select * from public.profiles where id = auth.uid();
$$;

------------------------------------------------------------
-- RLS
------------------------------------------------------------
alter table public.profiles enable row level security;

drop policy if exists "read active profiles" on public.profiles;
create policy "read active profiles"
  on public.profiles
  for select
  using (status = 'active');

drop policy if exists "update own profile" on public.profiles;
create policy "update own profile"
  on public.profiles
  for update
  using (auth.uid() = id)
  with check (auth.uid() = id and status = 'active');

------------------------------------------------------------
-- Grants
------------------------------------------------------------
grant usage on schema public to anon, authenticated;
grant select on public.profiles to anon, authenticated;
grant execute on function public.my_profile() to anon, authenticated;
grant execute on function public.touch_last_seen() to authenticated;
