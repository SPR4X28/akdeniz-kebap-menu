#!/usr/bin/env node
/* Erzeugt supabase/seed/akdeniz-kebap.sql aus content/findorff.json
   und content/stuhr.json.  Aufruf:  node scripts/legacy-to-sql.mjs  */
import { writeFileSync } from "node:fs";
import { join } from "node:path";
import { RESTAURANTS, ROOT, buildRestaurant } from "./legacy-menu.mjs";

const q = (v) =>
  v === undefined || v === null ? "null"
  : typeof v === "number" ? String(v)
  : typeof v === "boolean" ? String(v)
  : Array.isArray(v) && v.every((x) => typeof x === "string") ? `array[${v.map(q).join(", ")}]::text[]`
  : typeof v === "object" ? `${q(JSON.stringify(v))}::jsonb`
  : `'${String(v).replace(/'/g, "''")}'`;

function insert(table, rows, cols) {
  if (!rows.length) return "";
  const values = rows.map((r) => `  (${cols.map((c) => q(c === "settings" ? r[c] ?? {} : r[c])).join(", ")})`).join(",\n");
  return `insert into public.${table} (${cols.join(", ")}) values\n${values}\non conflict do nothing;\n\n`;
}

let sql = `-- ================================================================
-- Seed: Akdeniz Kebap Findorff + Marktkauf Stuhr (Mandanten 1 und 2)
-- ERZEUGT von scripts/legacy-to-sql.mjs aus content/*.json, nicht von
-- Hand bearbeiten. Läuft mehrfach ohne Schaden (on conflict do nothing),
-- überschreibt also keine Änderungen, die im CMS gemacht wurden.
-- ================================================================

begin;

`;

for (const def of RESTAURANTS) {
  const r = buildRestaurant(def);
  const rid = r.restaurant.id;
  const withRid = (rows) => rows.map((x) => ({ restaurant_id: rid, ...x }));

  sql += `-- ---------- ${r.restaurant.name} ----------\n`;
  sql += `insert into public.restaurants (id, slug, name, template_id, theme, settings, status) values
  (${q(rid)}, ${q(r.restaurant.slug)}, ${q(r.restaurant.name)},
   (select id from public.templates where key = 'doener-classic'),
   ${q(r.restaurant.theme)}, ${q(r.restaurant.settings)}, 'active')
on conflict do nothing;\n\n`;
  sql += insert("menu_screens", withRid(r.screens), ["id", "restaurant_id", "name", "footer", "settings", "sort_order"]);
  sql += insert("categories", withRid(r.categories), [
    "id", "restaurant_id", "name", "subtitle", "note", "title_image_path", "image_path", "display_style", "settings", "sort_order",
  ]);
  sql += insert("products", withRid(r.products), ["id", "restaurant_id", "category_id", "name", "price_cents", "image_path", "settings", "sort_order"]);
  sql += insert("product_variants", withRid(r.variants), [
    "id", "restaurant_id", "product_id", "size_label", "size_note", "option_label", "price_cents", "settings", "sort_order",
  ]);
  sql += insert("screen_categories", withRid(r.screenCategories), ["restaurant_id", "screen_id", "category_id", "sort_order"]);
}

sql += "commit;\n";

const target = join(ROOT, "supabase/seed/akdeniz-kebap.sql");
writeFileSync(target, sql);
console.log("geschrieben:", target);
