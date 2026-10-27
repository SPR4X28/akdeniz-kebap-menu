#!/usr/bin/env node
/* Lädt die Bilder aus img/ und logo.png in den Supabase Storage
   (Bucket menu-images, Ordner pro Restaurant), passend zum Seed.

   Aufruf (lokal, der Service-Key bleibt auf deinem Rechner):
     SUPABASE_URL=https://<projekt>.supabase.co \
     SUPABASE_SERVICE_ROLE_KEY=… \
     node scripts/upload-legacy-images.mjs                         */
import { readFileSync } from "node:fs";
import { extname } from "node:path";
import { RESTAURANTS, buildRestaurant } from "./legacy-menu.mjs";

const url = process.env.SUPABASE_URL?.replace(/\/$/, "");
const key = process.env.SUPABASE_SERVICE_ROLE_KEY;
if (!url || !key) {
  console.error("Bitte SUPABASE_URL und SUPABASE_SERVICE_ROLE_KEY setzen.");
  process.exit(1);
}

const TYPES = { ".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg", ".webp": "image/webp", ".svg": "image/svg+xml" };
let failed = 0;

for (const def of RESTAURANTS) {
  const { uploads } = buildRestaurant(def);
  for (const [objectKey, localPath] of uploads) {
    const res = await fetch(`${url}/storage/v1/object/menu-images/${objectKey}`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${key}`,
        apikey: key,
        "Content-Type": TYPES[extname(localPath).toLowerCase()] || "application/octet-stream",
        "x-upsert": "true",
        "cache-control": "3600",
      },
      body: readFileSync(localPath),
    });
    if (res.ok) {
      console.log("ok  ", objectKey);
    } else {
      failed++;
      console.error("FEHLER", objectKey, res.status, await res.text());
    }
  }
}

process.exit(failed ? 1 : 0);
