# Auth Service

Authentication service untuk Ubermensch app.

## Features

- Google OAuth 2.0 authentication
- JWT token generation & validation
- Refresh token management
- User profile management

## API Endpoints

### Authentication
- `POST /api/v1/auth/google` - Google OAuth login
- `POST /api/v1/auth/refresh` - Refresh access token
- `POST /api/v1/auth/logout` - Logout

### User Profile
- `GET /api/v1/auth/profile` - Get user profile
- `PUT /api/v1/auth/profile` - Update user profile

## Setup

1. Create Google OAuth credentials di [Google Cloud Console](https://console.cloud.google.com/)
2. Add credentials to `appsettings.Development.json`
3. Run service: `dotnet run`

