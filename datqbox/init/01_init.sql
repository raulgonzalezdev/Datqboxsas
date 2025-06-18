CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Crear el esquema requerido por Nhost Auth
CREATE SCHEMA IF NOT EXISTS auth;

CREATE TABLE IF NOT EXISTS public.organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT NOT NULL UNIQUE,
    display_name TEXT,
    password_hash TEXT,
    organization_id UUID REFERENCES public.organizations(id),
    role TEXT DEFAULT 'user',
    is_2fa_enabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Ejemplo: tabla de datos propia de Datqbox (puedes expandir)
CREATE TABLE IF NOT EXISTS public.datqbox_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES public.organizations(id),
    owner_id UUID REFERENCES public.users(id),
    title TEXT,
    content TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ===================
-- Habilitar Row Level Security (RLS) y políticas multi-tenant SaaS
-- ===================

-- 1. Habilitar RLS en las tablas principales
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.datqbox_items ENABLE ROW LEVEL SECURITY;

-- 2. Políticas para que cada usuario solo vea su organización y sus datos

-- Solo miembros de la organización pueden ver la organización
CREATE POLICY "Org: Solo miembros pueden ver" ON public.organizations
    USING (id::text = current_setting('request.jwt.claims', true)::json->>'x-hasura-organization-id');

-- Solo miembros pueden ver usuarios de su organización
CREATE POLICY "Users: Solo miembros pueden ver" ON public.users
    USING (organization_id::text = current_setting('request.jwt.claims', true)::json->>'x-hasura-organization-id');

-- Solo miembros pueden ver items de su organización
CREATE POLICY "Items: Solo miembros pueden ver" ON public.datqbox_items
    USING (organization_id::text = current_setting('request.jwt.claims', true)::json->>'x-hasura-organization-id');

-- 3. Permitir inserts solo si el usuario pertenece a la organización
CREATE POLICY "Users: Insert solo propio org" ON public.users
    FOR INSERT USING (organization_id::text = current_setting('request.jwt.claims', true)::json->>'x-hasura-organization-id');
CREATE POLICY "Items: Insert solo propio org" ON public.datqbox_items
    FOR INSERT USING (organization_id::text = current_setting('request.jwt.claims', true)::json->>'x-hasura-organization-id');

-- 4. Permitir updates solo si el usuario es dueño
CREATE POLICY "Users: Update solo propio" ON public.users
    FOR UPDATE USING (id::text = current_setting('request.jwt.claims', true)::json->>'x-hasura-user-id');
CREATE POLICY "Items: Update solo dueño" ON public.datqbox_items
    FOR UPDATE USING (owner_id::text = current_setting('request.jwt.claims', true)::json->>'x-hasura-user-id');

-- 5. Permitir deletes solo si el usuario es dueño
CREATE POLICY "Users: Delete solo propio" ON public.users
    FOR DELETE USING (id::text = current_setting('request.jwt.claims', true)::json->>'x-hasura-user-id');
CREATE POLICY "Items: Delete solo dueño" ON public.datqbox_items
    FOR DELETE USING (owner_id::text = current_setting('request.jwt.claims', true)::json->>'x-hasura-user-id');

-- ===================
-- Fin de políticas SaaS multi-tenant
-- ===================

-- Para futuras migraciones añade aquí o usa Hasura migrations
