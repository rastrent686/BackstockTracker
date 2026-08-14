-- Remembered product names, keyed by UPC.
-- Run this once in Supabase: SQL Editor -> New query -> Run.
--
-- This table is what makes scanning get faster over time: whenever you save an
-- item that has a UPC, the app stores the name here. The next time that UPC is
-- scanned -- on any device, even months later, even if the item was deleted --
-- the name fills itself in. Your own names take priority over the public
-- product databases.

create table if not exists public.backroom_upc_names (
  upc     text primary key,
  name    text not null,
  updated bigint
);

alter table public.backroom_upc_names enable row level security;

-- Matches how backroom_items is set up: the anon public key may read and write.
-- Anyone with your app's URL can do the same, so keep the link to staff only.
drop policy if exists "anon read upc names"  on public.backroom_upc_names;
drop policy if exists "anon write upc names" on public.backroom_upc_names;

create policy "anon read upc names"
  on public.backroom_upc_names for select
  to anon using (true);

create policy "anon write upc names"
  on public.backroom_upc_names for all
  to anon using (true) with check (true);

-- Lets other phones pick up new names live, like the item list already does.
alter publication supabase_realtime add table public.backroom_upc_names;
