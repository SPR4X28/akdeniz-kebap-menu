-- ================================================================
-- Die drei Design-Templates. Code liegt später im Frontend unter
-- templates/<key>/. Nur fertig gebaute Templates sind is_active.
-- ================================================================

insert into public.templates (key, name, description, orientations, settings_schema, is_active, sort_order)
values
  ('doener-classic', 'Döner Classic',
   'Helles Kreide-/Papier-Design mit Produktfotos, Preis-Matrix und Handschrift-Notizen (aktuelles Akdeniz-Design).',
   '{landscape,portrait}',
   '{
      "logo_path":  {"type": "image",  "label": "Logo"},
      "tagline":    {"type": "list",   "label": "Tagline (Wörter)"},
      "badge":      {"type": "text",   "label": "Badge-Text"},
      "primary":    {"type": "color",  "label": "Primärfarbe", "default": "#c62418"},
      "accent":     {"type": "color",  "label": "Akzentfarbe", "default": "#5c8b3c"}
    }', true, 1),
  ('street-dark', 'Street Dark',
   'Dunkler Hintergrund mit kräftigen Farben, gut lesbar aus der Entfernung.',
   '{landscape,portrait}',
   '{
      "logo_path":  {"type": "image",  "label": "Logo"},
      "primary":    {"type": "color",  "label": "Primärfarbe", "default": "#ffb400"},
      "background": {"type": "image",  "label": "Hintergrundbild"}
    }', false, 2),
  ('fresh-light', 'Fresh Light',
   'Reduziertes, helles Listen-Design, viele Artikel auf einem Bildschirm.',
   '{landscape,portrait}',
   '{
      "logo_path":  {"type": "image",  "label": "Logo"},
      "primary":    {"type": "color",  "label": "Primärfarbe", "default": "#2e7d32"}
    }', false, 3)
on conflict (key) do nothing;
