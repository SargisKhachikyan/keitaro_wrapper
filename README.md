# Keitaro Wrapper

Keitaro Wrapper is a web application built with Flutter Web and FastAPI for managing campaigns and streams through the Keitaro Admin API.

The Flutter frontend communicates with the FastAPI backend. The backend handles authentication, validation, local database operations, and communication with Keitaro using credentials stored in environment variables.

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
- [Security](#security)
- [Current Status](#current-status)

## Project Overview

The application provides:

- Campaign listing, searching, and refreshing.
- Campaign creation using live Keitaro options.
- GEO-based visitor filtering.
- Redirect streams with configurable destinations.
- Offer streams with selected Keitaro offers.
- Campaign editing.
- Adding and removing offers from streams.
- Editing offer shares.
- Domain, campaign group, and traffic source selection.
- Dashboard and offers pages.

### Campaign Creation Flow

When a campaign is created, the backend performs the following operations:

1. Creates a campaign in Keitaro.
2. Creates a redirect stream with a country filter and Google redirect.
3. Creates a second stream containing the selected offer with a 100% share.

The campaign also receives the selected domain, group, and traffic source.

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
- HTTP

### Database

- SQLite
- SQLAlchemy ORM
- Alembic migrations

## Project Structure

```text
keitaro_wrapper/
├── backend/
│   ├── app/
│   │   ├── api/
│   │   │   └── routes/
│   │   ├── core/
│   │   ├── models/
│   │   ├── schemas/
│   │   ├── services/
│   │   └── main.py
│   ├── alembic/
│   │   └── versions/
│   ├── tests/
│   ├── .env.example
│   ├── alembic.ini
│   └── requirements.txt (not included)
│
├── frontend/
│   ├── lib/
│   │   ├── core/
│   │   │   ├── api/
│   │   │   ├── router/
│   │   │   ├── layout/
│   │   │   └── theme/
│   │   ├── dashboard/
│   │   ├── campaigns/
│   │   └── offers/
│   ├── test/
│   └── pubspec.yaml
│
├── .gitignore
└── README.md
```

## Prerequisites

- Git
- Python 3.9 or newer
- Flutter SDK
- Dart SDK compatible with the constraint in `frontend/pubspec.yaml` (`^3.13.3`)
- Access to a Keitaro instance
- Keitaro Admin API credentials

## Backend Setup

Run the following commands from the project root.

### 1. Navigate to the backend

```bash
cd backend
```

### 2. Create a virtual environment

```bash
python3 -m venv .venv
```

Activate it:

macOS / Linux:

```bash
source .venv/bin/activate
```

Windows:

```bash
.venv\Scripts\activate
```

### 3. Install dependencies

```bash
python -m pip install --upgrade pip

python -m pip install fastapi uvicorn sqlalchemy alembic httpx python-dotenv pydantic pytest
```

### 4. Configure environment variables

Create your local environment file:

```bash
cp .env.example .env
```

Open `backend/.env` and provide your Keitaro API URL, API key, and backend authentication credentials.

### 5. Apply database migrations

```bash
alembic upgrade head
```

### 6. Start the backend

```bash
uvicorn app.main:app --reload
```

The backend will be available at:

- API: http://127.0.0.1:8000
- Swagger documentation: http://127.0.0.1:8000/docs

The application entry point is `backend/app/main.py`.

## Environment Variables

The backend uses the following environment variables:

| Variable | Description |
|---|---|
| `KEITARO_BASE_URL` | Keitaro instance URL |
| `KEITARO_API_KEY` | Keitaro Admin API key |
| `BACKEND_AUTH_ENABLED` | Enables backend authentication |
| `BACKEND_AUTH_USERNAME` | Backend login username |
| `BACKEND_AUTH_PASSWORD` | Backend login password |
| `CORS_ALLOWED_ORIGINS` | Allowed frontend origins |
| `TRUST_PROXY` | Enables trusted proxy handling |
| `RATE_LIMIT_REQUESTS_PER_MINUTE` | General request limit |
| `RATE_LIMIT_LOGIN_PER_MINUTE` | Login request limit |

Example:

```dotenv
KEITARO_BASE_URL=https://example-keitaro-host
KEITARO_API_KEY=replace-with-your-api-key

BACKEND_AUTH_ENABLED=true
BACKEND_AUTH_USERNAME=admin
BACKEND_AUTH_PASSWORD=replace-with-a-long-random-password

CORS_ALLOWED_ORIGINS=http://localhost:8765,http://127.0.0.1:8765
TRUST_PROXY=false

RATE_LIMIT_REQUESTS_PER_MINUTE=120
RATE_LIMIT_LOGIN_PER_MINUTE=10
```

Never commit real credentials or `.env` files to Git.

## Frontend Setup

Open a second terminal.

### 1. Navigate to the frontend

```bash
cd frontend
```

### 2. Install Flutter dependencies

```bash
flutter pub get
```

### 3. Run the application

```bash
flutter run -d chrome --web-port 8765
```

The frontend will be available at:

http://localhost:8765

The default backend URL is:

```text
http://127.0.0.1:8000
```

It is configured in:

```text
frontend/lib/core/api/api_config.dart
```

To specify another backend URL:

```bash
flutter run -d chrome \
  --web-port 8765 \
  --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

To build the production web application:

```bash
flutter build web
```

The Flutter frontend communicates only with FastAPI. It does not call the Keitaro Admin API directly.

## Database Migrations

The project uses SQLite with SQLAlchemy.

The local database file is:

```text
backend/keitaro.db
```

Run migration commands from the `backend/` directory.

Apply migrations:

```bash
alembic upgrade head
```

Check the current migration:

```bash
alembic current
```

View migration history:

```bash
alembic history
```

Generate a migration after changing SQLAlchemy models:

```bash
alembic revision --autogenerate -m "describe change"
```

The initial migration creates the local `campaigns` table.

Migration files are stored in:

```text
backend/alembic/versions/
```

## API Overview

The backend exposes the following API routes.

### Health

| Method | Endpoint | Description |
|---|---|---|
| GET | `/health` | Backend health check |
| GET | `/` | API status |

### Local Campaign Storage

| Method | Endpoint | Description |
|---|---|---|
| GET | `/campaigns/` | Get locally stored campaigns |
| POST | `/campaigns/` | Create a local campaign record |
| PUT | `/campaigns/{campaign_id}` | Update a local campaign |
| DELETE | `/campaigns/{campaign_id}` | Delete a local campaign |

### Keitaro Campaigns

| Method | Endpoint | Description |
|---|---|---|
| GET | `/keitaro/campaigns` | Get Keitaro campaigns |
| POST | `/keitaro/campaigns` | Create a Keitaro campaign |
| GET | `/keitaro/options` | Get domains, groups, traffic sources, and offers |

### Streams

| Method | Endpoint | Description |
|---|---|---|
| GET | `/keitaro/stream-actions` | Get available stream actions |
| GET | `/keitaro/stream-filters` | Get available stream filters |
| GET | `/keitaro/campaigns/{campaign_id}/streams` | Get campaign streams |
| POST | `/keitaro/campaigns/{campaign_id}/streams` | Create a stream |
| GET | `/keitaro/streams/{stream_id}` | Get stream details |
| PUT | `/keitaro/streams/{stream_id}` | Update stream properties |
| PUT | `/keitaro/streams/{stream_id}/offers` | Update stream offers |
| DELETE | `/keitaro/streams/{stream_id}` | Delete a stream |

### Offer Update Example

The stream offers endpoint accepts an offer list:

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

### Backend Responsibilities

- FastAPI handles HTTP requests.
- Pydantic validates incoming data.
- SQLAlchemy manages local database operations.
- Alembic manages database migrations.
- The Keitaro service communicates with the Keitaro Admin API.
- Authentication and rate limiting protect backend endpoints.

### Frontend Responsibilities

- Flutter builds the web interface.
- BLoC manages application state.
- Repositories handle data operations.
- Models parse API responses.
- ApiClient centralizes HTTP requests and error handling.
- GoRouter manages navigation.

### Request Flow

```text
User
  |
  v
Flutter Web
  |
  v
FastAPI Backend
  |
  +----> SQLite Database
  |
  v
Keitaro Admin API
```

The Keitaro API key remains on the backend and is never placed in Flutter code.

## Testing

### Backend Tests

Run from the `backend/` directory:

```bash
.venv/bin/python -m pytest -q
```

The backend tests cover API routes and validation using mocked behavior.

### Backend Syntax Check

```bash
python -m compileall -q app main.py tests
```

### Frontend Checks

Run from the `frontend/` directory:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter build web
```

## Security

The project includes the following security measures:

- Backend authentication.
- Bearer-token authentication for protected operations.
- Request rate limiting.
- Configurable CORS origins.
- Pydantic request validation.
- Sanitized upstream API errors.
- Keitaro credentials stored in backend environment variables.
- `.env` and local database files excluded from Git.

Do not expose API keys in frontend code, logs, public repositories, or API responses.

Do not perform campaign, stream, or offer mutations against live Keitaro data without authorization.

## Current Status

Implemented:

- Campaign dashboard and listing.
- Campaign creation.
- GEO filtering and redirect stream configuration.
- Selected offer stream creation.
- Domain, group, and traffic source selection.
- Campaign editor.
- Offer list and share editing.
- Backend and frontend integration.
- Local database and migrations.
- Backend authentication and rate limiting.

Verified during development:

- Campaign creation against live Keitaro.
- Stream creation and configuration.
- Offer share updates.
- Backend tests.
- Flutter analysis and tests.
- Flutter web build.

Additional live testing:

- Offer addition and removal against a live Keitaro instance require another available offer and have not yet been fully verified.

## Future Improvements

- Expand integration testing against live Keitaro.
- Add more automated tests for offer management.
- Improve error reporting and user feedback.
- Add more comprehensive deployment documentation.
- Add CI/CD automation.