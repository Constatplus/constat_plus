alter table public.profiles enable row level security;
alter table public.organizations enable row level security;
alter table public.organization_members enable row level security;

create or replace function public.is_app_admin(candidate_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles
    where id = candidate_user_id
      and role = 'admin'::public.app_role
      and account_status = 'active'::public.account_status
  );
$$;

create or replace function public.is_organization_member(
  candidate_organization_id uuid,
  candidate_user_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.organization_members
    where organization_id = candidate_organization_id
      and user_id = candidate_user_id
      and status = 'active'::public.membership_status
  );
$$;

create or replace function public.is_organization_owner(
  candidate_organization_id uuid,
  candidate_user_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.organization_members
    where organization_id = candidate_organization_id
      and user_id = candidate_user_id
      and role in (
        'owner'::public.organization_role,
        'admin'::public.organization_role
      )
      and status = 'active'::public.membership_status
  );
$$;

revoke all on function public.is_app_admin(uuid) from public;
revoke all on function public.is_organization_member(uuid, uuid) from public;
revoke all on function public.is_organization_owner(uuid, uuid) from public;
grant execute on function public.is_app_admin(uuid) to authenticated;
grant execute on function public.is_organization_member(uuid, uuid)
  to authenticated;
grant execute on function public.is_organization_owner(uuid, uuid)
  to authenticated;

create policy profiles_select_own_or_admin
on public.profiles
for select
to authenticated
using (id = auth.uid() or public.is_app_admin(auth.uid()));

create policy profiles_update_own
on public.profiles
for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());

create policy organizations_select_member_or_admin
on public.organizations
for select
to authenticated
using (
  public.is_organization_member(id, auth.uid())
  or public.is_app_admin(auth.uid())
);

create policy organizations_insert_creator
on public.organizations
for insert
to authenticated
with check (created_by = auth.uid());

create policy organizations_update_owner_or_admin
on public.organizations
for update
to authenticated
using (
  public.is_organization_owner(id, auth.uid())
  or public.is_app_admin(auth.uid())
)
with check (
  public.is_organization_owner(id, auth.uid())
  or public.is_app_admin(auth.uid())
);

create policy organizations_delete_owner_or_admin
on public.organizations
for delete
to authenticated
using (
  public.is_organization_owner(id, auth.uid())
  or public.is_app_admin(auth.uid())
);

create policy organization_members_select_member_or_admin
on public.organization_members
for select
to authenticated
using (
  public.is_organization_member(organization_id, auth.uid())
  or public.is_app_admin(auth.uid())
);

create policy organization_members_insert_owner_or_admin
on public.organization_members
for insert
to authenticated
with check (
  public.is_organization_owner(organization_id, auth.uid())
  or public.is_app_admin(auth.uid())
);

create policy organization_members_update_owner_or_admin
on public.organization_members
for update
to authenticated
using (
  public.is_organization_owner(organization_id, auth.uid())
  or public.is_app_admin(auth.uid())
)
with check (
  public.is_organization_owner(organization_id, auth.uid())
  or public.is_app_admin(auth.uid())
);

create policy organization_members_delete_owner_or_admin
on public.organization_members
for delete
to authenticated
using (
  public.is_organization_owner(organization_id, auth.uid())
  or public.is_app_admin(auth.uid())
);

revoke all on public.profiles from anon;
revoke all on public.organizations from anon;
revoke all on public.organization_members from anon;

revoke insert, update, delete on public.profiles from authenticated;
grant select on public.profiles to authenticated;
grant update (
  first_name,
  last_name,
  company_name,
  company_number,
  address,
  phone,
  professional_title
) on public.profiles to authenticated;

grant select, insert, update, delete on public.organizations to authenticated;
grant select, insert, update, delete on public.organization_members
  to authenticated;

revoke all on function public.sync_auth_user_profile() from public;
revoke all on function public.add_organization_owner() from public;
