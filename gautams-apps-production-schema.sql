-- Gautam's Apps production schema
-- Project ID: pmyqsieamfohrywdpora
--
-- This replaces the original single-row JSON sync with table-backed records.
-- Run this in the Supabase SQL Editor before using "Push now" from the app.

create table if not exists public.app_settings (
  key text primary key,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.app_users (
  id text primary key,
  name text not null,
  email text not null,
  role text not null default 'viewer',
  orgs text[] not null default '{}',
  data jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.initiatives (
  id text primary key,
  name text not null,
  org text not null,
  owner text,
  url text,
  status text,
  hourly_rate numeric,
  budget numeric,
  priority integer,
  planned_share numeric,
  allowed_viewers text[] not null default '{}',
  data jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.time_entries (
  id text primary key,
  project_id text not null references public.initiatives(id) on delete cascade,
  work_date date not null,
  hours numeric not null,
  hourly_rate numeric not null,
  contributor text,
  notes text,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.expense_documents (
  id text primary key,
  expense_id text,
  file_name text not null,
  mime_type text,
  byte_size integer,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.expenses (
  id text primary key,
  project_id text not null references public.initiatives(id) on delete cascade,
  spend_date date not null,
  vendor text not null,
  amount numeric not null,
  category text,
  payment_source text,
  document_type text,
  reference text,
  receipt text,
  purpose text,
  approval_status text,
  document_id text,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.expense_documents
  drop constraint if exists expense_documents_expense_id_fkey;

alter table public.expense_documents
  add constraint expense_documents_expense_id_fkey
  foreign key (expense_id) references public.expenses(id) on delete cascade;

create table if not exists public.income_entries (
  id text primary key,
  project_id text not null references public.initiatives(id) on delete cascade,
  invoice_date date not null,
  due_date date,
  invoice_number text,
  customer text not null,
  plan text,
  amount numeric not null,
  status text,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.fund_entries (
  id text primary key,
  project_id text not null references public.initiatives(id) on delete cascade,
  fund_date date not null,
  contributor text not null,
  type text,
  amount numeric not null,
  reference text,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.audit_events (
  id text primary key,
  project_id text,
  occurred_at timestamptz not null,
  actor text,
  action text not null,
  detail text,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.app_settings enable row level security;
alter table public.app_users enable row level security;
alter table public.initiatives enable row level security;
alter table public.time_entries enable row level security;
alter table public.expense_documents enable row level security;
alter table public.expenses enable row level security;
alter table public.income_entries enable row level security;
alter table public.fund_entries enable row level security;
alter table public.audit_events enable row level security;

drop policy if exists "app_settings_anon_all" on public.app_settings;
drop policy if exists "app_users_anon_all" on public.app_users;
drop policy if exists "initiatives_anon_all" on public.initiatives;
drop policy if exists "time_entries_anon_all" on public.time_entries;
drop policy if exists "expense_documents_anon_all" on public.expense_documents;
drop policy if exists "expenses_anon_all" on public.expenses;
drop policy if exists "income_entries_anon_all" on public.income_entries;
drop policy if exists "fund_entries_anon_all" on public.fund_entries;
drop policy if exists "audit_events_anon_all" on public.audit_events;

create policy "app_settings_anon_all" on public.app_settings for all to anon using (true) with check (true);
create policy "app_users_anon_all" on public.app_users for all to anon using (true) with check (true);
create policy "initiatives_anon_all" on public.initiatives for all to anon using (true) with check (true);
create policy "time_entries_anon_all" on public.time_entries for all to anon using (true) with check (true);
create policy "expense_documents_anon_all" on public.expense_documents for all to anon using (true) with check (true);
create policy "expenses_anon_all" on public.expenses for all to anon using (true) with check (true);
create policy "income_entries_anon_all" on public.income_entries for all to anon using (true) with check (true);
create policy "fund_entries_anon_all" on public.fund_entries for all to anon using (true) with check (true);
create policy "audit_events_anon_all" on public.audit_events for all to anon using (true) with check (true);
