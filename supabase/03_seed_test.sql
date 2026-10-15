-- Étape 1 — Données de test
-- À exécuter APRÈS 01_schema.sql.
-- Ces inserts sont faits en SQL (service_role / SQL Editor) : ils passent
-- les policies RLS, qui s'appliquent aux requêtes des utilisateurs.

insert into public.users (id, email, name, role) values
  ('11111111-1111-1111-1111-111111111111', 'admin@test.local', 'Alice Admin', 'admin'),
  ('22222222-2222-2222-2222-222222222222', 'bob@test.local', 'Bob Contrib', 'contributor'),
  ('33333333-3333-3333-3333-333333333333', 'carla@test.local', 'Carla Contrib', 'contributor')
on conflict (id) do nothing;

insert into public.tasks (id, title, description, created_by, assigned_to, status, deadline, estimated_hours, priority) values
  ('aaaaaaaa-0000-0000-0000-000000000001', 'Mettre en place le CI', 'Configurer la pipeline CI/CD',
   '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222',
   'in_progress', now() + interval '7 days', 8, 'high'),
  ('aaaaaaaa-0000-0000-0000-000000000002', 'Rédiger la doc API', null,
   '11111111-1111-1111-1111-111111111111', null,
   'todo', null, 4, 'medium')
on conflict (id) do nothing;

insert into public.task_dependencies (task_id, depends_on) values
  ('aaaaaaaa-0000-0000-0000-000000000002', 'aaaaaaaa-0000-0000-0000-000000000001')
on conflict do nothing;

insert into public.time_logs (task_id, user_id, hours_logged) values
  ('aaaaaaaa-0000-0000-0000-000000000001', '22222222-2222-2222-2222-222222222222', 2.5);
