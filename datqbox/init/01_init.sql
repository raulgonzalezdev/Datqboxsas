CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

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

-- Para futuras migraciones añade aquí o usa Hasura migrations
