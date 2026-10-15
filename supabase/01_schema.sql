-- Étape 1 — Schéma du dashboard de gestion de tâches d'équipe
-- Tables, foreign keys, index et contraintes.

-- ---------------------------------------------------------------------------
-- Table users
-- ---------------------------------------------------------------------------
create table public.users (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  name text not null,
  role text not null default 'contributor',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint users_role_check check (role in ('admin', 'contributor'))
);

create index users_email_idx on public.users (email);

-- ---------------------------------------------------------------------------
-- Table tasks
-- ---------------------------------------------------------------------------
create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  created_by uuid not null references public.users (id),
  assigned_to uuid references public.users (id),
  status text not null default 'todo',
  deadline timestamptz,
  estimated_hours integer,
  actual_hours integer not null default 0,
  priority text not null default 'medium',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint tasks_status_check check (status in ('todo', 'in_progress', 'done')),
  constraint tasks_priority_check check (priority in ('low', 'medium', 'high'))
);

create index tasks_assigned_to_idx on public.tasks (assigned_to);
create index tasks_status_idx on public.tasks (status);
create index tasks_deadline_idx on public.tasks (deadline);

-- ---------------------------------------------------------------------------
-- Table task_dependencies
-- ---------------------------------------------------------------------------
create table public.task_dependencies (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references public.tasks (id) on delete cascade,
  depends_on uuid not null references public.tasks (id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint task_dependencies_unique unique (task_id, depends_on),
  constraint task_dependencies_no_self check (task_id <> depends_on)
);

create index task_dependencies_task_id_idx on public.task_dependencies (task_id);
create index task_dependencies_depends_on_idx on public.task_dependencies (depends_on);

-- ---------------------------------------------------------------------------
-- Table time_logs
-- ---------------------------------------------------------------------------
create table public.time_logs (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references public.tasks (id) on delete cascade,
  user_id uuid not null references public.users (id),
  hours_logged numeric not null check (hours_logged > 0),
  logged_at timestamptz not null default now()
);

create index time_logs_task_id_idx on public.time_logs (task_id);
create index time_logs_user_id_idx on public.time_logs (user_id);

-- ---------------------------------------------------------------------------
-- Trigger updated_at : maintient updated_at à jour automatiquement
-- ---------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger users_updated_at
  before update on public.users
  for each row execute function public.set_updated_at();

create trigger tasks_updated_at
  before update on public.tasks
  for each row execute function public.set_updated_at();
