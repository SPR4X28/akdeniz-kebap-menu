# Supabase-Fundament: Einrichtung

Dieses Repo enthält jetzt die Datenbank für die Menükarten-Plattform. Die bisherige Website (Decap CMS + `content/*.json`) läuft unverändert weiter, bis Display-App und neues CMS fertig sind.

## Was drin ist

| Datei | Inhalt |
|---|---|
| `supabase/migrations/…_core_schema.sql` | Tabellen: `restaurants`, `restaurant_members`, `templates`, `categories` (mit Unterkategorien), `products`, `product_variants`, `menu_screens`, `screen_categories`, `displays`, `display_pairings`, `subscriptions` |
| `…_rls.sql` | Row Level Security: jeder Gastronom sieht und ändert nur seine Restaurants |
| `…_menu_realtime.sql` | Jede Änderung zählt `menu_version` hoch und schickt `menu_changed` auf den Kanal `restaurant:<id>` |
| `…_display_functions.sql` | Display-Kopplung per Code und `get_display_menu(token)` für die Bildschirme |
| `…_storage.sql` | Bucket `menu-images`, ein Ordner pro Restaurant |
| `…_templates.sql` | Die drei Templates `doener-classic` (aktiv), `street-dark`, `fresh-light` (noch inaktiv) |
| `supabase/seed/akdeniz-kebap.sql` | Findorff und Stuhr als Mandanten 1 und 2, erzeugt aus `content/findorff.json` und `content/stuhr.json` |
| `supabase/tests/tenant_isolation.sql` | Test mit zwei Gastronomen: niemand sieht fremde Daten |
| `scripts/` | Seed-Generator und Bild-Upload |

## Einmalig einrichten

### 1. Supabase-Projekt
Region **Frankfurt (eu-central-1)**, ist bereits angelegt.

### 2. Migrationen einspielen
**Variante A, SQL Editor (am einfachsten):** Im Supabase-Dashboard unter *SQL Editor* die Dateien aus `supabase/migrations/` **der Reihe nach** (nach Dateiname) einfügen und ausführen.

**Variante B, Supabase CLI:**
```bash
npx supabase login
npx supabase link --project-ref <projekt-ref>
npx supabase db push
```

### 3. Menüdaten übernehmen
Inhalt von `supabase/seed/akdeniz-kebap.sql` im SQL Editor ausführen. Das Skript darf mehrfach laufen und überschreibt nichts, was später im CMS geändert wurde.

Ändert sich vorher noch etwas in `content/*.json`, den Seed neu erzeugen:
```bash
node scripts/legacy-to-sql.mjs
```

### 4. Bilder hochladen
Auf deinem Rechner (der Service-Key bleibt lokal und kommt nie ins Repo oder Frontend):
```bash
SUPABASE_URL=https://<projekt-ref>.supabase.co \
SUPABASE_SERVICE_ROLE_KEY=<service_role key> \
node scripts/upload-legacy-images.mjs
```

### 5. Test laufen lassen
`supabase/tests/tenant_isolation.sql` im SQL Editor ausführen. Erwartet: „Alle Checks bestanden“. Alles läuft in einer Transaktion und wird zurückgerollt.

### 6. Inhaber-Konto verknüpfen
Unter *Authentication → Users → Invite user* den Inhaber einladen, dann im SQL Editor:
```sql
insert into public.restaurant_members (restaurant_id, user_id, role)
select r.id, u.id, 'owner'
from public.restaurants r, auth.users u
where r.slug in ('akdeniz-findorff', 'akdeniz-stuhr')
  and u.email = 'inhaber@example.com';
```
Mit einem Login verwaltet er dann beide Standorte.

### 7. Netlify-Umgebungsvariablen
Unter *Site configuration → Environment variables*:
- `SUPABASE_URL`: Project URL
- `SUPABASE_ANON_KEY`: anon/publishable key (darf ins Frontend, RLS schützt die Daten)

Den `service_role`-Key **nicht** in Netlify und nicht ins Frontend.

### 8. Einstellungen im Dashboard
- *Realtime → Settings*: öffentliche Kanäle erlauben („Allow public access“), die Displays haben kein Konto. Die Nachricht enthält nur die Versionsnummer.
- *Authentication → SMTP*: vor dem Livegang einen EU-Mailanbieter (z. B. Brevo) eintragen, der Standard-Mailer ist nur für Tests.

## So funktioniert ein Display

1. Der Fernseher (Smart-TV-Browser oder Fire-TV-Stick) ruft `request_display_pairing()` auf und zeigt einen 6-stelligen Code. Das `device_secret` behält er für sich.
2. Der Gastronom gibt den Code im CMS ein: `claim_display_pairing(code, restaurant_id, 'TV links', screen_id, 'landscape')`.
3. Der Fernseher fragt alle paar Sekunden `complete_display_pairing(device_secret)` und bekommt einmalig seinen `access_token`, den er dauerhaft speichert.
4. Danach lädt er `get_display_menu(access_token)`, abonniert den Kanal aus `realtime_channel` und lädt bei `menu_changed` neu. Zusätzlich alle 5 Minuten `display_heartbeat(access_token)`, damit verpasste Signale nachgeholt werden und das CMS sieht, ob der Bildschirm online ist.

Bildpfade im Menü sind Storage-Pfade. Die öffentliche URL ist
`<SUPABASE_URL>/storage/v1/object/public/menu-images/<pfad>`.

## Datenmodell in Kürze

- **Kategorie** = eine Karte auf dem Bildschirm (Döner Pita, Getränke …). `display_style` sagt dem Template, wie sie aussieht: `matrix` (Größe × Fleischsorte), `tiles`, `list`, `gallery`, `offers` (Menü-Balken). Unterkategorien über `parent_id`, maximal zwei Ebenen.
- **Produkt** mit eigenem Preis (`price_cents`) oder mit **Varianten**: `size_label` (M), `size_note` (130 g), `option_label` (Hähnchen).
- **Seite** (`menu_screens`) = was auf einem Bildschirm steht, mit Fußzeile. `screen_categories` legt fest, welche Kategorien auf welcher Seite erscheinen.
- **Display** = ein physischer Bildschirm, zeigt eine Seite im Quer- oder Hochformat.
- Preise immer in Cent. Zusatzstoffe und Allergene stehen als Legende in `restaurants.settings.legend`, pro Produkt als Kennzeichen in `allergens`/`additives`.
- Ist ein Restaurant `paused` (z. B. nach abgelaufener Schonfrist), ist das CMS schreibgeschützt, die Displays laufen weiter. Bei `cancelled` zeigen sie nichts mehr.

## Noch nicht enthalten

Display-App (Template `doener-classic` auf die neuen Daten umbauen), CMS auf Supabase Auth, Mollie-Webhook und Display-Limits je Paket folgen in eigenen Schritten.
