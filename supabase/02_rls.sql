-- Étape 1 — Row Level Security (RLS)
-- À exécuter APRÈS 01_schema.sql.
-- Postgres exécute les policies en OR : la policy admin (UPDATE) permet
-- à un admin de modifier n'importe quelle tâche, en plus des policies
-- sur created_by / assigned_to.

alter table public.users enable row level security;
alter table public.tasks enable row level security;
alter table public.task_dependencies enable row level security;
alter table public.time_logs enable row level security;

-- ---------------------------------------------------------------------------
-- users
-- ---------------------------------------------------------------------------
create policy "users can read all users"
  on public.users for select
  to authenticated
  using (true);

create policy "users can update their own profile"
  on public.users for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- ---------------------------------------------------------------------------
-- tasks
-- ---------------------------------------------------------------------------
create policy "users can read all tasks"
  on public.tasks for select
  to authenticated
  using (true);

create policy "users can create tasks"
  on public.tasks for insert
  to authenticated
  with check (created_by = auth.uid());

create policy "users can update their assigned tasks"
  on public.tasks for update
  to authenticated
  using (auth.uid() = assigned_to OR created_by = auth.uid())
  with check (auth.uid() = assigned_to OR created_by = auth.uid());

create policy "admin can update any task"
  on public.tasks for update
  to authenticated
  using (
    exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role = 'admin'
    )
  );

create policy "users can delete their own tasks"
  on public.tasks for delete
  to authenticated
  using (
    created_by = auth.uid()
    or exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role = 'admin'
    )
  );

-- ---------------------------------------------------------------------------
-- task_dependencies
-- ---------------------------------------------------------------------------
create policy "authenticated users can read task_dependencies"
  on public.task_dependencies for select
  to authenticated
  using (true);

create policy "authenticated users can write task_dependencies"
  on public.task_dependencies for insert
  to authenticated
  with check (true);

create policy "authenticated users can delete task_dependencies"
  on public.task_dependencies for delete
  to authenticated
  using (true);

-- ---------------------------------------------------------------------------
-- time_logs
-- ---------------------------------------------------------------------------
create policy "authenticated users can read time_logs"
  on public.time_logs for select
  to authenticated
  using (true);

create policy "authenticated users can insert time_logs"
  on public.time_logs for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "authenticated users can delete time_logs"
  on public.time_logs for delete
  to authenticated
  using (
    user_id = auth.uid()
    or exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.role = 'admin'
    )
  );
