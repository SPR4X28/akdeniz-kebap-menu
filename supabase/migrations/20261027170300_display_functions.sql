-- ================================================================
-- Display-Zugriff ohne Benutzerkonto
-- 1. Kopplung: Fernseher holt einen Code, Gastronom gibt ihn im CMS
--    ein, Fernseher bekommt seinen access_token.
-- 2. Danach liest das Display sein Menü nur über get_display_menu.
-- Alle Funktionen sind security definer und geben nur öffentliche
-- Menüdaten zurück, keine internen Felder wie Abo- oder Mollie-Daten.
-- ================================================================

-- ---------- Menü als JSON ----------
create or replace function private.product_json(p public.products)
returns jsonb language sql stable set search_path = '' as $$
  select jsonb_build_object(
    'id', p.id,
    'name', p.name,
    'description', p.description,
    'price_cents', p.price_cents,
    'image_path', p.image_path,
    'allergens', to_jsonb(p.allergens),
    'additives', to_jsonb(p.additives),
    'settings', p.settings,
    'variants', coalesce((
      select jsonb_agg(jsonb_build_object(
          'id', v.id,
          'size_label', v.size_label,
          'size_note', v.size_note,
          'option_label', v.option_label,
          'price_cents', v.price_cents,
          'settings', v.settings
        ) order by v.sort_order, v.created_at)
      from public.product_variants v
      where v.product_id = p.id and v.is_available
    ), '[]'::jsonb)
  )
$$;

create or replace function private.category_base_json(c public.categories)
returns jsonb language sql stable set search_path = '' as $$
  select jsonb_build_object(
    'id', c.id,
    'name', c.name,
    'subtitle', c.subtitle,
    'note', c.note,
    'title_image_path', c.title_image_path,
    'image_path', c.image_path,
    'display_style', c.display_style,
    'settings', c.settings,
    'visible_from', c.visible_from,
    'visible_until', c.visible_until,
    'visible_days', to_jsonb(c.visible_days),
    'products', coalesce((
      select jsonb_agg(private.product_json(p) order by p.sort_order, p.created_at)
      from public.products p
      where p.category_id = c.id and p.is_available
    ), '[]'::jsonb)
  )
$$;

-- Hauptkategorie mit ihren Unterkategorien (maximal zwei Ebenen)
create or replace function private.category_json(c public.categories)
returns jsonb language sql stable set search_path = '' as $$
  select private.category_base_json(c) || jsonb_build_object(
    'children', coalesce((
      select jsonb_agg(private.category_base_json(sc) order by sc.sort_order, sc.created_at)
      from public.categories sc
      where sc.parent_id = c.id and sc.is_visible
    ), '[]'::jsonb)
  )
$$;

create or replace function private.menu_json(rid uuid)
returns jsonb language sql stable set search_path = '' as $$
  select jsonb_build_object(
    'menu_version', r.menu_version,
    'restaurant', jsonb_build_object(
      'id', r.id,
      'name', r.name,
      'slug', r.slug,
      'timezone', r.timezone,
      'theme', r.theme,
      'legend', r.settings -> 'legend'
    ),
    'template', (select jsonb_build_object('key', t.key, 'orientations', to_jsonb(t.orientations))
                 from public.templates t where t.id = r.template_id),
    'screens', coalesce((
      select jsonb_agg(jsonb_build_object(
          'id', s.id,
          'name', s.name,
          'footer', to_jsonb(s.footer),
          'settings', s.settings,
          'categories', coalesce((
            select jsonb_agg(private.category_json(c) order by sc.sort_order)
            from public.screen_categories sc
            join public.categories c on c.id = sc.category_id
            where sc.screen_id = s.id and c.is_visible
          ), '[]'::jsonb)
        ) order by s.sort_order, s.created_at)
      from public.menu_screens s
      where s.restaurant_id = r.id
    ), '[]'::jsonb)
  )
  from public.restaurants r
  where r.id = rid
$$;

-- Für die Vorschau im CMS: dasselbe JSON, das ein Display bekommt.
create or replace function public.get_menu_preview(p_restaurant_id uuid)
returns jsonb language plpgsql stable security definer set search_path = '' as $$
begin
  if not private.is_member(p_restaurant_id) then
    raise exception 'Kein Zugriff auf dieses Restaurant' using errcode = '42501';
  end if;
  return private.menu_json(p_restaurant_id);
end $$;

-- ---------- Display liest sein Menü ----------
-- Rückgabe null bei unbekanntem Token. Ein gekündigtes Restaurant
-- liefert ebenfalls null; pausierte Restaurants laufen weiter.
create or replace function public.get_display_menu(p_token text)
returns jsonb language plpgsql volatile security definer set search_path = '' as $$
declare
  d public.displays;
  menu jsonb;
begin
  select * into d from public.displays where access_token = p_token;
  if not found then
    return null;
  end if;
  if exists (select 1 from public.restaurants where id = d.restaurant_id and status = 'cancelled') then
    return null;
  end if;

  menu := private.menu_json(d.restaurant_id);

  update public.displays
    set last_seen_at = now(), last_menu_version = (menu ->> 'menu_version')::bigint
    where id = d.id;

  return menu || jsonb_build_object(
    'display', jsonb_build_object(
      'id', d.id,
      'name', d.name,
      'orientation', d.orientation,
      'screen_id', coalesce(d.screen_id, (
        select s.id from public.menu_screens s
        where s.restaurant_id = d.restaurant_id
        order by s.sort_order, s.created_at limit 1)),
      'settings', d.settings
    ),
    'realtime_channel', 'restaurant:' || d.restaurant_id::text
  );
end $$;

-- Leichtgewichtiger Lebenszeichen-Aufruf (z. B. alle 5 Minuten):
-- meldet das Display als online und liefert die aktuelle menu_version,
-- damit verpasste Realtime-Signale nachgeholt werden.
create or replace function public.display_heartbeat(p_token text)
returns bigint language plpgsql volatile security definer set search_path = '' as $$
declare v bigint;
begin
  update public.displays d
    set last_seen_at = now()
    from public.restaurants r
    where d.access_token = p_token and r.id = d.restaurant_id
    returning r.menu_version into v;
  return v;
end $$;

-- ---------- Kopplung per Code ----------
create or replace function public.request_display_pairing()
returns jsonb language plpgsql volatile security definer set search_path = '' as $$
declare
  alphabet constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';  -- ohne 0/O, 1/I
  v_code text;
  v_secret text := encode(extensions.gen_random_bytes(32), 'hex');
  v_bytes bytea;
  v_expires timestamptz;
begin
  delete from public.display_pairings where expires_at < now() - interval '1 day';

  if (select count(*) from public.display_pairings where expires_at > now() and display_id is null) > 1000 then
    raise exception 'Zu viele offene Kopplungen, bitte später erneut versuchen';
  end if;

  loop
    v_bytes := extensions.gen_random_bytes(6);
    v_code := '';
    for i in 0..5 loop
      v_code := v_code || substr(alphabet, (get_byte(v_bytes, i) % 32) + 1, 1);
    end loop;

    insert into public.display_pairings (code, device_secret_hash)
      values (v_code, encode(extensions.digest(v_secret, 'sha256'), 'hex'))
      on conflict (code) do nothing
      returning expires_at into v_expires;
    exit when v_expires is not null;
  end loop;

  return jsonb_build_object('code', v_code, 'device_secret', v_secret, 'expires_at', v_expires);
end $$;

-- Gastronom koppelt im CMS: Code eintippen, Namen und Seite wählen.
create or replace function public.claim_display_pairing(
  p_code text,
  p_restaurant_id uuid,
  p_name text,
  p_screen_id uuid default null,
  p_orientation text default 'landscape'
)
returns uuid language plpgsql volatile security definer set search_path = '' as $$
declare
  v_display_id uuid;
begin
  if not private.can_edit(p_restaurant_id) then
    raise exception 'Kein Zugriff auf dieses Restaurant' using errcode = '42501';
  end if;

  perform 1 from public.display_pairings
    where code = upper(trim(p_code)) and expires_at > now() and display_id is null
    for update;
  if not found then
    raise exception 'Code ungültig oder abgelaufen' using errcode = 'P0002';
  end if;

  insert into public.displays (restaurant_id, screen_id, name, orientation)
    values (p_restaurant_id, p_screen_id, p_name, p_orientation)
    returning id into v_display_id;

  update public.display_pairings
    set display_id = v_display_id, claimed_at = now()
    where code = upper(trim(p_code));

  return v_display_id;
end $$;

-- Fernseher fragt alle paar Sekunden nach, ob er gekoppelt wurde.
-- Der Token wird genau einmal ausgeliefert, danach ist die Kopplung weg.
create or replace function public.complete_display_pairing(p_device_secret text)
returns jsonb language plpgsql volatile security definer set search_path = '' as $$
declare
  p public.display_pairings;
  v_token text;
begin
  select * into p from public.display_pairings
    where device_secret_hash = encode(extensions.digest(p_device_secret, 'sha256'), 'hex')
    for update;

  if not found or (p.display_id is null and p.expires_at <= now()) then
    return jsonb_build_object('status', 'expired');
  end if;
  if p.display_id is null then
    return jsonb_build_object('status', 'pending', 'code', p.code, 'expires_at', p.expires_at);
  end if;

  select access_token into v_token from public.displays where id = p.display_id;
  delete from public.display_pairings where code = p.code;
  return jsonb_build_object('status', 'paired', 'access_token', v_token);
end $$;

-- Neuer Token, z. B. wenn ein Gerät verloren ging. Das alte Gerät
-- zeigt danach nichts mehr an und muss neu gekoppelt werden.
create or replace function public.rotate_display_token(p_display_id uuid)
returns void language plpgsql volatile security definer set search_path = '' as $$
begin
  update public.displays
    set access_token = encode(extensions.gen_random_bytes(24), 'hex')
    where id = p_display_id and private.can_edit(restaurant_id);
  if not found then
    raise exception 'Display nicht gefunden' using errcode = 'P0002';
  end if;
end $$;

-- ---------- Rechte ----------
revoke all on function private.product_json(public.products),
                       private.category_base_json(public.categories),
                       private.category_json(public.categories),
                       private.menu_json(uuid) from public;

revoke all on function public.get_menu_preview(uuid),
                       public.get_display_menu(text),
                       public.display_heartbeat(text),
                       public.request_display_pairing(),
                       public.claim_display_pairing(text, uuid, text, uuid, text),
                       public.complete_display_pairing(text),
                       public.rotate_display_token(uuid) from public, anon, authenticated;

grant execute on function public.get_display_menu(text),
                          public.display_heartbeat(text),
                          public.request_display_pairing(),
                          public.complete_display_pairing(text) to anon, authenticated;

grant execute on function public.get_menu_preview(uuid),
                          public.claim_display_pairing(text, uuid, text, uuid, text),
                          public.rotate_display_token(uuid) to authenticated;
