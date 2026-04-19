# FutPred - App de Predicciones de Fútbol

## Stack

- **Backend**: Rails 8
- **Frontend**: Hotwire (Turbo + Stimulus), Tailwind CSS
- **Base de datos**: PostgreSQL (Docker)
- **Jobs**: Sidekiq + Redis
- **Testing**: RSpec + YAML fixtures
- **API externa**: Football-Data.org (free tier)

## Convenciones

### Arquitectura

- Usar **Actors** (gema `service_actor`) en lugar de service objects planos
- Actors van en `app/actors/`
- Nombrar actors con verbos: `CalculateScore`, `ImportFixtures`, `SyncResults`

### Testing

- Usar **YAML fixtures** en `spec/fixtures/`, NO FactoryBot
- Cargar fixtures con `fixtures :all` o fixtures específicos
- Specs van en `spec/` siguiendo la estructura de `app/`

### Jobs

- Usar **Sidekiq** con Redis para background jobs
- Jobs van en `app/jobs/`
- Configurar colas en `config/sidekiq.yml`

### Frontend

- Tailwind CSS para estilos
- Turbo Frames para actualizaciones parciales
- Turbo Streams para respuestas de formularios
- Stimulus solo cuando sea necesario JS custom

### Base de datos

- PostgreSQL corriendo en Docker (`docker compose up -d`)
- Credenciales dev: user=futpred, password=futpred, host=localhost

### Git

- NO incluir `Co-Authored-By` de Claude en los commits
- Commits en inglés

## Comandos útiles

```bash
# Desarrollo
docker compose up -d          # Iniciar PostgreSQL
bin/dev                       # Servidor con assets watch
bin/rails server              # Solo Rails

# Base de datos
bin/rails db:migrate
bin/rails db:fixtures:load FIXTURES_PATH=spec/fixtures

# Tests
bundle exec rspec
bundle exec rspec spec/models/

# Sidekiq
bundle exec sidekiq

# Football-Data.org API
bin/rails football_data:competitions          # Listar competiciones disponibles
bin/rails football_data:import[WC]            # Importar Mundial (WC = World Cup)
bin/rails football_data:import[EC]            # Importar Eurocopa
bin/rails football_data:import[CL]            # Importar Champions League
bin/rails football_data:sync                  # Sincronizar resultados
```

## Variables de entorno

```bash
FOOTBALL_DATA_API_KEY=tu_api_key  # Obtener en https://www.football-data.org/
```

## Modelo de datos

```
Tournament (global) ←→ Organization (N:N via OrganizationTournament)
     ↓                        ↓
   Round                 Membership
     ↓                        ↓
  Fixture                   User
     ↓
TournamentTeam → Team

OrganizationTournament → Prediction (las predicciones pertenecen al contexto org+torneo)
```

Los torneos son globales (ej: Mundial 2026) y las organizaciones los agregan para competir.

## Sistema de puntos

| Predicción | Puntos |
|------------|--------|
| Resultado exacto (ej: 2-1) | 5 pts |
| Acertaste quién gana (ej: 3-0 cuando fue 2-1) | 3 pts |
| No acertaste | 0 pts |

Multiplicador por ronda (Round#scoring_multiplier):
- Grupos: x1.0
- Cuartos: x1.5
- Semifinal: x1.75
- Final: x2.0
