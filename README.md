# management-dashboard

Dashboard de gestion de tâches d'équipe — **Étape 1 : infrastructure et base de données Supabase**.

## Contenu

| Fichier | Rôle |
| --- | --- |
| `supabase/01_schema.sql` | 4 tables (`users`, `tasks`, `task_dependencies`, `time_logs`), clés étrangères, index, contraintes, triggers `updated_at` |
| `supabase/02_rls.sql` | Row Level Security + policies sur les 4 tables |
| `supabase/03_seed_test.sql` | Données de test (3 utilisateurs, 2 tâches, 1 dépendance, 1 log de temps) |

## Ordre d'exécution

Dans le **SQL Editor** du projet Supabase, exécuter les scripts dans l'ordre :

1. `01_schema.sql`
2. `02_rls.sql`
3. `03_seed_test.sql` (optionnel, pour tester)

> Le fichier `.secrets.env` (mot de passe DB, project ref) n'est **pas** versionné.

## Schéma

```
users ──< tasks (created_by)
      ──< tasks (assigned_to)
tasks ──< task_dependencies (task_id, depends_on)
tasks ──< time_logs (task_id)
users ──< time_logs (user_id)
```

### users
`id` (uuid, pk) · `email` (text, unique) · `name` · `role` (`admin`|`contributor`) · `created_at` · `updated_at`

### tasks
`id` · `title` · `description` · `created_by` → users · `assigned_to` → users (nullable) ·
`status` (`todo`|`in_progress`|`done`) · `deadline` · `estimated_hours` · `actual_hours` ·
`priority` (`low`|`medium`|`high`) · `created_at` · `updated_at`

### task_dependencies
`id` · `task_id` → tasks (cascade) · `depends_on` → tasks (cascade) · `created_at`
— `UNIQUE(task_id, depends_on)`, pas d'auto-dépendance.

### time_logs
`id` · `task_id` → tasks (cascade) · `user_id` → users · `hours_logged` (numeric) · `logged_at`

## Sécurité (RLS)

- **users** : SELECT pour tout utilisateur authentifié ; UPDATE de son propre profil.
- **tasks** : SELECT pour tous ; INSERT ; UPDATE si `assigned_to` ou `created_by` = utilisateur, ou si admin ; DELETE si créateur ou admin.
- **task_dependencies** : lecture/écriture pour tout utilisateur authentifié.
- **time_logs** : lecture pour tous ; INSERT de ses propres logs ; DELETE de ses logs ou en admin.
