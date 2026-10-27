-- ================================================================
-- Digitale Menükarten – Kernschema (Multi-Tenant)
-- Jede fachliche Tabelle trägt restaurant_id. Zusammengesetzte
-- Fremdschlüssel (restaurant_id, id) verhindern, dass z. B. ein
-- Produkt von Restaurant A in einer Kategorie von Restaurant B landet.
-- ================================================================

create extension if not exists pgcrypto with schema extensions;

-- Interne Hilfsfunktionen liegen in "private", das von der API
-- (PostgREST) nicht ausgeliefert wird.
create schema if not exists private;

create or replace function private.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

-- ---------------------------------------------------------------
-- Templates (global, nur vom Plattform-Admin gepflegt)
-- ---------------------------------------------------------------
create table public.templates (
  id uuid primary key default gen_random_uuid(),
  key text not null unique check (key ~ '^[a-z0-9-]+$'),   -- Ordnername im Frontend
  name text not null,
  description text,
  orientations text[] not null default '{landscape}'
    check (orientations <@ array['landscape', 'portrait'] and cardinality(orientations) > 0),
  settings_schema jsonb not null default '{}',              -- welche theme-Felder das Template kennt
  is_active boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------
-- Restaurants = Mandanten. Ein Standort = ein Restaurant = ein Abo.
-- ---------------------------------------------------------------
create table public.restaurants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique check (slug ~ '^[a-z0-9-]+$'),
  template_id uuid references public.templates (id) on delete set null,
  theme jsonb not null default '{}',      -- Logo, Farben, Tagline, Badge …
  settings jsonb not null default '{}',   -- z. B. legend (Zusatzstoffe & Allergene)
  timezone text not null default 'Europe/Berlin',
  status text not null default 'setup'
    check (status in ('setup', 'active', 'paused', 'cancelled')),
  mollie_customer_id text,
  menu_version bigint not null default 0, -- wird bei jeder Menüänderung hochgezählt
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger restaurants_updated_at before update on public.restaurants
  for each row execute function private.set_updated_at();

create table public.restaurant_members (
  restaurant_id uuid not null references public.restaurants (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  role text not null default 'editor' check (role in ('owner', 'editor')),
  created_at timestamptz not null default now(),
  primary key (restaurant_id, user_id)
);

create index restaurant_members_user_idx on public.restaurant_members (user_id);

-- ---------------------------------------------------------------
-- Menü: Kategorien (mit optionalen Unterkategorien), Produkte, Varianten
-- ---------------------------------------------------------------
create table public.categories (
  id uuid primary key default gen_random_uuid(),
  restaurant_id uuid not null references public.restaurants (id) on delete cascade,
  parent_id uuid,                                  -- null = Hauptkategorie
  name text not null,
  subtitle text,
  note text,                                       -- z. B. Handschrift-Notiz
  title_image_path text,                           -- Storage-Pfad, ersetzt den Titel als Bild
  image_path text,                                 -- Produktfoto der Kategorie
  display_style text not null default 'list'
    check (display_style in ('list', 'matrix', 'tiles', 'gallery', 'offers')),
  settings jsonb not null default '{}',            -- z. B. column_header, portion
  sort_order int not null default 0,
  is_visible boolean not null default true,
  visible_from time,                               -- Zeitsteuerung (Plus), wertet das Display aus
  visible_until time,
  visible_days smallint[] check (visible_days <@ array[1, 2, 3, 4, 5, 6, 7]::smallint[]), -- 1 = Mo
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (restaurant_id, id),
  foreign key (restaurant_id, parent_id)
    references public.categories (restaurant_id, id) on delete cascade,
  check (parent_id is distinct from id)
);

create index categories_restaurant_idx on public.categories (restaurant_id, parent_id, sort_order);

create trigger categories_updated_at before update on public.categories
  for each row execute function private.set_updated_at();

-- Höchstens zwei Ebenen: Kategorie > Unterkategorie
create or replace function private.check_category_depth()
returns trigger language plpgsql as $$
begin
  if new.parent_id is not null then
    if exists (select 1 from public.categories where id = new.parent_id and parent_id is not null) then
      raise exception 'Unterkategorien dürfen keine eigenen Unterkategorien haben';
    end if;
    if exists (select 1 from public.categories where parent_id = new.id) then
      raise exception 'Eine Kategorie mit Unterkategorien kann nicht selbst Unterkategorie werden';
    end if;
  end if;
  return new;
end $$;

create trigger categories_depth before insert or update of parent_id on public.categories
  for each row execute function private.check_category_depth();

create table public.products (
  id uuid primary key default gen_random_uuid(),
  restaurant_id uuid not null references public.restaurants (id) on delete cascade,
  category_id uuid not null,
  name text not null,
  description text,
  price_cents int check (price_cents >= 0),        -- null, wenn der Preis in den Varianten steht
  image_path text,
  allergens text[] not null default '{}',          -- Kennbuchstaben, z. B. {a,f}
  additives text[] not null default '{}',          -- Kennziffern, z. B. {1,6}
  settings jsonb not null default '{}',            -- z. B. kind (Farbe), icon
  is_available boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (restaurant_id, id),
  foreign key (restaurant_id, category_id)
    references public.categories (restaurant_id, id) on delete cascade
);

create index products_category_idx on public.products (restaurant_id, category_id, sort_order);

create trigger products_updated_at before update on public.products
  for each row execute function private.set_updated_at();

-- Varianten bilden Größen (Zeilen) und Optionen (Spalten) ab,
-- z. B. Döner Pita: size_label 'M', size_note '130 g', option_label 'Hähnchen'.
create table public.product_variants (
  id uuid primary key default gen_random_uuid(),
  restaurant_id uuid not null references public.restaurants (id) on delete cascade,
  product_id uuid not null,
  size_label text,
  size_note text,
  option_label text,
  price_cents int not null check (price_cents >= 0),
  settings jsonb not null default '{}',
  is_available boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (size_label is not null or option_label is not null),
  foreign key (restaurant_id, product_id)
    references public.products (restaurant_id, id) on delete cascade
);

create index product_variants_product_idx on public.product_variants (restaurant_id, product_id, sort_order);

create trigger product_variants_updated_at before update on public.product_variants
  for each row execute function private.set_updated_at();

-- ---------------------------------------------------------------
-- Bildschirmseiten ("Seite 1", "Seite 2") und Displays
-- ---------------------------------------------------------------
create table public.menu_screens (
  id uuid primary key default gen_random_uuid(),
  restaurant_id uuid not null references public.restaurants (id) on delete cascade,
  name text not null,
  footer text[] not null default '{}',
  settings jsonb not null default '{}',            -- z. B. layout, show_legend
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (restaurant_id, id)
);

create trigger menu_screens_updated_at before update on public.menu_screens
  for each row execute function private.set_updated_at();

create table public.screen_categories (
  restaurant_id uuid not null references public.restaurants (id) on delete cascade,
  screen_id uuid not null,
  category_id uuid not null,
  sort_order int not null default 0,
  primary key (screen_id, category_id),
  foreign key (restaurant_id, screen_id)
    references public.menu_screens (restaurant_id, id) on delete cascade,
  foreign key (restaurant_id, category_id)
    references public.categories (restaurant_id, id) on delete cascade
);

create index screen_categories_category_idx on public.screen_categories (restaurant_id, category_id);

create table public.displays (
  id uuid primary key default gen_random_uuid(),
  restaurant_id uuid not null references public.restaurants (id) on delete cascade,
  screen_id uuid,                                  -- null = erste Seite
  name text not null,
  orientation text not null default 'landscape' check (orientation in ('landscape', 'portrait')),
  access_token text not null unique default encode(extensions.gen_random_bytes(24), 'hex'),
  settings jsonb not null default '{}',
  last_seen_at timestamptz,
  last_menu_version bigint,
  created_at timestamptz not null default now(),
  foreign key (restaurant_id, screen_id)
    references public.menu_screens (restaurant_id, id) on delete set null (screen_id)
);

create index displays_restaurant_idx on public.displays (restaurant_id);

-- Kopplung per Code: Der Fernseher zeigt einen 6-stelligen Code,
-- der Gastronom tippt ihn im CMS ein. Nur Funktionen greifen hierauf zu.
create table public.display_pairings (
  code text primary key check (code ~ '^[A-Z2-9]{6}$'),
  device_secret_hash text not null unique,
  display_id uuid references public.displays (id) on delete cascade,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default now() + interval '15 minutes',
  claimed_at timestamptz
);

-- ---------------------------------------------------------------
-- Abos (Spiegel aus Mollie, nur per Edge Function/Service-Key geschrieben)
-- ---------------------------------------------------------------
create table public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  restaurant_id uuid not null references public.restaurants (id) on delete cascade,
  plan text not null check (plan in ('basis', 'plus')),
  billing_interval text not null default 'monthly' check (billing_interval in ('monthly', 'yearly')),
  extra_displays int not null default 0 check (extra_displays >= 0),
  status text not null default 'pending'
    check (status in ('pending', 'active', 'past_due', 'cancelled')),
  mollie_subscription_id text unique,
  mollie_mandate_id text,
  current_period_end timestamptz,
  grace_until timestamptz,                         -- danach CMS schreibgeschützt
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index subscriptions_restaurant_idx on public.subscriptions (restaurant_id);

create trigger subscriptions_updated_at before update on public.subscriptions
  for each row execute function private.set_updated_at();
