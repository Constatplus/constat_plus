create type public.app_role as enum ('user', 'controller', 'admin');
create type public.account_status as enum (
  'pending',
  'active',
  'suspended',
  'closed'
);
create type public.organization_role as enum ('owner', 'admin', 'member');
create type public.membership_status as enum (
  'invited',
  'active',
  'suspended',
  'removed'
);

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null,
  first_name text not null default '',
  last_name text not null default '',
  company_name text not null default '',
  company_number text not null default '',
  address text not null default '',
  phone text not null default '',
  professional_title text not null default '',
  role public.app_role not null default 'user',
  account_status public.account_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_email_not_blank check (length(trim(email)) > 3)
);

create unique index profiles_email_lower_unique
  on public.profiles (lower(email));

create table public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  company_number text not null default '',
  billing_email text not null default '',
  created_by uuid not null references public.profiles (id) on delete restrict,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint organizations_name_not_blank check (length(trim(name)) > 0)
);

create table public.organization_members (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null
    references public.organizations (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  role public.organization_role not null default 'member',
  status public.membership_status not null default 'invited',
  invited_by uuid references public.profiles (id) on delete set null,
  joined_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, user_id)
);

create index organization_members_user_id_idx
  on public.organization_members (user_id);
create index organization_members_organization_id_idx
  on public.organization_members (organization_id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

create trigger organizations_set_updated_at
before update on public.organizations
for each row execute function public.set_updated_at();

create trigger organization_members_set_updated_at
before update on public.organization_members
for each row execute function public.set_updated_at();

create or replace function public.sync_auth_user_profile()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (
    id,
    email,
    first_name,
    last_name,
    company_name,
    phone,
    professional_title,
    account_status
  )
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'first_name', ''),
    coalesce(new.raw_user_meta_data ->> 'last_name', ''),
    coalesce(new.raw_user_meta_data ->> 'company', ''),
    coalesce(new.raw_user_meta_data ->> 'phone', ''),
    coalesce(new.raw_user_meta_data ->> 'profession', ''),
    case
      when new.email_confirmed_at is null then 'pending'::public.account_status
      else 'active'::public.account_status
    end
  )
  on conflict (id) do update
  set
    email = excluded.email,
    account_status = case
      when public.profiles.account_status in (
        'suspended'::public.account_status,
        'closed'::public.account_status
      ) then public.profiles.account_status
      else excluded.account_status
    end;
  return new;
end;
$$;

create trigger auth_user_profile_created
after insert on auth.users
for each row execute function public.sync_auth_user_profile();

create trigger auth_user_profile_updated
after update of email, email_confirmed_at on auth.users
for each row execute function public.sync_auth_user_profile();

insert into public.profiles (
  id,
  email,
  first_name,
  last_name,
  company_name,
  phone,
  professional_title,
  account_status
)
select
  id,
  coalesce(email, ''),
  coalesce(raw_user_meta_data ->> 'first_name', ''),
  coalesce(raw_user_meta_data ->> 'last_name', ''),
  coalesce(raw_user_meta_data ->> 'company', ''),
  coalesce(raw_user_meta_data ->> 'phone', ''),
  coalesce(raw_user_meta_data ->> 'profession', ''),
  case
    when email_confirmed_at is null then 'pending'::public.account_status
    else 'active'::public.account_status
  end
from auth.users
on conflict (id) do nothing;

create or replace function public.add_organization_owner()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.organization_members (
    organization_id,
    user_id,
    role,
    status,
    invited_by,
    joined_at
  )
  values (
    new.id,
    new.created_by,
    'owner'::public.organization_role,
    'active'::public.membership_status,
    new.created_by,
    now()
  );
  return new;
end;
$$;

create trigger organization_owner_created
after insert on public.organizations
for each row execute function public.add_organization_owner();

comment on column public.profiles.role is
  'Rôle applicatif géré côté serveur. Ne jamais le déduire de user_metadata.';
comment on table public.organization_members is
  'Préparation de la collaboration Pro ; aucune interface équipe au lot 2.';
