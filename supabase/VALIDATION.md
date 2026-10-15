# Étape 1 — Validation

Résultats des vérifications effectuées sur le projet Supabase
`iyfopbkhfhpziapvqika` (management-dashboard), le 2026-10-15.

## Tables & RLS

| Table | RLS activé | Policies |
| --- | --- | --- |
| users | oui | 2 (select all, update own) |
| tasks | oui | 5 (select, insert, update, admin update, delete) |
| task_dependencies | oui | 3 (select, insert, delete) |
| time_logs | oui | 3 (select, insert, delete) |

**13 policies** au total, RLS activé sur les 4 tables.

## Index créés (8)

`users_email_idx`, `tasks_assigned_to_idx`, `tasks_status_idx`,
`tasks_deadline_idx`, `task_dependencies_task_id_idx`,
`task_dependencies_depends_on_idx`, `time_logs_task_id_idx`,
`time_logs_user_id_idx`.

## Données de test

- 3 utilisateurs : Alice Admin (admin), Bob Contrib, Carla Contrib
- 2 tâches : « Mettre en place le CI » (assignée à Bob, in_progress, high),
  « Rédiger la doc API » (non assignée, todo)
- 1 dépendance : doc API dépend de « Mettre en place le CI »
- 1 log de temps : 2.5 h de Bob sur la tâche CI

## Test fonctionnel RLS

Réalisé en simulant le rôle Postgres et un JWT (`request.jwt.claims`) :

| Test | Attendu | Obtenu |
| --- | --- | --- |
| role `anon` lit tasks | 0 ligne | 0 ✓ |
| role `authenticated` (Bob) lit tasks | 2 lignes | 2 ✓ |
| Bob met à jour SA tâche | 1 ligne | 1 ✓ |
| Bob met à jour une tâche ni assignée ni créée par lui | 0 ligne | 0 ✓ |
| Bob crée une tâche avec `created_by` = Alice (usurpation) | rejet | erreur RLS ✓ |

RLS fonctionne : cloisonnement des écritures, lecture globale pour les
utilisateurs authentifiés, refus pour les anonymes.
