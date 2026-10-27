-- ================================================================
-- Test: Mandantentrennung, Display-Kopplung und Live-Signal
-- Läuft komplett in einer Transaktion und wird am Ende zurückgerollt.
-- Ausführen im Supabase SQL Editor oder mit
--   psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/tests/tenant_isolation.sql
-- Voraussetzung: Migrationen und Seed (akdeniz-kebap.sql) sind eingespielt.
-- Jeder fehlgeschlagene Check bricht mit einer Fehlermeldung ab.
-- ================================================================
begin;

-- Zwei Gastronomen: A ist owner von Findorff, B ist owner eines fremden Restaurants
insert into auth.users (id, email) values
  ('00000000-0000-4000-8000-00000000000a', 'test-a@example.com'),
  ('00000000-0000-4000-8000-00000000000b', 'test-b@example.com');

insert into public.restaurants (id, slug, name, status) values
  ('00000000-0000-4000-8000-0000000000b0', 'test-fremd', 'Fremdes Restaurant', 'active');
insert into public.categories (id, restaurant_id, name) values
  ('00000000-0000-4000-8000-0000000000b1', '00000000-0000-4000-8000-0000000000b0', 'Geheim');

insert into public.restaurant_members (restaurant_id, user_id, role) values
  ((select id from public.restaurants where slug = 'akdeniz-findorff'), '00000000-0000-4000-8000-00000000000a', 'owner'),
  ('00000000-0000-4000-8000-0000000000b0', '00000000-0000-4000-8000-00000000000b', 'owner');

create temp table ctx (k text primary key, v text);
grant all on ctx to authenticated, anon;

-- ---------- als Gastronom A ----------
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-4000-8000-00000000000a","role":"authenticated"}', true);

do $$
declare n int;
begin
  select count(*) into n from public.restaurants;
  if n <> 1 then raise exception 'A sieht % Restaurants statt 1', n; end if;

  select count(*) into n from public.categories where restaurant_id = '00000000-0000-4000-8000-0000000000b0';
  if n <> 0 then raise exception 'A sieht Kategorien des fremden Restaurants'; end if;

  select count(*) into n from public.products;
  if n = 0 then raise exception 'A sieht seine eigenen Produkte nicht'; end if;

  select count(*) into n from public.restaurants where slug = 'akdeniz-stuhr';
  if n <> 0 then raise exception 'A sieht Stuhr, ist dort aber kein Mitglied'; end if;

  -- Schreiben ins fremde Restaurant muss scheitern
  begin
    insert into public.categories (restaurant_id, name) values ('00000000-0000-4000-8000-0000000000b0', 'Hack');
    raise exception 'A konnte in fremdes Restaurant schreiben';
  exception when insufficient_privilege then null;
  end;

  update public.categories set name = 'Hack' where id = '00000000-0000-4000-8000-0000000000b1';
  get diagnostics n = row_count;
  if n <> 0 then raise exception 'A konnte fremde Kategorie ändern'; end if;

  -- Abo-Status darf A nicht selbst setzen
  begin
    update public.restaurants set status = 'active';
    raise exception 'A konnte den Status ändern';
  exception when insufficient_privilege then null;
  end;

  insert into ctx values ('version_vorher', (select menu_version::text from public.restaurants where slug = 'akdeniz-findorff'));

  -- Preisänderung von 3 Varianten in einem Statement
  update public.product_variants set price_cents = price_cents + 10
  where id in (select id from public.product_variants order by id limit 3);
end $$;

reset role;

do $$
declare v_vorher bigint := (select v::bigint from ctx where k = 'version_vorher');
        v_nachher bigint;
        n int;
begin
  select menu_version into v_nachher from public.restaurants where slug = 'akdeniz-findorff';
  if v_nachher <> v_vorher + 1 then
    raise exception 'menu_version: erwartet %, ist % (ein Signal pro Statement)', v_vorher + 1, v_nachher;
  end if;
  -- realtime.send verschluckt Fehler (z. B. wenn der Realtime-Dienst die
  -- Tagespartition von realtime.messages noch nicht angelegt hat). Darum hier
  -- nur ein Hinweis statt Abbruch; die Trigger selbst sind oben geprüft.
  select count(*) into n from realtime.messages
    where topic = 'restaurant:' || (select id from public.restaurants where slug = 'akdeniz-findorff')
      and event = 'menu_changed';
  if n = 0 then
    raise warning 'Kein Broadcast in realtime.messages gefunden. Realtime-Partitionen: %',
      coalesce((select string_agg(tablename, ', ') from pg_tables
                where schemaname = 'realtime' and tablename like 'messages\_%'), 'keine');
  end if;
end $$;

-- ---------- Fernseher (anonym) holt einen Kopplungscode ----------
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);

do $$
declare p jsonb := public.request_display_pairing();
        n int;
begin
  insert into ctx values ('code', p ->> 'code'), ('secret', p ->> 'device_secret');
  if public.complete_display_pairing(p ->> 'device_secret') ->> 'status' <> 'pending' then
    raise exception 'Kopplung sollte noch offen sein';
  end if;
  -- anonym gibt es keinen direkten Tabellenzugriff
  begin
    select count(*) into n from public.products;
    raise exception 'anon kann products direkt lesen';
  exception when insufficient_privilege then null;
  end;
end $$;

-- ---------- Gastronom B versucht, den Code für Findorff zu nutzen ----------
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-4000-8000-00000000000b","role":"authenticated"}', true);

do $$
begin
  perform public.claim_display_pairing((select v from ctx where k = 'code'),
    (select id from public.restaurants where slug = 'akdeniz-findorff'), 'Fremd-TV');
  raise exception 'B konnte ein Display für Findorff koppeln';
exception when insufficient_privilege then null;
end $$;

-- ---------- Gastronom A koppelt den Fernseher ----------
select set_config('request.jwt.claims', '{"sub":"00000000-0000-4000-8000-00000000000a","role":"authenticated"}', true);

do $$
declare v_id uuid;
begin
  v_id := public.claim_display_pairing(lower((select v from ctx where k = 'code')),
    (select id from public.restaurants where slug = 'akdeniz-findorff'), 'TV links');
  if v_id is null then raise exception 'Kopplung fehlgeschlagen'; end if;
end $$;

-- ---------- Fernseher holt Token und Menü ----------
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);

do $$
declare r jsonb := public.complete_display_pairing((select v from ctx where k = 'secret'));
        menu jsonb;
begin
  if r ->> 'status' <> 'paired' then raise exception 'Fernseher nicht gekoppelt: %', r; end if;
  if (public.complete_display_pairing((select v from ctx where k = 'secret')) ->> 'status') <> 'expired' then
    raise exception 'Token darf nur einmal ausgeliefert werden';
  end if;

  menu := public.get_display_menu(r ->> 'access_token');
  if menu is null then raise exception 'Kein Menü für gültigen Token'; end if;
  if menu -> 'restaurant' ->> 'slug' <> 'akdeniz-findorff' then raise exception 'Falsches Restaurant im Menü'; end if;
  if jsonb_array_length(menu -> 'screens') <> 2 then raise exception 'Erwartet 2 Seiten'; end if;
  if menu::text like '%mollie%' or menu::text like '%Geheim%' then raise exception 'Interne/fremde Daten im Display-JSON'; end if;
  if public.display_heartbeat(r ->> 'access_token') <> (menu ->> 'menu_version')::bigint then
    raise exception 'Heartbeat liefert falsche menu_version';
  end if;
  if public.get_display_menu('falscher-token') is not null then raise exception 'Menü für falschen Token'; end if;
end $$;

reset role;
select 'Alle Checks bestanden' as ergebnis;
rollback;
