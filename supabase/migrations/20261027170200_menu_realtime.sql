-- ================================================================
-- Live-Updates: Jede Menüänderung zählt restaurants.menu_version hoch
-- und schickt ein Broadcast "menu_changed" auf den Kanal
-- "restaurant:<id>". Die Displays laden daraufhin das Menü neu.
-- Statement-Trigger: Speichert das CMS 20 Preise in einem Rutsch,
-- gibt es pro Restaurant trotzdem nur ein Signal.
-- ================================================================

create or replace function private.bump_menu_version(rid uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare v bigint;
begin
  update public.restaurants set menu_version = menu_version + 1
  where id = rid
  returning menu_version into v;

  if v is not null then
    perform realtime.send(
      jsonb_build_object('restaurant_id', rid, 'menu_version', v),
      'menu_changed',
      'restaurant:' || rid::text,
      false   -- öffentlicher Kanal: die Nachricht enthält nur die Versionsnummer
    );
  end if;
end $$;

revoke all on function private.bump_menu_version(uuid) from public;

create or replace function private.on_menu_change()
returns trigger language plpgsql security definer set search_path = '' as $$
declare rid uuid;
begin
  if tg_op = 'DELETE' then
    for rid in select distinct restaurant_id from old_rows loop
      perform private.bump_menu_version(rid);
    end loop;
  else
    for rid in select distinct restaurant_id from new_rows loop
      perform private.bump_menu_version(rid);
    end loop;
  end if;
  return null;
end $$;

do $$
declare t text;
begin
  foreach t in array array['categories', 'products', 'product_variants', 'menu_screens', 'screen_categories'] loop
    execute format(
      'create trigger %1$s_menu_insert after insert on public.%1$I
         referencing new table as new_rows for each statement execute function private.on_menu_change()', t);
    execute format(
      'create trigger %1$s_menu_update after update on public.%1$I
         referencing new table as new_rows for each statement execute function private.on_menu_change()', t);
    execute format(
      'create trigger %1$s_menu_delete after delete on public.%1$I
         referencing old table as old_rows for each statement execute function private.on_menu_change()', t);
  end loop;
end $$;

-- Display umkonfiguriert (andere Seite, Hochformat …). Der Heartbeat
-- (last_seen_at) löst bewusst kein Signal aus.
create or replace function private.on_display_change()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  perform private.bump_menu_version(new.restaurant_id);
  return null;
end $$;

create trigger displays_menu_change after update on public.displays
  for each row
  when ((new.screen_id, new.orientation, new.settings, new.name)
        is distinct from (old.screen_id, old.orientation, old.settings, old.name))
  execute function private.on_display_change();

-- Änderungen am Restaurant selbst (Template, Logo, Farben, Kennzeichnung)
create or replace function private.on_restaurant_change()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if (new.name, new.template_id, new.theme, new.settings, new.status)
     is distinct from (old.name, old.template_id, old.theme, old.settings, old.status) then
    new.menu_version := old.menu_version + 1;
    perform realtime.send(
      jsonb_build_object('restaurant_id', new.id, 'menu_version', new.menu_version),
      'menu_changed',
      'restaurant:' || new.id::text,
      false
    );
  end if;
  return new;
end $$;

create trigger restaurants_menu_change before update on public.restaurants
  for each row execute function private.on_restaurant_change();
