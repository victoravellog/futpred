# FutPred ⚽

App de predicciones de fútbol / Football predictions app

---

## 🇪🇸 Español

### ¿Qué es FutPred?

FutPred es una app para hacer predicciones de partidos de fútbol con tus amigos. Crea organizaciones, agrega torneos (como el Mundial 2026), y compite para ver quién predice mejor los resultados.

### Sistema de puntos

| Predicción | Puntos |
|------------|--------|
| Resultado exacto (ej: predijiste 2-1 y fue 2-1) | 5 pts |
| Acertaste quién gana (ej: predijiste 3-0 y fue 2-1) | 3 pts |
| No acertaste | 0 pts |

Los puntos se multiplican según la fase: Grupos x1, Cuartos x1.5, Semis x1.75, Final x2

### Requisitos

- Ruby 3.3+
- Docker y Docker Compose
- Node.js 20+

### Instalación

```bash
# Clonar el repositorio
git clone https://github.com/tu-usuario/futpred.git
cd futpred

# Instalar dependencias
bundle install
yarn install

# Iniciar PostgreSQL y Redis
docker compose up -d

# Crear base de datos
bin/rails db:create db:migrate

# Cargar datos del Mundial 2026 (opcional)
bin/rails db:seed

# Iniciar servidor
bin/dev
```

Abre http://localhost:3000 y crea tu cuenta.

### Tests

```bash
bundle exec rspec
```

---

## 🇬🇧 English

### What is FutPred?

FutPred is a football predictions app to play with your friends. Create organizations, add tournaments (like the 2026 World Cup), and compete to see who predicts results best.

### Scoring system

| Prediction | Points |
|------------|--------|
| Exact score (e.g.: predicted 2-1 and it was 2-1) | 5 pts |
| Correct winner (e.g.: predicted 3-0 and it was 2-1) | 3 pts |
| Wrong prediction | 0 pts |

Points are multiplied by phase: Groups x1, Quarter-finals x1.5, Semi-finals x1.75, Final x2

### Requirements

- Ruby 3.3+
- Docker and Docker Compose
- Node.js 20+

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/futpred.git
cd futpred

# Install dependencies
bundle install
yarn install

# Start PostgreSQL and Redis
docker compose up -d

# Create database
bin/rails db:create db:migrate

# Load 2026 World Cup data (optional)
bin/rails db:seed

# Start server
bin/dev
```

Open http://localhost:3000 and create your account.

### Tests

```bash
bundle exec rspec
```

---

## Stack

- **Backend**: Rails 8
- **Frontend**: Hotwire (Turbo + Stimulus), Tailwind CSS
- **Database**: PostgreSQL
- **Jobs**: Sidekiq + Redis
- **Testing**: RSpec

## License

MIT
