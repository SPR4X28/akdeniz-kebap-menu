-- ================================================================
-- Seed: Akdeniz Kebap Findorff + Marktkauf Stuhr (Mandanten 1 und 2)
-- ERZEUGT von scripts/legacy-to-sql.mjs aus content/*.json, nicht von
-- Hand bearbeiten. Läuft mehrfach ohne Schaden (on conflict do nothing),
-- überschreibt also keine Änderungen, die im CMS gemacht wurden.
-- ================================================================

begin;

-- ---------- Akdeniz Kebap Findorff ----------
insert into public.restaurants (id, slug, name, template_id, theme, settings, status) values
  ('4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'akdeniz-findorff', 'Akdeniz Kebap Findorff',
   (select id from public.templates where key = 'doener-classic'),
   '{"logo_path":"4856ed4e-6573-5314-8bfb-4df2d2b7352c/legacy/logo.png","tagline":["Frisch","Hausgemacht","Einfach lecker"],"badge":"Einzigartiger Geschmack\nGARANTIERT!"}'::jsonb, '{"legend":{"title":"Kennzeichnung","additives":[{"n":"1","text":"Mit Konservierungsstoffen"},{"n":"2","text":"Chininhaltig"},{"n":"3","text":"Mit Phosphat"},{"n":"4","text":"Mit Antioxidationsmittel"},{"n":"5","text":"Geschwefelt"},{"n":"6","text":"Koffeinhaltig"},{"n":"7","text":"Mit Farbstoff"},{"n":"8","text":"Mit Süßungsmittel"},{"n":"9","text":"Mit Geschmacksverstärker"},{"n":"10","text":"Geschwärzt"},{"n":"11","text":"Stabilisatoren"},{"n":"12","text":"Mit Säuerungsmittel"}],"allergens":[{"n":"a","text":"Glutenhaltiges Getreide (Weizen)"},{"n":"b","text":"Krebstiere"},{"n":"c","text":"Eier"},{"n":"d","text":"Fisch"},{"n":"e","text":"Erdnüsse"},{"n":"f","text":"Milch und Laktose"},{"n":"g","text":"Schalenfrüchte (Nüsse)"},{"n":"h","text":"Lupine"},{"n":"i","text":"Weichtiere"},{"n":"j","text":"Sellerie"},{"n":"k","text":"Senf"},{"n":"l","text":"Sesamsamen"},{"n":"m","text":"Schwefeldioxid und Sulphite"},{"n":"n","text":"Soja"}]}}'::jsonb, 'active')
on conflict do nothing;

insert into public.menu_screens (id, restaurant_id, name, footer, settings, sort_order) values
  ('022fc77c-d557-5d11-b2b8-62573b1b880c', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'Seite 1', array['Alle Gerichte frisch zubereitet · Hähnchen, Steak oder Fleisch-Mix zur Wahl', 'Alle Preise in Euro, inkl. MwSt.']::text[], '{"layout":"six"}'::jsonb, 0),
  ('0eb3fb57-f448-5e92-ba1a-ad054760f6a7', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'Seite 2', array['Zusatzstoffe & Allergene – siehe Kennzeichnung unten.', 'Alle Preise in Euro, inkl. MwSt.']::text[], '{"show_legend":true}'::jsonb, 1)
on conflict do nothing;

insert into public.categories (id, restaurant_id, name, subtitle, note, title_image_path, image_path, display_style, settings, sort_order) values
  ('2e680cbb-b525-50d2-a593-bebe953cd5d2', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'Döner Pita', 'Knusprig. Saftig. Echt Akdeniz.', 'Immer eine
gute Wahl!', '4856ed4e-6573-5314-8bfb-4df2d2b7352c/legacy/doener-title.png', '4856ed4e-6573-5314-8bfb-4df2d2b7352c/legacy/doener-cut.png', 'matrix', '{"column_header":"Größe"}'::jsonb, 0),
  ('6d46b1f3-bbcb-58f9-ae6c-51abf80c83af', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'Dürüm', 'Gerollt. Voller Geschmack.', 'Mehr Geschmack
zum Mitnehmen!', '4856ed4e-6573-5314-8bfb-4df2d2b7352c/legacy/dueruem-title.png', '4856ed4e-6573-5314-8bfb-4df2d2b7352c/legacy/dueruem-cut.png', 'matrix', '{"column_header":"Größe"}'::jsonb, 1),
  ('03f4cc6e-049a-54b4-a37e-fd67361a7a9d', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'Box', 'Praktisch. Zum Löffeln.', 'Perfekt für
zwischendurch!', '4856ed4e-6573-5314-8bfb-4df2d2b7352c/legacy/box-title.png', '4856ed4e-6573-5314-8bfb-4df2d2b7352c/legacy/box-cut.png', 'tiles', '{"portion":"Nur Größe M · 130 g"}'::jsonb, 2),
  ('67e67341-ddf6-5489-b720-87726d1c2f9a', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'Teller', 'Angerichtet. Richtig satt.', 'Genuss auf
dem Teller!', '4856ed4e-6573-5314-8bfb-4df2d2b7352c/legacy/teller-title.png', '4856ed4e-6573-5314-8bfb-4df2d2b7352c/legacy/teller-cut.png', 'matrix', '{"column_header":"Größe"}'::jsonb, 3),
  ('c3884d2c-7374-5876-8b31-724ab568573b', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'Rollo', 'Gerollt. Aus dem Ofen gebacken.', 'Frisch aus
dem Ofen!', '4856ed4e-6573-5314-8bfb-4df2d2b7352c/legacy/rollo-title.png', '4856ed4e-6573-5314-8bfb-4df2d2b7352c/legacy/rollo-cut.png', 'matrix', '{"column_header":"Größe"}'::jsonb, 4),
  ('661e69d1-72e4-5b53-873b-7394c8db9abc', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'Türkische Pizza', 'Lahmacun', 'Täglich frisch
gebacken!', '4856ed4e-6573-5314-8bfb-4df2d2b7352c/legacy/pizza-title.png', '4856ed4e-6573-5314-8bfb-4df2d2b7352c/legacy/pizza-cut.png', 'tiles', '{}'::jsonb, 5),
  ('5b301d34-f491-5e40-94a9-3abc0370dd55', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'Mach''s zum Menü', 'Unser Spar-Tipp für Döner Pita, Dürüm, Türkische Pizza und Rollo.', null, null, null, 'offers', '{}'::jsonb, 6),
  ('3628ccb3-ec91-5e27-a7b9-7b6fb6f0a124', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'Vegetarisch', 'Ohne Fleisch für Unsere Vegetarischen Freunde', null, null, null, 'list', '{}'::jsonb, 7),
  ('9c17df1f-c5c2-5f19-9465-58b669729ab2', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'Pizza', '32 cm · Ofenfrisch', null, null, null, 'gallery', '{}'::jsonb, 8),
  ('c2b9d422-9946-53d1-bb5c-754431247a63', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'Falafel & Halloumi', null, null, null, null, 'list', '{}'::jsonb, 9),
  ('b2a085ec-2dd4-543e-a944-07b017f61937', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'Extras & Beilagen', 'Für den Extra Hunger', null, null, null, 'list', '{}'::jsonb, 10),
  ('deacd335-b4d3-5218-b61d-f482b463424c', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'Getränke', 'Eiskalt serviert', null, null, null, 'list', '{}'::jsonb, 11)
on conflict do nothing;

insert into public.products (id, restaurant_id, category_id, name, price_cents, image_path, settings, sort_order) values
  ('a859a591-00a4-50bd-b086-95245abf0242', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '2e680cbb-b525-50d2-a593-bebe953cd5d2', 'Döner Pita', null, null, '{}'::jsonb, 0),
  ('6d9b982e-7a79-5829-bb4f-06946fc21f16', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '6d46b1f3-bbcb-58f9-ae6c-51abf80c83af', 'Dürüm', null, null, '{}'::jsonb, 0),
  ('6eedc68e-2a42-5db5-a326-31e2b8dd9a47', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '03f4cc6e-049a-54b4-a37e-fd67361a7a9d', 'Box', null, null, '{}'::jsonb, 0),
  ('8415c650-235e-59ba-9413-e354d6fc5da9', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '67e67341-ddf6-5489-b720-87726d1c2f9a', 'Teller', null, null, '{}'::jsonb, 0),
  ('2fb9e1eb-f696-5627-b81c-4410b888d98f', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'c3884d2c-7374-5876-8b31-724ab568573b', 'Rollo', null, null, '{}'::jsonb, 0),
  ('850113e9-5ba2-5188-b823-d6d641fd482b', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '661e69d1-72e4-5b53-873b-7394c8db9abc', 'Türkische Pizza', null, null, '{}'::jsonb, 0),
  ('7d68dd64-1941-5690-a15c-b8e2a7b4cebf', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '5b301d34-f491-5e40-94a9-3abc0370dd55', 'Pommes & Softdrink 0,33 l', 550, null, '{"icon":"cola","price_prefix":"+"}'::jsonb, 0),
  ('302f990b-0cb0-5661-8498-0ba2e3b85444', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '5b301d34-f491-5e40-94a9-3abc0370dd55', 'Pommes & Wasser / Ayran', 490, null, '{"icon":"ayran","price_prefix":"+"}'::jsonb, 1),
  ('26df9fbb-6a34-5fa7-9097-a044725d9aa1', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '3628ccb3-ec91-5e27-a7b9-7b6fb6f0a124', 'Veggie Pita', 690, null, '{}'::jsonb, 0),
  ('b7c8bddc-179c-5bbe-b78c-1450d9e425c7', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '3628ccb3-ec91-5e27-a7b9-7b6fb6f0a124', 'Dürüm Vegetarisch', 790, null, '{}'::jsonb, 1),
  ('3d8ed3e3-66a9-5f7b-b087-ce84a86f4ff6', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '9c17df1f-c5c2-5f19-9465-58b669729ab2', 'Margherita', 1000, '4856ed4e-6573-5314-8bfb-4df2d2b7352c/legacy/pizza-margherita.png', '{"kind":"plain"}'::jsonb, 0),
  ('ac73c02a-80d6-5304-8381-726c7a8f99a7', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '9c17df1f-c5c2-5f19-9465-58b669729ab2', 'Tonno', 1150, '4856ed4e-6573-5314-8bfb-4df2d2b7352c/legacy/pizza-tonno.png', '{"kind":"is-mix"}'::jsonb, 1),
  ('b6ec73bb-3f5d-5936-9008-5e4c16a254b4', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '9c17df1f-c5c2-5f19-9465-58b669729ab2', 'Sucuk', 1150, '4856ed4e-6573-5314-8bfb-4df2d2b7352c/legacy/pizza-sucuk.png', '{"kind":"haehnchen"}'::jsonb, 2),
  ('eac12eb0-20eb-5c00-8bcc-5d551ed5314f', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '9c17df1f-c5c2-5f19-9465-58b669729ab2', 'Steak', 1250, '4856ed4e-6573-5314-8bfb-4df2d2b7352c/legacy/pizza-steak.png', '{"kind":"steak"}'::jsonb, 3),
  ('6b409ba1-21b3-53a5-8b69-62f9ac1a66dd', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '9c17df1f-c5c2-5f19-9465-58b669729ab2', 'Chicken', 1200, '4856ed4e-6573-5314-8bfb-4df2d2b7352c/legacy/pizza-chicken.png', '{"kind":"salad"}'::jsonb, 4),
  ('72813f7f-76ac-5f9b-bbd1-df2018b2d87c', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'c2b9d422-9946-53d1-bb5c-754431247a63', 'Falafel o. Halloumi Pita', 790, null, '{}'::jsonb, 0),
  ('c9f2b0bc-fedc-5933-8be5-caaa312465f7', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'c2b9d422-9946-53d1-bb5c-754431247a63', 'Dürüm Falafel o. Halloumi', 890, null, '{}'::jsonb, 1),
  ('6bbd3d8e-8f08-52d8-b0fa-110ea4280996', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'c2b9d422-9946-53d1-bb5c-754431247a63', 'Falafel o. Halloumi Box', 890, null, '{}'::jsonb, 2),
  ('042ea793-e9b1-50d0-8e2f-0e654adf1112', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'c2b9d422-9946-53d1-bb5c-754431247a63', 'Falafel o. Halloumi Teller', 1190, null, '{}'::jsonb, 3),
  ('f31b939e-d40c-517a-99dd-64dbc154c3df', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'b2a085ec-2dd4-543e-a944-07b017f61937', 'Pommes', 350, null, '{}'::jsonb, 0),
  ('8f86816b-a4d0-59cb-9194-813e84fd86b9', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'b2a085ec-2dd4-543e-a944-07b017f61937', 'Reis', 350, null, '{}'::jsonb, 1),
  ('034b841f-46a8-58e0-a809-012e6cfe5954', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'b2a085ec-2dd4-543e-a944-07b017f61937', 'Sauce (Extra)', 200, null, '{}'::jsonb, 2),
  ('064c5a60-5781-5a80-b2dc-aadb9c8a940d', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'b2a085ec-2dd4-543e-a944-07b017f61937', 'Ketchup / Mayo', 50, null, '{}'::jsonb, 3),
  ('7b36046b-e670-5723-ae9d-54e360d714a3', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'b2a085ec-2dd4-543e-a944-07b017f61937', 'Brot', 100, null, '{}'::jsonb, 4),
  ('04199cf3-5fa5-5ec0-9eb7-e827c3731e69', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'deacd335-b4d3-5218-b61d-f482b463424c', 'Softdrink 0,33 l', 350, null, '{}'::jsonb, 0),
  ('6b8f2c32-be43-56a5-bf45-fbaa6dd65076', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'deacd335-b4d3-5218-b61d-f482b463424c', 'Wasser 0,5 l', 250, null, '{}'::jsonb, 1),
  ('8f70eefc-8aa9-53f9-908a-3a5c44f03e30', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'deacd335-b4d3-5218-b61d-f482b463424c', 'Ayran 0,25 l', 250, null, '{}'::jsonb, 2)
on conflict do nothing;

insert into public.product_variants (id, restaurant_id, product_id, size_label, size_note, option_label, price_cents, settings, sort_order) values
  ('9db0ccf2-158d-52b2-ab59-28d6bef1c4e2', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'a859a591-00a4-50bd-b086-95245abf0242', 'M', '130 g', 'Hähnchen', 790, '{"kind":"haehnchen"}'::jsonb, 0),
  ('1b7de00f-1852-5da4-97af-d5f5978a2042', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'a859a591-00a4-50bd-b086-95245abf0242', 'M', '130 g', 'Steak', 1090, '{"kind":"steak"}'::jsonb, 1),
  ('f58a405d-9d27-5728-aff8-981460330360', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'a859a591-00a4-50bd-b086-95245abf0242', 'M', '130 g', 'Fleisch-Mix', 950, '{"kind":"is-mix"}'::jsonb, 2),
  ('ad7aa24f-5d78-579e-8a1b-df651b74bc65', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'a859a591-00a4-50bd-b086-95245abf0242', 'L', '180 g', 'Hähnchen', 990, '{"kind":"haehnchen"}'::jsonb, 3),
  ('2ae9097a-297f-5d40-88b8-ce8e2e810ad2', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'a859a591-00a4-50bd-b086-95245abf0242', 'L', '180 g', 'Steak', 1350, '{"kind":"steak"}'::jsonb, 4),
  ('6a872df0-dac8-5c24-ab3a-2cb333944b58', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'a859a591-00a4-50bd-b086-95245abf0242', 'L', '180 g', 'Fleisch-Mix', 1190, '{"kind":"is-mix"}'::jsonb, 5),
  ('d0f4b31b-89d9-5e73-b0ce-2d7a633fce26', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'a859a591-00a4-50bd-b086-95245abf0242', 'XL', '230 g', 'Hähnchen', 1150, '{"kind":"haehnchen"}'::jsonb, 6),
  ('27a28532-b249-56c7-ab74-ce649de010a6', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'a859a591-00a4-50bd-b086-95245abf0242', 'XL', '230 g', 'Steak', 1550, '{"kind":"steak"}'::jsonb, 7),
  ('e93061ef-08a3-5298-93eb-db8cecb1e40b', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', 'a859a591-00a4-50bd-b086-95245abf0242', 'XL', '230 g', 'Fleisch-Mix', 1350, '{"kind":"is-mix"}'::jsonb, 8),
  ('d8d98f1c-60b8-56a3-a12f-37376fc0bfb3', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '6d9b982e-7a79-5829-bb4f-06946fc21f16', 'M', '160 g', 'Hähnchen', 950, '{"kind":"haehnchen"}'::jsonb, 0),
  ('22fc67c1-dae5-5c4a-8248-830de3f37654', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '6d9b982e-7a79-5829-bb4f-06946fc21f16', 'M', '160 g', 'Steak', 1250, '{"kind":"steak"}'::jsonb, 1),
  ('3125ce7c-0685-54c0-906d-5a5f1700e1f2', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '6d9b982e-7a79-5829-bb4f-06946fc21f16', 'M', '160 g', 'Fleisch-Mix', 1100, '{"kind":"is-mix"}'::jsonb, 2),
  ('54e0e21d-f6cd-5721-b0f8-900706ecb526', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '6d9b982e-7a79-5829-bb4f-06946fc21f16', 'L', '200 g', 'Hähnchen', 1150, '{"kind":"haehnchen"}'::jsonb, 3),
  ('139faf8f-f09b-5966-8616-51998d6f4f95', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '6d9b982e-7a79-5829-bb4f-06946fc21f16', 'L', '200 g', 'Steak', 1490, '{"kind":"steak"}'::jsonb, 4),
  ('81c1f231-4bf4-50e2-9aba-e6deca588c77', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '6d9b982e-7a79-5829-bb4f-06946fc21f16', 'L', '200 g', 'Fleisch-Mix', 1350, '{"kind":"is-mix"}'::jsonb, 5),
  ('2fd1f1ee-0076-5c50-af5d-b5a32c8e702d', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '6d9b982e-7a79-5829-bb4f-06946fc21f16', 'XL', '250 g', 'Hähnchen', 1300, '{"kind":"haehnchen"}'::jsonb, 6),
  ('36895cee-12a0-59c2-a31d-3dbd52de3b47', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '6d9b982e-7a79-5829-bb4f-06946fc21f16', 'XL', '250 g', 'Steak', 1690, '{"kind":"steak"}'::jsonb, 7),
  ('f75dbaa2-5b85-5734-8446-a6ae4947826b', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '6d9b982e-7a79-5829-bb4f-06946fc21f16', 'XL', '250 g', 'Fleisch-Mix', 1490, '{"kind":"is-mix"}'::jsonb, 8),
  ('53b34f8c-dc09-5782-8531-817d45cf6923', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '6eedc68e-2a42-5db5-a326-31e2b8dd9a47', null, null, 'Hähnchen', 790, '{"kind":"haehnchen"}'::jsonb, 0),
  ('0e309c37-8c05-5474-9728-5a41930c5ff6', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '6eedc68e-2a42-5db5-a326-31e2b8dd9a47', null, null, 'Steak', 1090, '{"kind":"steak"}'::jsonb, 1),
  ('0c6aa711-d510-51ce-ac3a-34fb6221d579', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '6eedc68e-2a42-5db5-a326-31e2b8dd9a47', null, null, 'Fleisch-Mix', 950, '{"kind":"is-mix"}'::jsonb, 2),
  ('c28b963b-9419-5ea8-95d9-e26ceb099d7e', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '8415c650-235e-59ba-9413-e354d6fc5da9', 'M', '200 g', 'Hähnchen', 1350, '{"kind":"haehnchen"}'::jsonb, 0),
  ('090aef19-d1b8-52a4-9d04-da646928e150', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '8415c650-235e-59ba-9413-e354d6fc5da9', 'M', '200 g', 'Steak', 1590, '{"kind":"steak"}'::jsonb, 1),
  ('ddc888f6-9963-5681-ab56-28faff8b0084', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '8415c650-235e-59ba-9413-e354d6fc5da9', 'M', '200 g', 'Fleisch-Mix', 1490, '{"kind":"is-mix"}'::jsonb, 2),
  ('c13b04e5-d37d-5010-bc92-01fb54b923cb', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '8415c650-235e-59ba-9413-e354d6fc5da9', 'L', '250 g', 'Hähnchen', 1550, '{"kind":"haehnchen"}'::jsonb, 3),
  ('62eae97a-9cf4-547a-bd2c-2b3b8e3615b0', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '8415c650-235e-59ba-9413-e354d6fc5da9', 'L', '250 g', 'Steak', 1890, '{"kind":"steak"}'::jsonb, 4),
  ('935807a9-6411-5688-a21f-35fa9940f17f', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '8415c650-235e-59ba-9413-e354d6fc5da9', 'L', '250 g', 'Fleisch-Mix', 1750, '{"kind":"is-mix"}'::jsonb, 5),
  ('11b6678c-01fd-5723-a831-6605b1e9e68d', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '2fb9e1eb-f696-5627-b81c-4410b888d98f', 'M', '180 g', 'Hähnchen', 1200, '{"kind":"haehnchen"}'::jsonb, 0),
  ('bfbbe755-3f7b-5230-b6a9-a0a6c25bd5fd', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '2fb9e1eb-f696-5627-b81c-4410b888d98f', 'M', '180 g', 'Steak', 1400, '{"kind":"steak"}'::jsonb, 1),
  ('550f1046-8263-5d9b-bbc9-6b7d7b442266', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '2fb9e1eb-f696-5627-b81c-4410b888d98f', 'M', '180 g', 'Fleisch-Mix', 1300, '{"kind":"is-mix"}'::jsonb, 2),
  ('f2c26f06-4ea1-5f9f-833a-bffd641f854c', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '2fb9e1eb-f696-5627-b81c-4410b888d98f', 'L', '220 g', 'Hähnchen', 1500, '{"kind":"haehnchen"}'::jsonb, 3),
  ('cbd588a2-913c-50b5-86e7-4af279781a64', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '2fb9e1eb-f696-5627-b81c-4410b888d98f', 'L', '220 g', 'Steak', 1700, '{"kind":"steak"}'::jsonb, 4),
  ('6ace9e63-09e3-5a75-a55b-87f0ec12d492', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '2fb9e1eb-f696-5627-b81c-4410b888d98f', 'L', '220 g', 'Fleisch-Mix', 1600, '{"kind":"is-mix"}'::jsonb, 5),
  ('e50a321a-0e90-5d7a-8351-3fe6019029ad', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '850113e9-5ba2-5188-b823-d6d641fd482b', null, null, 'Ohne Beilage', 450, '{"kind":"plain"}'::jsonb, 0),
  ('37700fbe-51ef-52c5-8702-f518e28096ae', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '850113e9-5ba2-5188-b823-d6d641fd482b', null, null, 'Mit Salat & Sauce', 790, '{"kind":"salad"}'::jsonb, 1),
  ('d5fc45d4-7ebc-5e37-876a-5cf73ea46a6e', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '850113e9-5ba2-5188-b823-d6d641fd482b', null, null, 'Mit Fleisch, Salat & Sauce', 1250, '{"kind":"steak"}'::jsonb, 2),
  ('6d24213d-d472-54ee-ae9a-8a7834d99d99', '4856ed4e-6573-5314-8bfb-4df2d2b7352c', '850113e9-5ba2-5188-b823-d6d641fd482b', null, null, 'Mit Fleisch-Mix, Salat & Sauce', 1400, '{"kind":"is-mix"}'::jsonb, 3)
on conflict do nothing;

insert into public.screen_categories (restaurant_id, screen_id, category_id, sort_order) values
  ('4856ed4e-6573-5314-8bfb-4df2d2b7352c', '022fc77c-d557-5d11-b2b8-62573b1b880c', '2e680cbb-b525-50d2-a593-bebe953cd5d2', 0),
  ('4856ed4e-6573-5314-8bfb-4df2d2b7352c', '022fc77c-d557-5d11-b2b8-62573b1b880c', '6d46b1f3-bbcb-58f9-ae6c-51abf80c83af', 1),
  ('4856ed4e-6573-5314-8bfb-4df2d2b7352c', '022fc77c-d557-5d11-b2b8-62573b1b880c', '03f4cc6e-049a-54b4-a37e-fd67361a7a9d', 2),
  ('4856ed4e-6573-5314-8bfb-4df2d2b7352c', '022fc77c-d557-5d11-b2b8-62573b1b880c', '67e67341-ddf6-5489-b720-87726d1c2f9a', 3),
  ('4856ed4e-6573-5314-8bfb-4df2d2b7352c', '022fc77c-d557-5d11-b2b8-62573b1b880c', 'c3884d2c-7374-5876-8b31-724ab568573b', 4),
  ('4856ed4e-6573-5314-8bfb-4df2d2b7352c', '022fc77c-d557-5d11-b2b8-62573b1b880c', '661e69d1-72e4-5b53-873b-7394c8db9abc', 5),
  ('4856ed4e-6573-5314-8bfb-4df2d2b7352c', '022fc77c-d557-5d11-b2b8-62573b1b880c', '5b301d34-f491-5e40-94a9-3abc0370dd55', 6),
  ('4856ed4e-6573-5314-8bfb-4df2d2b7352c', '0eb3fb57-f448-5e92-ba1a-ad054760f6a7', '3628ccb3-ec91-5e27-a7b9-7b6fb6f0a124', 0),
  ('4856ed4e-6573-5314-8bfb-4df2d2b7352c', '0eb3fb57-f448-5e92-ba1a-ad054760f6a7', '9c17df1f-c5c2-5f19-9465-58b669729ab2', 1),
  ('4856ed4e-6573-5314-8bfb-4df2d2b7352c', '0eb3fb57-f448-5e92-ba1a-ad054760f6a7', 'c2b9d422-9946-53d1-bb5c-754431247a63', 2),
  ('4856ed4e-6573-5314-8bfb-4df2d2b7352c', '0eb3fb57-f448-5e92-ba1a-ad054760f6a7', 'b2a085ec-2dd4-543e-a944-07b017f61937', 3),
  ('4856ed4e-6573-5314-8bfb-4df2d2b7352c', '0eb3fb57-f448-5e92-ba1a-ad054760f6a7', 'deacd335-b4d3-5218-b61d-f482b463424c', 4)
on conflict do nothing;

-- ---------- Akdeniz Kebap Marktkauf Stuhr ----------
insert into public.restaurants (id, slug, name, template_id, theme, settings, status) values
  ('4400212c-8599-5633-8f20-30b28f417192', 'akdeniz-stuhr', 'Akdeniz Kebap Marktkauf Stuhr',
   (select id from public.templates where key = 'doener-classic'),
   '{"logo_path":"4400212c-8599-5633-8f20-30b28f417192/legacy/logo.png","tagline":["Frisch","Hausgemacht","Einfach lecker"],"badge":"Einzigartiger Geschmack\nGARANTIERT!"}'::jsonb, '{"legend":{"title":"Kennzeichnung","additives":[{"n":"1","text":"Mit Konservierungsstoffen"},{"n":"2","text":"Chininhaltig"},{"n":"3","text":"Mit Phosphat"},{"n":"4","text":"Mit Antioxidationsmittel"},{"n":"5","text":"Geschwefelt"},{"n":"6","text":"Koffeinhaltig"},{"n":"7","text":"Mit Farbstoff"},{"n":"8","text":"Mit Süßungsmittel"},{"n":"9","text":"Mit Geschmacksverstärker"},{"n":"10","text":"Geschwärzt"},{"n":"11","text":"Stabilisatoren"},{"n":"12","text":"Mit Säuerungsmittel"}],"allergens":[{"n":"a","text":"Glutenhaltiges Getreide (Weizen)"},{"n":"b","text":"Krebstiere"},{"n":"c","text":"Eier"},{"n":"d","text":"Fisch"},{"n":"e","text":"Erdnüsse"},{"n":"f","text":"Milch und Laktose"},{"n":"g","text":"Schalenfrüchte (Nüsse)"},{"n":"h","text":"Lupine"},{"n":"i","text":"Weichtiere"},{"n":"j","text":"Sellerie"},{"n":"k","text":"Senf"},{"n":"l","text":"Sesamsamen"},{"n":"m","text":"Schwefeldioxid und Sulphite"},{"n":"n","text":"Soja"}]}}'::jsonb, 'active')
on conflict do nothing;

insert into public.menu_screens (id, restaurant_id, name, footer, settings, sort_order) values
  ('a809fcb9-8183-5293-badf-1767ba304894', '4400212c-8599-5633-8f20-30b28f417192', 'Seite 1', array['Alle Gerichte frisch zubereitet · Hähnchen, Steak oder Fleisch-Mix zur Wahl', 'Alle Preise in Euro, inkl. MwSt.']::text[], '{}'::jsonb, 0),
  ('36823403-3c95-54ab-9623-8ace744887c1', '4400212c-8599-5633-8f20-30b28f417192', 'Seite 2', array['Zusatzstoffe & Allergene – siehe Kennzeichnung unten.', 'Alle Preise in Euro, inkl. MwSt.']::text[], '{"show_legend":true}'::jsonb, 1)
on conflict do nothing;

insert into public.categories (id, restaurant_id, name, subtitle, note, title_image_path, image_path, display_style, settings, sort_order) values
  ('b97988ae-a109-5225-aaf1-3a7a1ca820b0', '4400212c-8599-5633-8f20-30b28f417192', 'Döner Pita', 'Knusprig. Saftig. Echt Akdeniz.', 'Immer eine
gute Wahl!', '4400212c-8599-5633-8f20-30b28f417192/legacy/doener-title.png', '4400212c-8599-5633-8f20-30b28f417192/legacy/doener-cut.png', 'matrix', '{"column_header":"Größe"}'::jsonb, 0),
  ('7cd911ac-a75c-55c2-863e-1f025e5eaba7', '4400212c-8599-5633-8f20-30b28f417192', 'Dürüm', 'Gerollt. Voller Geschmack.', 'Mehr Geschmack
zum Mitnehmen!', '4400212c-8599-5633-8f20-30b28f417192/legacy/dueruem-title.png', '4400212c-8599-5633-8f20-30b28f417192/legacy/dueruem-cut.png', 'matrix', '{"column_header":"Größe"}'::jsonb, 1),
  ('7b689ac0-4a57-54c3-bc46-163eaa804d1d', '4400212c-8599-5633-8f20-30b28f417192', 'Box', 'Praktisch. Zum Löffeln.', 'Perfekt für
zwischendurch!', '4400212c-8599-5633-8f20-30b28f417192/legacy/box-title.png', '4400212c-8599-5633-8f20-30b28f417192/legacy/box-cut.png', 'tiles', '{"portion":"Nur Größe M · 130 g"}'::jsonb, 2),
  ('ffc9e49e-af76-5265-8c9f-d65e9a632aa9', '4400212c-8599-5633-8f20-30b28f417192', 'Teller', 'Angerichtet. Richtig satt.', 'Genuss auf
dem Teller!', '4400212c-8599-5633-8f20-30b28f417192/legacy/teller-title.png', '4400212c-8599-5633-8f20-30b28f417192/legacy/teller-cut.png', 'matrix', '{"column_header":"Größe"}'::jsonb, 3),
  ('4d76ff88-a4b1-5880-bd3d-895c7a2832ca', '4400212c-8599-5633-8f20-30b28f417192', 'Mach''s zum Menü', 'Unser Spar-Tipp für Döner Pita und Dürüm zum Menü erweitern.', null, null, null, 'offers', '{}'::jsonb, 4),
  ('2a40d5de-dc3d-5cb8-aa09-458cff6041bd', '4400212c-8599-5633-8f20-30b28f417192', 'Vegetarisch', 'Ohne Fleisch für Unsere Vegetarischen Freunde', null, null, null, 'list', '{}'::jsonb, 5),
  ('e6ddf8e6-bb67-5cba-be7c-8be6bc0210e1', '4400212c-8599-5633-8f20-30b28f417192', 'Türkische Pizza', 'Lahmacun', null, null, null, 'gallery', '{}'::jsonb, 6),
  ('05223c87-06da-5cf6-be4f-3957fe91d5f7', '4400212c-8599-5633-8f20-30b28f417192', 'Falafel & Halloumi', null, null, null, null, 'list', '{}'::jsonb, 7),
  ('3282ae15-5e8a-50de-866d-ebd1402ac051', '4400212c-8599-5633-8f20-30b28f417192', 'Extras & Beilagen', 'Für den Extra Hunger', null, null, null, 'list', '{}'::jsonb, 8),
  ('eafbfd5a-d45d-5979-a61c-7e9a890a7297', '4400212c-8599-5633-8f20-30b28f417192', 'Getränke', 'Eiskalt serviert', null, null, null, 'list', '{}'::jsonb, 9)
on conflict do nothing;

insert into public.products (id, restaurant_id, category_id, name, price_cents, image_path, settings, sort_order) values
  ('e425ffc3-cf67-508f-83dd-ad9495553925', '4400212c-8599-5633-8f20-30b28f417192', 'b97988ae-a109-5225-aaf1-3a7a1ca820b0', 'Döner Pita', null, null, '{}'::jsonb, 0),
  ('a7685c35-3150-5df3-b4d2-b4c2e2c638ed', '4400212c-8599-5633-8f20-30b28f417192', '7cd911ac-a75c-55c2-863e-1f025e5eaba7', 'Dürüm', null, null, '{}'::jsonb, 0),
  ('2a046f2e-a9e2-5e78-94db-ea8d47f65949', '4400212c-8599-5633-8f20-30b28f417192', '7b689ac0-4a57-54c3-bc46-163eaa804d1d', 'Box', null, null, '{}'::jsonb, 0),
  ('972d4900-8b60-56a5-b162-13cc5968403e', '4400212c-8599-5633-8f20-30b28f417192', 'ffc9e49e-af76-5265-8c9f-d65e9a632aa9', 'Teller', null, null, '{}'::jsonb, 0),
  ('be73efd8-803e-5a62-b6dc-930c232f7404', '4400212c-8599-5633-8f20-30b28f417192', '4d76ff88-a4b1-5880-bd3d-895c7a2832ca', 'Pommes & Softdrink 0,33 l', 550, null, '{"icon":"cola","price_prefix":"+"}'::jsonb, 0),
  ('cb3205c2-63c2-5264-a3d9-91c2ed89edbb', '4400212c-8599-5633-8f20-30b28f417192', '4d76ff88-a4b1-5880-bd3d-895c7a2832ca', 'Pommes & Wasser / Ayran', 490, null, '{"icon":"ayran","price_prefix":"+"}'::jsonb, 1),
  ('47e6ac94-b8e0-581c-8a48-3bc2fe7242b2', '4400212c-8599-5633-8f20-30b28f417192', '2a40d5de-dc3d-5cb8-aa09-458cff6041bd', 'Veggie Pita', 690, null, '{}'::jsonb, 0),
  ('8e51931c-e4d9-5f9f-b119-c2c7ed875172', '4400212c-8599-5633-8f20-30b28f417192', '2a40d5de-dc3d-5cb8-aa09-458cff6041bd', 'Dürüm Vegetarisch', 790, null, '{}'::jsonb, 1),
  ('b45ef500-6f4c-5aeb-87b1-7b1e9a78e883', '4400212c-8599-5633-8f20-30b28f417192', 'e6ddf8e6-bb67-5cba-be7c-8be6bc0210e1', 'Ohne Beilage', 450, null, '{}'::jsonb, 0),
  ('6f3d36af-ecc7-5d53-be98-e37e66eceda8', '4400212c-8599-5633-8f20-30b28f417192', 'e6ddf8e6-bb67-5cba-be7c-8be6bc0210e1', 'Mit Salat & Sauce', 790, null, '{}'::jsonb, 1),
  ('2779bb7d-b609-5a88-a4aa-dca7b42d4e99', '4400212c-8599-5633-8f20-30b28f417192', 'e6ddf8e6-bb67-5cba-be7c-8be6bc0210e1', 'Mit Fleisch, Salat & Sauce', 1250, null, '{}'::jsonb, 2),
  ('5d8537f9-da96-52d2-b37f-9d856b25a929', '4400212c-8599-5633-8f20-30b28f417192', 'e6ddf8e6-bb67-5cba-be7c-8be6bc0210e1', 'Mit Fleisch-Mix, Salat & Sauce', 1400, null, '{}'::jsonb, 3),
  ('1406652d-375e-576e-94c9-945bba372e4e', '4400212c-8599-5633-8f20-30b28f417192', '05223c87-06da-5cf6-be4f-3957fe91d5f7', 'Falafel o. Halloumi Pita', 790, null, '{}'::jsonb, 0),
  ('c1c120d5-66ef-5800-87f9-1880ec54a444', '4400212c-8599-5633-8f20-30b28f417192', '05223c87-06da-5cf6-be4f-3957fe91d5f7', 'Dürüm Falafel o. Halloumi', 890, null, '{}'::jsonb, 1),
  ('9a9fc0f1-0195-5a1c-b13b-49ac59d7f377', '4400212c-8599-5633-8f20-30b28f417192', '05223c87-06da-5cf6-be4f-3957fe91d5f7', 'Falafel o. Halloumi Box', 890, null, '{}'::jsonb, 2),
  ('8e9f38c9-2cef-573e-b61c-7aac24749eb0', '4400212c-8599-5633-8f20-30b28f417192', '05223c87-06da-5cf6-be4f-3957fe91d5f7', 'Falafel o. Halloumi Teller', 1190, null, '{}'::jsonb, 3),
  ('3e499365-6461-5e6b-824f-63f93c33776e', '4400212c-8599-5633-8f20-30b28f417192', '3282ae15-5e8a-50de-866d-ebd1402ac051', 'Pommes', 350, null, '{}'::jsonb, 0),
  ('6c385988-d76e-5634-837e-f6024dfc1d57', '4400212c-8599-5633-8f20-30b28f417192', '3282ae15-5e8a-50de-866d-ebd1402ac051', 'Reis', 350, null, '{}'::jsonb, 1),
  ('436bdb74-76c4-5084-be7a-702aa44d08cf', '4400212c-8599-5633-8f20-30b28f417192', '3282ae15-5e8a-50de-866d-ebd1402ac051', 'Sauce (Extra)', 200, null, '{}'::jsonb, 2),
  ('bbb10d65-81e2-5596-8e49-4daee7a361b8', '4400212c-8599-5633-8f20-30b28f417192', '3282ae15-5e8a-50de-866d-ebd1402ac051', 'Ketchup / Mayo', 50, null, '{}'::jsonb, 3),
  ('a1d7c60d-0b42-58ad-9c41-8c41dbcf671d', '4400212c-8599-5633-8f20-30b28f417192', '3282ae15-5e8a-50de-866d-ebd1402ac051', 'Brot', 100, null, '{}'::jsonb, 4),
  ('807b93f9-f3f3-5ff8-8508-6948c00fbdad', '4400212c-8599-5633-8f20-30b28f417192', 'eafbfd5a-d45d-5979-a61c-7e9a890a7297', 'Softdrink 0,33 l', 350, null, '{}'::jsonb, 0),
  ('b2fbf4fa-4793-514e-bad9-97598fa2abce', '4400212c-8599-5633-8f20-30b28f417192', 'eafbfd5a-d45d-5979-a61c-7e9a890a7297', 'Wasser 0,5 l', 250, null, '{}'::jsonb, 1),
  ('40655384-2720-5a52-8e7f-22f34878a759', '4400212c-8599-5633-8f20-30b28f417192', 'eafbfd5a-d45d-5979-a61c-7e9a890a7297', 'Ayran 0,25 l', 250, null, '{}'::jsonb, 2)
on conflict do nothing;

insert into public.product_variants (id, restaurant_id, product_id, size_label, size_note, option_label, price_cents, settings, sort_order) values
  ('33e11d9b-9a1e-5508-87f9-810db6b1de85', '4400212c-8599-5633-8f20-30b28f417192', 'e425ffc3-cf67-508f-83dd-ad9495553925', 'M', '130 g', 'Hähnchen', 790, '{"kind":"haehnchen"}'::jsonb, 0),
  ('5862ecba-f3e3-559f-9e47-ea1e5da4c148', '4400212c-8599-5633-8f20-30b28f417192', 'e425ffc3-cf67-508f-83dd-ad9495553925', 'M', '130 g', 'Steak', 1090, '{"kind":"steak"}'::jsonb, 1),
  ('eb2ce6d5-e0bd-545b-9051-afdb4e651c0e', '4400212c-8599-5633-8f20-30b28f417192', 'e425ffc3-cf67-508f-83dd-ad9495553925', 'M', '130 g', 'Fleisch-Mix', 950, '{"kind":"is-mix"}'::jsonb, 2),
  ('b56ffc4c-55c3-517e-9f03-89cc561c391c', '4400212c-8599-5633-8f20-30b28f417192', 'e425ffc3-cf67-508f-83dd-ad9495553925', 'L', '180 g', 'Hähnchen', 990, '{"kind":"haehnchen"}'::jsonb, 3),
  ('df3b6fee-e376-55fb-88c3-c21fd803bb11', '4400212c-8599-5633-8f20-30b28f417192', 'e425ffc3-cf67-508f-83dd-ad9495553925', 'L', '180 g', 'Steak', 1350, '{"kind":"steak"}'::jsonb, 4),
  ('8e040f93-8a81-58bd-ac80-0124b8740215', '4400212c-8599-5633-8f20-30b28f417192', 'e425ffc3-cf67-508f-83dd-ad9495553925', 'L', '180 g', 'Fleisch-Mix', 1190, '{"kind":"is-mix"}'::jsonb, 5),
  ('50c86c3d-26c1-5789-8372-6db2d187d0a8', '4400212c-8599-5633-8f20-30b28f417192', 'e425ffc3-cf67-508f-83dd-ad9495553925', 'XL', '230 g', 'Hähnchen', 1150, '{"kind":"haehnchen"}'::jsonb, 6),
  ('889e2afd-da40-5b91-a4fd-9c0235e48a92', '4400212c-8599-5633-8f20-30b28f417192', 'e425ffc3-cf67-508f-83dd-ad9495553925', 'XL', '230 g', 'Steak', 1550, '{"kind":"steak"}'::jsonb, 7),
  ('8e77691a-95b4-551c-abf1-0af8c7bd77e8', '4400212c-8599-5633-8f20-30b28f417192', 'e425ffc3-cf67-508f-83dd-ad9495553925', 'XL', '230 g', 'Fleisch-Mix', 1350, '{"kind":"is-mix"}'::jsonb, 8),
  ('22d624eb-e916-5a62-af8c-e3b524d3e5be', '4400212c-8599-5633-8f20-30b28f417192', 'a7685c35-3150-5df3-b4d2-b4c2e2c638ed', 'M', '160 g', 'Hähnchen', 950, '{"kind":"haehnchen"}'::jsonb, 0),
  ('5a7a3e84-1b12-546e-b593-438da7cf6200', '4400212c-8599-5633-8f20-30b28f417192', 'a7685c35-3150-5df3-b4d2-b4c2e2c638ed', 'M', '160 g', 'Steak', 1250, '{"kind":"steak"}'::jsonb, 1),
  ('91794df2-515d-5576-a50d-76fe4c7f138b', '4400212c-8599-5633-8f20-30b28f417192', 'a7685c35-3150-5df3-b4d2-b4c2e2c638ed', 'M', '160 g', 'Fleisch-Mix', 1100, '{"kind":"is-mix"}'::jsonb, 2),
  ('e1efd29e-d0f0-5b5c-84bb-7351e2a1587e', '4400212c-8599-5633-8f20-30b28f417192', 'a7685c35-3150-5df3-b4d2-b4c2e2c638ed', 'L', '200 g', 'Hähnchen', 1150, '{"kind":"haehnchen"}'::jsonb, 3),
  ('cbb50ba0-69be-5a3d-a26c-0e132435df74', '4400212c-8599-5633-8f20-30b28f417192', 'a7685c35-3150-5df3-b4d2-b4c2e2c638ed', 'L', '200 g', 'Steak', 1490, '{"kind":"steak"}'::jsonb, 4),
  ('2bd34de6-0360-55f7-a1f3-22780ddfc632', '4400212c-8599-5633-8f20-30b28f417192', 'a7685c35-3150-5df3-b4d2-b4c2e2c638ed', 'L', '200 g', 'Fleisch-Mix', 1350, '{"kind":"is-mix"}'::jsonb, 5),
  ('752979e4-98c2-5e30-85c6-72874bcee17c', '4400212c-8599-5633-8f20-30b28f417192', 'a7685c35-3150-5df3-b4d2-b4c2e2c638ed', 'XL', '250 g', 'Hähnchen', 1300, '{"kind":"haehnchen"}'::jsonb, 6),
  ('16f65d4d-8fbd-53b0-950f-78d788e88915', '4400212c-8599-5633-8f20-30b28f417192', 'a7685c35-3150-5df3-b4d2-b4c2e2c638ed', 'XL', '250 g', 'Steak', 1690, '{"kind":"steak"}'::jsonb, 7),
  ('ea571424-6c83-501a-9cb9-ea8cebcb0ab2', '4400212c-8599-5633-8f20-30b28f417192', 'a7685c35-3150-5df3-b4d2-b4c2e2c638ed', 'XL', '250 g', 'Fleisch-Mix', 1490, '{"kind":"is-mix"}'::jsonb, 8),
  ('91564054-7fc1-54ab-a7a6-7341d4546614', '4400212c-8599-5633-8f20-30b28f417192', '2a046f2e-a9e2-5e78-94db-ea8d47f65949', null, null, 'Hähnchen', 790, '{"kind":"haehnchen"}'::jsonb, 0),
  ('8f506365-69ad-56a9-9c61-2b04297ca0b1', '4400212c-8599-5633-8f20-30b28f417192', '2a046f2e-a9e2-5e78-94db-ea8d47f65949', null, null, 'Steak', 1090, '{"kind":"steak"}'::jsonb, 1),
  ('b769a015-92db-5e2d-a14f-5a075ce49a51', '4400212c-8599-5633-8f20-30b28f417192', '2a046f2e-a9e2-5e78-94db-ea8d47f65949', null, null, 'Fleisch-Mix', 950, '{"kind":"is-mix"}'::jsonb, 2),
  ('a587bcc6-c8b9-5d8f-ab4d-2b0133c4baff', '4400212c-8599-5633-8f20-30b28f417192', '972d4900-8b60-56a5-b162-13cc5968403e', 'M', '200 g', 'Hähnchen', 1350, '{"kind":"haehnchen"}'::jsonb, 0),
  ('dbf173ea-8f38-514e-a534-d1bf69c1ab11', '4400212c-8599-5633-8f20-30b28f417192', '972d4900-8b60-56a5-b162-13cc5968403e', 'M', '200 g', 'Steak', 1590, '{"kind":"steak"}'::jsonb, 1),
  ('ff2966e2-69c2-5161-92f9-25b22c26ae9c', '4400212c-8599-5633-8f20-30b28f417192', '972d4900-8b60-56a5-b162-13cc5968403e', 'M', '200 g', 'Fleisch-Mix', 1490, '{"kind":"is-mix"}'::jsonb, 2),
  ('2a860872-48a8-5dfd-8b39-d023a41742ad', '4400212c-8599-5633-8f20-30b28f417192', '972d4900-8b60-56a5-b162-13cc5968403e', 'L', '250 g', 'Hähnchen', 1550, '{"kind":"haehnchen"}'::jsonb, 3),
  ('9501b0c4-fddd-50ef-9bf5-64092ddb280f', '4400212c-8599-5633-8f20-30b28f417192', '972d4900-8b60-56a5-b162-13cc5968403e', 'L', '250 g', 'Steak', 1890, '{"kind":"steak"}'::jsonb, 4),
  ('370aa714-d901-50da-89fc-495e1ceca58a', '4400212c-8599-5633-8f20-30b28f417192', '972d4900-8b60-56a5-b162-13cc5968403e', 'L', '250 g', 'Fleisch-Mix', 1750, '{"kind":"is-mix"}'::jsonb, 5)
on conflict do nothing;

insert into public.screen_categories (restaurant_id, screen_id, category_id, sort_order) values
  ('4400212c-8599-5633-8f20-30b28f417192', 'a809fcb9-8183-5293-badf-1767ba304894', 'b97988ae-a109-5225-aaf1-3a7a1ca820b0', 0),
  ('4400212c-8599-5633-8f20-30b28f417192', 'a809fcb9-8183-5293-badf-1767ba304894', '7cd911ac-a75c-55c2-863e-1f025e5eaba7', 1),
  ('4400212c-8599-5633-8f20-30b28f417192', 'a809fcb9-8183-5293-badf-1767ba304894', '7b689ac0-4a57-54c3-bc46-163eaa804d1d', 2),
  ('4400212c-8599-5633-8f20-30b28f417192', 'a809fcb9-8183-5293-badf-1767ba304894', 'ffc9e49e-af76-5265-8c9f-d65e9a632aa9', 3),
  ('4400212c-8599-5633-8f20-30b28f417192', 'a809fcb9-8183-5293-badf-1767ba304894', '4d76ff88-a4b1-5880-bd3d-895c7a2832ca', 4),
  ('4400212c-8599-5633-8f20-30b28f417192', '36823403-3c95-54ab-9623-8ace744887c1', '2a40d5de-dc3d-5cb8-aa09-458cff6041bd', 0),
  ('4400212c-8599-5633-8f20-30b28f417192', '36823403-3c95-54ab-9623-8ace744887c1', 'e6ddf8e6-bb67-5cba-be7c-8be6bc0210e1', 1),
  ('4400212c-8599-5633-8f20-30b28f417192', '36823403-3c95-54ab-9623-8ace744887c1', '05223c87-06da-5cf6-be4f-3957fe91d5f7', 2),
  ('4400212c-8599-5633-8f20-30b28f417192', '36823403-3c95-54ab-9623-8ace744887c1', '3282ae15-5e8a-50de-866d-ebd1402ac051', 3),
  ('4400212c-8599-5633-8f20-30b28f417192', '36823403-3c95-54ab-9623-8ace744887c1', 'eafbfd5a-d45d-5979-a61c-7e9a890a7297', 4)
on conflict do nothing;

commit;
