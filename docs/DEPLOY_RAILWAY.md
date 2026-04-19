# Deploy en Railway

El deploy se hace automáticamente via GitHub Actions cuando creas una release (tag `v*`).

## Setup inicial (una sola vez)

### 1. Crear token de Railway

1. Ve a [railway.app/account/tokens](https://railway.app/account/tokens)
2. Create Token → copia el token
3. En GitHub repo → Settings → Secrets → Actions
4. New secret: `RAILWAY_TOKEN` = el token copiado

### 2. Deshabilitar auto-deploy

En Railway, para cada servicio:
1. Settings → Deploy → Automatic Deploys → OFF

Así solo se deploya cuando creas una release.

## Servicios necesarios

1. **PostgreSQL** - Base de datos
2. **Redis** - Para Sidekiq (jobs en background)
3. **Web** - La app Rails
4. **Worker** - Sidekiq para procesar jobs

## Pasos

### 1. Crear proyecto en Railway

1. Ve a [railway.app](https://railway.app)
2. New Project → Deploy from GitHub repo
3. Selecciona `victoravellog/futpred`

### 2. Agregar PostgreSQL

1. New → Database → PostgreSQL
2. Railway genera automáticamente `DATABASE_URL`

### 3. Agregar Redis

1. New → Database → Redis
2. Railway genera automáticamente `REDIS_URL`

### 4. Configurar variables de entorno

En el servicio **web**, agrega:

```
RAILS_ENV=production
RAILS_MASTER_KEY=<valor de config/master.key>
SECRET_KEY_BASE=<generar con: openssl rand -hex 64>
RAILS_SERVE_STATIC_FILES=true
```

### 5. Agregar Worker (Sidekiq)

1. New → Empty Service → From Repo
2. Selecciona el mismo repo
3. En Settings → Start Command: `bundle exec sidekiq`
4. Copia las mismas variables de entorno del web

## Variables de entorno requeridas

| Variable | Descripción |
|----------|-------------|
| `DATABASE_URL` | Auto-generada por Railway PostgreSQL |
| `REDIS_URL` | Auto-generada por Railway Redis |
| `RAILS_MASTER_KEY` | Contenido de `config/master.key` |
| `SECRET_KEY_BASE` | Generar con `openssl rand -hex 64` |

## Dominio

Railway genera un dominio automático tipo `futpred-production.up.railway.app`.

Puedes agregar un dominio custom en Settings → Domains.
