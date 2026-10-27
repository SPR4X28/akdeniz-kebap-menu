/* ================================================================
   Übernahme der bisherigen Decap-CMS-Menüs (content/*.json) in das
   neue Supabase-Datenmodell. Wird von legacy-to-sql.mjs (Seed-SQL)
   und upload-legacy-images.mjs (Bilder in den Storage) genutzt.
   Feste UUIDs (aus Namen abgeleitet), damit beides zusammenpasst und
   der Seed mehrfach laufen darf.
   ================================================================ */
import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import { basename, dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

export const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");

export const RESTAURANTS = [
  // layout entspricht data-layout im bisherigen findorff/index.html
  { file: "content/findorff.json", slug: "akdeniz-findorff", name: "Akdeniz Kebap Findorff", layouts: { seite1: "six" } },
  { file: "content/stuhr.json", slug: "akdeniz-stuhr", name: "Akdeniz Kebap Marktkauf Stuhr" },
];

const MATRIX_OPTIONS = [
  { key: "haehnchen", label: "Hähnchen", kind: "haehnchen" },
  { key: "steak", label: "Steak", kind: "steak" },
  { key: "mix", label: "Fleisch-Mix", kind: "is-mix" },
];

export function uuid(...parts) {
  const h = createHash("sha1").update("akdeniz-legacy:" + parts.join("/")).digest();
  h[6] = (h[6] & 0x0f) | 0x50; // Version 5
  h[8] = (h[8] & 0x3f) | 0x80;
  const x = h.subarray(0, 16).toString("hex");
  return `${x.slice(0, 8)}-${x.slice(8, 12)}-${x.slice(12, 16)}-${x.slice(16, 20)}-${x.slice(20)}`;
}

/* "7,90 €" -> 790, "+ 5,50 €" -> 550 */
export function cents(price) {
  const m = String(price).match(/(\d+)(?:,(\d{1,2}))?/);
  if (!m) throw new Error(`Preis nicht lesbar: ${price}`);
  return Number(m[1]) * 100 + Number((m[2] || "0").padEnd(2, "0"));
}

/* Bildpfad aus dem alten Repo -> Storage-Pfad im Ordner des Restaurants */
function imageKey(rid, path, uploads) {
  if (!path) return null;
  const file = basename(path);
  const key = `${rid}/legacy/${file}`;
  uploads.set(key, join(ROOT, path.includes("img/") ? "img" : "", file));
  return key;
}

function tileKind(t) {
  return t.kind || (t.mix ? "is-mix" : t.label === "Hähnchen" ? "haehnchen" : t.label === "Steak" ? "steak" : null);
}

function clean(obj) {
  return Object.fromEntries(Object.entries(obj).filter(([, v]) => v !== undefined && v !== null && v !== ""));
}

export function buildRestaurant(def) {
  const data = JSON.parse(readFileSync(join(ROOT, def.file), "utf8"));
  const rid = uuid(def.slug);
  const uploads = new Map();
  const out = { categories: [], products: [], variants: [], screens: [], screenCategories: [] };

  const restaurant = {
    id: rid,
    slug: def.slug,
    name: def.name,
    theme: clean({
      logo_path: imageKey(rid, data.brand.logo, uploads),
      tagline: data.brand.tagline,
      badge: data.brand.badge,
    }),
    settings: data.seite2.info ? { legend: data.seite2.info } : {},
  };

  function addProduct(cid, idx, p) {
    const id = uuid(def.slug, cid, "product", idx);
    out.products.push({ id, category_id: cid, sort_order: idx, ...p });
    return id;
  }
  function addVariant(pid, idx, v) {
    out.variants.push({ id: uuid(pid, "variant", idx), product_id: pid, sort_order: idx, ...v });
  }

  function addCategory(screenKey, screenId, cardIdx, c) {
    const cid = uuid(def.slug, screenKey, "card", cardIdx);
    const style = c.gallery ? "gallery" : c.list ? "list" : c.tiles ? "tiles" : "matrix";
    out.categories.push({
      id: cid,
      name: c.title,
      subtitle: c.subtitle,
      note: c.note,
      title_image_path: imageKey(rid, c.titleImage, uploads),
      image_path: imageKey(rid, c.image, uploads),
      display_style: style,
      settings: clean({ column_header: c.head, portion: c.portion }),
      sort_order: out.categories.length,
    });
    out.screenCategories.push({ screen_id: screenId, category_id: cid, sort_order: cardIdx });

    if (style === "matrix") {
      const pid = addProduct(cid, 0, { name: c.title });
      let i = 0;
      for (const r of c.rows) {
        for (const o of MATRIX_OPTIONS) {
          addVariant(pid, i++, {
            size_label: r.label,
            size_note: r.sub,
            option_label: o.label,
            price_cents: cents(r[o.key]),
            settings: { kind: o.kind },
          });
        }
      }
    } else if (style === "tiles") {
      const pid = addProduct(cid, 0, { name: c.title });
      c.tiles.forEach((t, i) =>
        addVariant(pid, i, {
          option_label: t.label,
          price_cents: cents(t.price),
          settings: clean({ kind: tileKind(t) }),
        }),
      );
    } else if (style === "list") {
      c.list.forEach((it, i) =>
        addProduct(cid, i, { name: it.name, price_cents: cents(it.price), image_path: imageKey(rid, it.image, uploads) }),
      );
    } else {
      c.gallery.forEach((it, i) =>
        addProduct(cid, i, {
          name: it.name,
          price_cents: cents(it.price),
          image_path: imageKey(rid, it.image, uploads),
          settings: clean({ kind: it.kind }),
        }),
      );
    }
  }

  ["seite1", "seite2"].forEach((key, sIdx) => {
    const page = data[key];
    const sid = uuid(def.slug, "screen", key);
    out.screens.push({
      id: sid,
      name: `Seite ${sIdx + 1}`,
      footer: page.foot || [],
      settings: clean({ layout: def.layouts?.[key], show_legend: key === "seite2" && page.info ? true : undefined }),
      sort_order: sIdx,
    });
    page.cards.forEach((c, i) => addCategory(key, sid, i, c));

    if (page.menu) {
      const cid = uuid(def.slug, key, "menu-offers");
      out.categories.push({
        id: cid,
        name: page.menu.title,
        subtitle: page.menu.text,
        display_style: "offers",
        settings: {},
        sort_order: out.categories.length,
      });
      out.screenCategories.push({ screen_id: sid, category_id: cid, sort_order: page.cards.length });
      page.menu.offers.forEach((o, i) =>
        addProduct(cid, i, {
          name: o.label.replace(/^\+\s*/, ""),
          price_cents: cents(o.price),
          settings: { icon: o.icon, price_prefix: "+" },
        }),
      );
    }
  });

  return { restaurant, ...out, uploads };
}
