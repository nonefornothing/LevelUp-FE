# Ubermensch Backend API

Backend services untuk aplikasi Ubermensch menggunakan .NET Core 8.

## 🏗️ Architecture

- **Framework**: ASP.NET Core 8
- **Database**: PostgreSQL 15
- **Cache**: Redis 7
- **Storage**: MinIO (S3-compatible)
- **Architecture**: Microservices (Auth, Core, Coach)

## 📁 Project Structure

```
backend/
├── auth-service/          # Authentication service
│   ├── Controllers/
│   ├── Services/
│   ├── Models/
│   └── Program.cs
├── core-service/         # Core API service
│   ├── Controllers/
│   ├── Services/
│   ├── Models/
│   └── Program.cs
├── coach-service/        # Coach engine service
│   ├── Controllers/
│   ├── Services/
│   ├── Models/
│   └── Program.cs
├── shared/               # Shared libraries
│   ├── Models/
│   ├── Utilities/
│   └── Database/
└── scripts/              # Database scripts
    └── init.sql
```

## 🚀 Quick Start

### **Prerequisites**
- .NET 8 SDK
- Docker Desktop (untuk PostgreSQL, Redis, MinIO)

### **Setup**

1. **Start Docker services:**
   ```bash
   docker-compose up -d
   ```

2. **Run migrations (optional - schema sudah di init.sql):**
   ```bash
   cd core-service
   dotnet ef database update
   ```

3. **Run services:**
   ```bash
   # Auth Service
   cd auth-service
   dotnet run
   # Runs on http://localhost:5001

   # Core Service
   cd core-service
   dotnet run
   # Runs on http://localhost:5002

   # Coach Service
   cd coach-service
   dotnet run
   # Runs on http://localhost:5003
   ```

## 🔧 Configuration

### **Connection Strings**

Edit `appsettings.Development.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=ubermensch;Username=ubermensch_user;Password=ubermensch_dev_password"
  },
  "Redis": {
    "ConnectionString": "localhost:6379,password=ubermensch_dev_password"
  },
  "JWT": {
    "SecretKey": "your-secret-key-here-min-32-characters",
    "Issuer": "ubermensch.app",
    "Audience": "ubermensch.app",
    "ExpirationMinutes": 15
  },
  "GoogleOAuth": {
    "ClientId": "your-google-client-id",
    "ClientSecret": "your-google-client-secret"
  }
}
```

## 📚 API Documentation

API endpoints akan tersedia di:
- Auth Service: `http://localhost:5001/swagger`
- Core Service: `http://localhost:5002/swagger`
- Coach Service: `http://localhost:5003/swagger`

## 🧪 Testing

```bash
# Run all tests
dotnet test

# Run specific project tests
cd core-service
dotnet test
```

## 📝 Next Steps

1. Setup Google OAuth credentials
2. Configure JWT secret key
3. Implement authentication endpoints
4. Implement core CRUD endpoints
5. Add Swagger documentation

