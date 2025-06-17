# Datqbox SaaS Backend Starter

Sistema completo para SaaS:
- Autenticación JWT, Google, GitHub, 2FA (Nhost Auth)
- GraphQL API instantánea (Hasura)
- Multi-tenant (tablas organization/user, políticas RLS)
- 100% listo para Docker

## Pasos para correr

1. Renombra las variables de OAuth (Google/Github) en `docker-compose.yml` por tus credenciales.
2. Ejecuta:

```bash
docker-compose up -d
```

Accede a:

- Hasura Console: http://localhost:8080
- Nhost Auth: http://localhost:4000
- Mailhog (test emails): http://localhost:8025

Usa la consola Hasura para añadir permisos, configurar claims, y crear migraciones/metadata.

### Documentación relevante
- [Nhost Auth Docs](https://docs.nhost.io/auth)
- [Hasura Auth Setup](https://hasura.io/docs/latest/auth/authentication/)
- [Hasura RLS Policies](https://hasura.io/docs/latest/auth/authorization/row-level-permissions/)

---

## **6. Políticas RLS y Claims (añade desde la consola Hasura)**

En Hasura Console (http://localhost:8080):

- Agrega RLS a `users`, `organizations`, y tu tabla de datos.  
- Añade los claims en los JWT:
  - `x-hasura-user-id`
  - `x-hasura-organization-id`
  - `x-hasura-default-role`
  - `x-hasura-allowed-roles`

Ejemplo de policy para `datqbox_items`:

```sql
ALTER TABLE public.datqbox_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Only org members can access"
    ON public.datqbox_items
    USING (organization_id::text = current_setting('request.jwt.claims', true)::json->>'x-hasura-organization-id');
```

---

¿Qué debes hacer ahora?

- Copia todo lo anterior en la estructura indicada en una carpeta datqbox/.
- Agrega tus credenciales OAuth (Google/GitHub) en docker-compose.yml.
- (Opcional) Agrega tus migraciones Hasura en hasura/metadata/ (luego de correr el stack y usar la consola, puedes exportar el metadata y copiar aquí).
