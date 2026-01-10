# Core Service

Core API service untuk Ubermensch app.

## Features

- Goals/Quests CRUD
- Actions/Habits management
- Daily check-ins
- Domain scores calculation
- Progress tracking
- Evidence vault

## API Endpoints

### Goals
- `GET /api/v1/goals` - Get all goals
- `GET /api/v1/goals/{id}` - Get goal by ID
- `POST /api/v1/goals` - Create goal
- `PUT /api/v1/goals/{id}` - Update goal
- `DELETE /api/v1/goals/{id}` - Delete goal

### Actions
- `GET /api/v1/goals/{goalId}/actions` - Get actions for goal
- `POST /api/v1/actions` - Create action
- `PUT /api/v1/actions/{id}` - Update action
- `DELETE /api/v1/actions/{id}` - Delete action
- `POST /api/v1/actions/{id}/complete` - Mark action as completed

### Check-ins
- `GET /api/v1/checkins` - Get check-ins
- `POST /api/v1/checkins` - Create check-in
- `PUT /api/v1/checkins/{id}` - Update check-in

### Domains
- `GET /api/v1/domains` - Get all domains
- `POST /api/v1/domains` - Create domain
- `PUT /api/v1/domains/{id}` - Update domain

## Setup

1. Ensure PostgreSQL is running (via Docker Compose)
2. Run service: `dotnet run`
3. API available at: `http://localhost:5002`

