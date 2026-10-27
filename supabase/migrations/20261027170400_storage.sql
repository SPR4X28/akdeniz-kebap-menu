-- ================================================================
-- Bilder im Supabase Storage (Region Frankfurt)
-- Bucket "menu-images", ein Ordner pro Restaurant:
--   menu-images/<restaurant_id>/…
-- Lesen ist öffentlich (Menüs sind öffentlich, Displays haben kein
-- Konto). Hochladen, Ersetzen und Löschen nur im eigenen Ordner.
-- ================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('menu-images', 'menu-images', true, 5 * 1024 * 1024,
        array['image/png', 'image/jpeg', 'image/webp', 'image/svg+xml'])
on conflict (id) do nothing;

create or replace function private.folder_restaurant_id(object_name text)
returns uuid language plpgsql immutable set search_path = '' as $$
begin
  return split_part(object_name, '/', 1)::uuid;
exception when invalid_text_representation then
  return null;
end $$;

grant execute on function private.folder_restaurant_id(text) to authenticated;

create policy "Mitglieder sehen Bilder ihres Restaurants" on storage.objects
  for select to authenticated
  using (bucket_id = 'menu-images' and (select private.is_member(private.folder_restaurant_id(name))));

create policy "Mitglieder laden Bilder in ihren Ordner" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'menu-images' and (select private.can_edit(private.folder_restaurant_id(name))));

create policy "Mitglieder ersetzen Bilder in ihrem Ordner" on storage.objects
  for update to authenticated
  using (bucket_id = 'menu-images' and (select private.can_edit(private.folder_restaurant_id(name))))
  with check (bucket_id = 'menu-images' and (select private.can_edit(private.folder_restaurant_id(name))));

create policy "Mitglieder löschen Bilder in ihrem Ordner" on storage.objects
  for delete to authenticated
  using (bucket_id = 'menu-images' and (select private.can_edit(private.folder_restaurant_id(name))));
