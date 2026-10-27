-- ================================================================
-- Mandantentrennung mit Row Level Security
-- Gastronomen (owner/editor) sehen und ändern nur ihre Restaurants.
-- Displays haben kein Konto und lesen nur über Funktionen (siehe
-- display_functions). Der Plattform-Admin nutzt den Service-Key bzw.
-- das Supabase-Dashboard, beides umgeht RLS.
-- ================================================================

grant usage on schema private to authenticated, anon;

create or replace function private.is_member(rid uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.restaurant_members m
    where m.restaurant_id = rid and m.user_id = (select auth.uid())
  )
$$;

create or replace function private.is_owner(rid uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.restaurant_members m
    where m.restaurant_id = rid and m.user_id = (select auth.uid()) and m.role = 'owner'
  )
$$;

-- Schreiben nur, solange das Restaurant nicht pausiert/gekündigt ist
-- (z. B. nach abgelaufener Schonfrist). Displays laufen trotzdem weiter.
create or replace function private.can_edit(rid uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select private.is_member(rid) and exists (
    select 1 from public.restaurants r
    where r.id = rid and r.status in ('setup', 'active')
  )
$$;

revoke all on function private.is_member(uuid), private.is_owner(uuid), private.can_edit(uuid) from public;
grant execute on function private.is_member(uuid), private.is_owner(uuid), private.can_edit(uuid) to authenticated;

alter table public.templates          enable row level security;
alter table public.restaurants        enable row level security;
alter table public.restaurant_members enable row level security;
alter table public.categories         enable row level security;
alter table public.products           enable row level security;
alter table public.product_variants   enable row level security;
alter table public.menu_screens       enable row level security;
alter table public.screen_categories  enable row level security;
alter table public.displays           enable row level security;
alter table public.display_pairings   enable row level security;
alter table public.subscriptions      enable row level security;

-- Anonyme Besucher bekommen keinen direkten Tabellenzugriff.
revoke all on all tables in schema public from anon;

-- ---------- templates: für alle lesbar, Schreiben nur Admin ----------
grant select on public.templates to anon;

create policy "Aktive Templates sind lesbar" on public.templates
  for select to anon, authenticated
  using (is_active);

-- ---------- restaurants ----------
create policy "Mitglieder lesen ihr Restaurant" on public.restaurants
  for select to authenticated
  using ((select private.is_member(id)));

create policy "Mitglieder ändern ihr Restaurant" on public.restaurants
  for update to authenticated
  using ((select private.can_edit(id)))
  with check ((select private.can_edit(id)));

-- Status, Abo-Daten und menu_version sind Sache des Admins bzw. der Trigger.
revoke insert, update, delete on public.restaurants from authenticated;
grant update (name, template_id, theme, settings, timezone) on public.restaurants to authenticated;

-- ---------- restaurant_members ----------
create policy "Eigene Mitgliedschaften und Team (für owner) lesen" on public.restaurant_members
  for select to authenticated
  using (user_id = (select auth.uid()) or (select private.is_owner(restaurant_id)));

create policy "owner verwaltet das Team" on public.restaurant_members
  for all to authenticated
  using ((select private.is_owner(restaurant_id)))
  with check ((select private.is_owner(restaurant_id)));

-- Der letzte owner eines Restaurants kann nicht entfernt oder herabgestuft werden.
create or replace function private.keep_last_owner()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if old.role = 'owner' and (tg_op = 'DELETE' or new.role <> 'owner' or new.restaurant_id <> old.restaurant_id)
     and not exists (
       select 1 from public.restaurant_members
       where restaurant_id = old.restaurant_id and role = 'owner' and user_id <> old.user_id
     )
     -- Kaskaden beim Löschen des Restaurants selbst nicht blockieren
     and exists (select 1 from public.restaurants where id = old.restaurant_id)
  then
    raise exception 'Ein Restaurant braucht mindestens einen owner';
  end if;
  return coalesce(new, old);
end $$;

create trigger restaurant_members_keep_owner before update or delete on public.restaurant_members
  for each row execute function private.keep_last_owner();

-- ---------- Menüdaten: gleiches Muster für alle Tabellen ----------
do $$
declare t text;
begin
  foreach t in array array['categories', 'products', 'product_variants', 'menu_screens', 'screen_categories'] loop
    execute format(
      'create policy "Mitglieder lesen eigene Daten" on public.%I for select to authenticated
         using ((select private.is_member(restaurant_id)))', t);
    execute format(
      'create policy "Mitglieder legen eigene Daten an" on public.%I for insert to authenticated
         with check ((select private.can_edit(restaurant_id)))', t);
    execute format(
      'create policy "Mitglieder ändern eigene Daten" on public.%I for update to authenticated
         using ((select private.can_edit(restaurant_id)))
         with check ((select private.can_edit(restaurant_id)))', t);
    execute format(
      'create policy "Mitglieder löschen eigene Daten" on public.%I for delete to authenticated
         using ((select private.can_edit(restaurant_id)))', t);
  end loop;
end $$;

-- ---------- displays: neue Displays nur über die Kopplung ----------
create policy "Mitglieder lesen eigene Displays" on public.displays
  for select to authenticated
  using ((select private.is_member(restaurant_id)));

create policy "Mitglieder ändern eigene Displays" on public.displays
  for update to authenticated
  using ((select private.can_edit(restaurant_id)))
  with check ((select private.can_edit(restaurant_id)));

create policy "Mitglieder entfernen eigene Displays" on public.displays
  for delete to authenticated
  using ((select private.can_edit(restaurant_id)));

revoke insert, update on public.displays from authenticated;
grant update (name, screen_id, orientation, settings) on public.displays to authenticated;

-- ---------- display_pairings: kein direkter Zugriff ----------
revoke all on public.display_pairings from authenticated;

-- ---------- subscriptions: owner liest, schreiben nur Service-Key ----------
create policy "owner liest das Abo" on public.subscriptions
  for select to authenticated
  using ((select private.is_owner(restaurant_id)));

revoke insert, update, delete on public.subscriptions from authenticated;
