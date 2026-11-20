# Keitaro Wrapper

Keitaro Wrapper is a Flutter Web and FastAPI application for managing campaigns and streams through a real Keitaro Admin API instance.

The Flutter frontend sends requests to the local FastAPI backend. FastAPI communicates with Keitaro using the API key and base URL stored in the backend environment.

## Table of Contents

- [Project Overview](#project-overview)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Backend Setup](#backend-setup)
- [Environment Variables](#environment-variables)
- [Frontend Setup](#frontend-setup)
- [Database Migrations](#database-migrations)
- [API Overview](#api-overview)
- [Architecture](#architecture)
- [Testing](#testing)
- [Security Notes](#security-notes)
- [Current Status](#current-status)

## Project Overview

The application provides:

- Campaign list, search, refresh, and editor navigation.
- Campaign creation with live Keitaro options.
- GEO country filtering.
- A redirect stream for matching GEO visitors.
- A stream with a selected Keitaro offer.
- Offer viewing, adding, removal, share editing, and saving.
- Real domain, campaign group, traffic source, and offer options.
- Dark dashboard and offers views.

Created streams follow the implemented backend flow:

1. Create the campaign.
2. Create a regular redirect stream with a country filter and Google redirect.
3. Create a default landings stream with the selected offer and 100% share.

## Tech Stack

### Backend

- Python
- FastAPI
- Uvicorn
- SQLAlchemy
- Alembic
- Pydantic
- HTTPX
- python-dotenv
- pytest

### Frontend

- Flutter
- Dart
- Flutter Web
- flutter_bloc
- Equatable
- GoRouter
- HTTP package

### Database

- SQLite
- Database file: `backend/keitaro.db`

## Project Structure

```text
keitaro_wrapper/
├── backend/
│   ├── app/
│   │   ├── api/routes/       # FastAPI health, local, and Keitaro routes
│   │   ├── core/             # SQLite database configuration
│   │   ├── models/           # SQLAlchemy models
│   │   ├── schemas/          # Pydantic request and response schemas
│   │   └── services/         # Keitaro Admin API client
│   ├── alembic/              # Migration environment and revisions
│   ├── tests/                # Backend route tests
│   ├── alembic.ini           # Alembic configuration
│   └── .env                  # Local secrets, ignored by Git
├── frontend/
│   ├── lib/
│   │   ├── core/api/         # API base configuration and HTTP client
│   │   ├── core/router/      # GoRouter configuration
│   │   ├── core/layout/      # App layout and sidebar
│   │   ├── core/theme/       # Application theme
│   │   ├── dashboard/        # Dashboard BLoC, page, and widgets
│   │   ├── campaigns/        # Campaign BLoC, models, repository, pages
│   │   └── offers/           # Offers BLoC, repository, page, and widgets
│   ├── test/                 # Flutter widget tests
│   └── pubspec.yaml          # Flutter dependencies
├── .gitignore
└── README.md
```

## Prerequisites

- Git.
- Python 3.9 or newer.
- Flutter stable.
- Dart SDK supplied by Flutter.
- A running Keitaro instance and Keitaro Admin API credentials.

The project currently uses Dart `3.13.3` as declared in `frontend/pubspec.yaml`.

## Backend Setup

Run commands from the project root:

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install fastapi uvicorn sqlalchemy alembic httpx python-dotenv pydantic pytest
```

Create the environment file:

```bash
cp .env.example .env
```

Add valid credentials to `.env`, then apply migrations:

```bash
alembic upgrade head
```

Start the API:

```bash
uvicorn app.main:app --reload
```

The API is available at <http://127.0.0.1:8000>. Swagger is available at <http://127.0.0.1:8000/docs>.

`backend/app/main.py` is the application entry point used by Uvicorn. `backend/main.py` is a separate, older entry point and is not used by the command above.

## Environment Variables

Create `backend/.env` using this format:

```dotenv
KEITARO_BASE_URL=https://example-keitaro-host
KEITARO_API_KEY=replace-with-your-api-key
```

Required variables:

- `KEITARO_BASE_URL` — base URL of the Keitaro instance.
- `KEITARO_API_KEY` — Keitaro Admin API key.
- `BACKEND_AUTH_ENABLED` — Set `true` to require login for backend operations.
- `BACKEND_AUTH_USERNAME` — Backend login username.
- `BACKEND_AUTH_PASSWORD` — Backend login password.
- `CORS_ALLOWED_ORIGINS` — Comma-separated frontend origins.
- `TRUST_PROXY` — Set `true` only behind a trusted reverse proxy.
- `RATE_LIMIT_REQUESTS_PER_MINUTE` — General per-IP request limit.
- `RATE_LIMIT_LOGIN_PER_MINUTE` — Login attempt limit.

Never commit real credentials.

## Frontend Setup

Run commands from the project root:

```bash
cd frontend
flutter pub get
flutter run -d chrome --web-port 8765
```

The default backend address is `http://127.0.0.1:8000`, defined in `lib/core/api/api_config.dart`.

To use another address:

```bash
flutter run -d chrome --web-port 8765 \
  --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

For a release build:

```bash
flutter build web
```

The Flutter app opens FastAPI routes only. It never calls the Keitaro Admin API directly.

## Database Migrations

The local SQLAlchemy database is SQLite at `backend/keitaro.db`. The database URL is configured in both `app/core/database.py` and `alembic.ini`.

Run migration commands from `backend/`:

```bash
alembic upgrade head
alembic current
alembic history
```

The initial migration creates the `campaigns` table. It is located at:

```text
backend/alembic/versions/f1b62a6778d8_create_campaigns_table.py
```

To generate a new migration after model changes:

```bash
alembic revision --autogenerate -m "describe change"
```

## API Overview

### Health

| Method | Path | Purpose |
|---|---|---|
| GET | `/health` | Backend health check |
| GET | `/` | API status message |

### Local campaign storage

| Method | Path | Purpose |
|---|---|---|
| GET | `/campaigns/` | List local SQLAlchemy campaigns |
| POST | `/campaigns/` | Create a local campaign record |
| PUT | `/campaigns/{campaign_id}` | Update a local campaign record |
| DELETE | `/campaigns/{campaign_id}` | Delete a local campaign record |

### Keitaro campaigns

| Method | Path | Purpose |
|---|---|---|
| GET | `/keitaro/campaigns` | List Keitaro campaigns |
| POST | `/keitaro/campaigns` | Create a Keitaro campaign |

### Keitaro options

| Method | Path | Purpose |
|---|---|---|
| GET | `/keitaro/options` | Get domains, groups, traffic sources, and offers |
| GET | `/keitaro/stream-actions` | Get available stream actions |
| GET | `/keitaro/stream-filters` | Get available stream filters |

### Streams and offers

| Method | Path | Purpose |
|---|---|---|
| GET | `/keitaro/campaigns/{campaign_id}/streams` | List campaign streams |
| POST | `/keitaro/campaigns/{campaign_id}/streams` | Create a campaign stream |
| GET | `/keitaro/streams/{stream_id}` | Get a stream |
| PUT | `/keitaro/streams/{stream_id}` | Update stream properties |
| PUT | `/keitaro/streams/{stream_id}/offers` | Replace the stream offer list |
| DELETE | `/keitaro/streams/{stream_id}` | Delete a stream |

The `/keitaro/streams/{stream_id}/offers` endpoint expects:

```json
{
  "offers": [
    {
      "offer_id": 18813,
      "share": 100,
      "state": "active"
    }
  ]
}
```

## Architecture

### Backend

- `app/api/routes/` defines HTTP endpoints and Pydantic validation.
- `app/services/keitaro_service.py` communicates with Keitaro Admin API.
- `app/models/` contains SQLAlchemy entities.
- `app/schemas/` contains local Pydantic request/response models.
- `app/core/database.py` creates the SQLite engine and sessions.
- Alembic manages database migrations.

### Frontend

- Pages compose reusable widgets.
- Widgets display UI and local form state.
- BLoCs handle events and application states.
- Repositories perform backend operations.
- Models parse typed API data.
- `ApiClient` centralizes HTTP requests and JSON/error handling.

Flutter → FastAPI → Keitaro Admin API:

```text
Flutter Web
    ↓
FastAPI backend
    ↓
Keitaro Admin API
```

## Testing

### Backend tests

From `backend/`:

```bash
.venv/bin/python -m pytest -q
```

The existing tests use mocked FastAPI route behavior and cover campaign, options, stream, offer, validation, and CORS paths.

### Backend syntax

```bash
python -m compileall -q app main.py tests
```

### Frontend checks

From `frontend/`:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter build web
```

## Security Notes

- Do not commit `backend/.env`.
- Do not place `KEITARO_API_KEY` in Flutter code or Dart define values.
- Keep Keitaro credentials only in the backend environment.
- Use FastAPI as the proxy to the Keitaro Admin API.
- Do not expose API keys in logs or API error responses.
- CORS is restricted to the configured local Flutter origins and credentials are disabled.
- Do not run campaign, stream, or offer mutations against live data without explicit approval.

## Current Status

The campaign dashboard, campaign creation flow, campaign editor, stream offer management, offers page, and real backend integration are implemented.

Campaign creation and share updates have been verified against live Keitaro during development. Separate offer-addition and offer-removal scenarios against live Keitaro may require additional manual approval and are not declared fully verified.
