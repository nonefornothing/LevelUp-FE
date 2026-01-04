# Deployment Guide - Ubermensch App

## 🚀 Deployment Strategy untuk 1M Concurrent Users

### **Phase 1: MVP Deployment (0-10K Users)**

#### **Infrastructure Setup**

**Option A: Self-Hosted (Recommended untuk Startup Budget)**

**Server Specs:**
- **Provider**: DigitalOcean / Hetzner / Vultr
- **Instance**: 4 CPU, 16GB RAM, 160GB SSD
- **OS**: Ubuntu 22.04 LTS
- **Cost**: ~$40-80/month

**Services:**
```
┌─────────────────────────────────────┐
│         Nginx (Port 80/443)         │
│      SSL: Let's Encrypt             │
└──────────────┬──────────────────────┘
               │
    ┌──────────┼──────────┐
    │          │          │
┌───▼───┐  ┌───▼───┐  ┌───▼───┐
│Auth   │  │Core   │  │Coach  │
│:5001  │  │:5002  │  │:5003  │
└───┬───┘  └───┬───┘  └───┬───┘
    │          │          │
    └──────────┼──────────┘
               │
    ┌──────────▼──────────┐
    │   PostgreSQL        │
    │   (Port 5432)       │
    └─────────────────────┘
    ┌──────────▼──────────┐
    │   Redis             │
    │   (Port 6379)       │
    └─────────────────────┘
    ┌──────────▼──────────┐
    │   MinIO             │
    │   (Port 9000)       │
    └─────────────────────┘
```

#### **Docker Compose Setup**

**docker-compose.yml**
```yaml
version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    container_name: ubermensch-postgres
    environment:
      POSTGRES_DB: ubermensch
      POSTGRES_USER: ubermensch_user
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ubermensch_user"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: ubermensch-redis
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5

  # MinIO (S3-compatible storage)
  minio:
    image: minio/minio:latest
    container_name: ubermensch-minio
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: ${MINIO_ROOT_USER}
      MINIO_ROOT_PASSWORD: ${MINIO_ROOT_PASSWORD}
    volumes:
      - minio_data:/data
    ports:
      - "9000:9000"
      - "9001:9001"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3

  # Auth Service (.NET)
  auth-service:
    build:
      context: ./backend/auth-service
      dockerfile: Dockerfile
    container_name: ubermensch-auth
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ConnectionStrings__DefaultConnection=Host=postgres;Database=ubermensch;Username=ubermensch_user;Password=${DB_PASSWORD}
      - Redis__ConnectionString=redis:6379,password=${REDIS_PASSWORD}
      - JWT__SecretKey=${JWT_SECRET_KEY}
      - GoogleOAuth__ClientId=${GOOGLE_CLIENT_ID}
      - GoogleOAuth__ClientSecret=${GOOGLE_CLIENT_SECRET}
    ports:
      - "5001:8080"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped

  # Core Service (.NET)
  core-service:
    build:
      context: ./backend/core-service
      dockerfile: Dockerfile
    container_name: ubermensch-core
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ConnectionStrings__DefaultConnection=Host=postgres;Database=ubermensch;Username=ubermensch_user;Password=${DB_PASSWORD}
      - Redis__ConnectionString=redis:6379,password=${REDIS_PASSWORD}
      - MinIO__Endpoint=http://minio:9000
      - MinIO__AccessKey=${MINIO_ROOT_USER}
      - MinIO__SecretKey=${MINIO_ROOT_PASSWORD}
    ports:
      - "5002:8080"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      minio:
        condition: service_healthy
    restart: unless-stopped

  # Coach Engine Service (.NET)
  coach-service:
    build:
      context: ./backend/coach-service
      dockerfile: Dockerfile
    container_name: ubermensch-coach
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ConnectionStrings__DefaultConnection=Host=postgres;Database=ubermensch;Username=ubermensch_user;Password=${DB_PASSWORD}
      - CoreService__BaseUrl=http://core-service:8080
    ports:
      - "5003:8080"
    depends_on:
      - core-service
    restart: unless-stopped

  # Nginx Reverse Proxy
  nginx:
    image: nginx:alpine
    container_name: ubermensch-nginx
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/ssl:/etc/nginx/ssl
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - auth-service
      - core-service
      - coach-service
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
  minio_data:
```

#### **Nginx Configuration**

**nginx/nginx.conf**
```nginx
events {
    worker_connections 1024;
}

http {
    upstream auth_backend {
        server auth-service:8080;
    }

    upstream core_backend {
        server core-service:8080;
    }

    upstream coach_backend {
        server coach-service:8080;
    }

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=auth_limit:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=100r/s;

    server {
        listen 80;
        server_name api.ubermensch.app;
        
        # Redirect to HTTPS
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name api.ubermensch.app;

        ssl_certificate /etc/nginx/ssl/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/privkey.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

        # Auth endpoints
        location /api/v1/auth/ {
            limit_req zone=auth_limit burst=20 nodelay;
            proxy_pass http://auth_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Core API endpoints
        location /api/v1/core/ {
            limit_req zone=api_limit burst=200 nodelay;
            proxy_pass http://core_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Coach endpoints
        location /api/v1/coach/ {
            limit_req zone=api_limit burst=200 nodelay;
            proxy_pass http://coach_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Health check
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
```

#### **SSL Certificate Setup (Let's Encrypt)**

```bash
# Install Certbot
sudo apt update
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d api.ubermensch.app

# Auto-renewal (already configured by certbot)
```

---

### **Phase 2: Scaling (10K-100K Users)**

#### **Horizontal Scaling**

**Load Balancer Setup:**
- Multiple backend instances (2-3)
- Nginx load balancing dengan health checks
- Database read replicas (2-3)

**Updated docker-compose.yml (scaled):**
```yaml
  # Core Service - Instance 1
  core-service-1:
    build: ./backend/core-service
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ConnectionStrings__DefaultConnection=Host=postgres-primary;Database=ubermensch;...
    deploy:
      replicas: 1

  # Core Service - Instance 2
  core-service-2:
    build: ./backend/core-service
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ConnectionStrings__DefaultConnection=Host=postgres-primary;Database=ubermensch;...
    deploy:
      replicas: 1

  # PostgreSQL Primary
  postgres-primary:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: ubermensch
      POSTGRES_USER: ubermensch_user
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_primary_data:/var/lib/postgresql/data

  # PostgreSQL Read Replica 1
  postgres-replica-1:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: ubermensch
      POSTGRES_USER: ubermensch_user
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    command: >
      postgres
      -c hot_standby=on
      -c primary_conninfo=host=postgres-primary port=5432 user=replication_user password=${REPLICATION_PASSWORD}
```

**Nginx Load Balancing:**
```nginx
upstream core_backend {
    least_conn;  # Load balancing method
    server core-service-1:8080 max_fails=3 fail_timeout=30s;
    server core-service-2:8080 max_fails=3 fail_timeout=30s;
    server core-service-3:8080 max_fails=3 fail_timeout=30s;
}
```

---

### **Phase 3: High Scale (100K-1M Users)**

#### **Database Sharding**

**Sharding Strategy:**
- Shard berdasarkan `user_id % 10`
- 10 shards untuk distribusi load

**Shard Router (Backend):**
```csharp
public class ShardRouter
{
    private readonly string[] _shardConnections = new[]
    {
        "Host=postgres-shard-0;Database=ubermensch_shard_0;...",
        "Host=postgres-shard-1;Database=ubermensch_shard_1;...",
        // ... 10 shards
    };

    public string GetShardConnection(string userId)
    {
        var shardIndex = GetShardIndex(userId);
        return _shardConnections[shardIndex];
    }

    private int GetShardIndex(string userId)
    {
        // Simple hash-based sharding
        var hash = userId.GetHashCode();
        return Math.Abs(hash % 10);
    }
}
```

#### **Caching Strategy**

**Redis Cluster Setup:**
- 3-5 Redis nodes
- Cluster mode untuk high availability
- Cache layers:
  - L1: In-memory cache (per instance)
  - L2: Redis cluster
  - L3: Database

**Cache Keys:**
```
user:{userId}:profile
user:{userId}:goals
user:{userId}:domain_scores
domain:{domainId}:score:{userId}
goal:{goalId}:progress
```

**Cache TTL:**
- Domain scores: 1 hour
- User profile: 30 minutes
- Goals list: 15 minutes
- Next Best Action: 5 minutes

---

## 📦 Backend Deployment (.NET)

### **Dockerfile Example**

**backend/core-service/Dockerfile**
```dockerfile
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY ["CoreService.csproj", "./"]
RUN dotnet restore "CoreService.csproj"

# Copy everything else and build
COPY . .
RUN dotnet build "CoreService.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "CoreService.csproj" -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Environment variables
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

EXPOSE 8080

ENTRYPOINT ["dotnet", "CoreService.dll"]
```

### **.NET Application Configuration**

**appsettings.Production.json**
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "ConnectionStrings": {
    "DefaultConnection": "${DB_CONNECTION_STRING}"
  },
  "Redis": {
    "ConnectionString": "${REDIS_CONNECTION_STRING}"
  },
  "JWT": {
    "SecretKey": "${JWT_SECRET_KEY}",
    "Issuer": "ubermensch.app",
    "Audience": "ubermensch.app",
    "ExpirationMinutes": 15,
    "RefreshExpirationDays": 7
  },
  "RateLimiting": {
    "PermitLimit": 100,
    "Window": "00:01:00"
  }
}
```

---

## 📱 Android App Deployment

### **Build Configuration**

**app/build.gradle.kts (Release)**
```kotlin
buildTypes {
    release {
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
        
        // Signing config
        signingConfig = signingConfigs.getByName("release")
        
        // Build config fields
        buildConfigField("String", "API_BASE_URL", "\"https://api.ubermensch.app\"")
        buildConfigField("String", "API_VERSION", "\"v1\"")
    }
}
```

### **ProGuard Rules**

**app/proguard-rules.pro**
```proguard
# Keep data classes
-keep class com.ubermensch.**.data.model.** { *; }

# Keep Room entities
-keep @androidx.room.Entity class * { *; }

# Keep Retrofit interfaces
-keep interface com.ubermensch.**.data.remote.** { *; }

# Keep Parcelable
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}
```

### **Google Play Upload**

**Steps:**
1. Generate signed AAB (Android App Bundle)
2. Upload ke Google Play Console (Internal Testing)
3. Test dengan internal testers
4. Rollout ke Production (staged: 5% → 20% → 100%)

**Fastlane Setup (Automation):**
```ruby
# fastlane/Fastfile
platform :android do
  desc "Build and upload to Google Play"
  lane :beta do
    gradle(
      task: "bundle",
      build_type: "Release",
      properties: {
        "android.injected.signing.store.file" => ENV["KEYSTORE_PATH"],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"]
      }
    )
    
    upload_to_play_store(
      track: "internal",
      aab: "app/build/outputs/bundle/release/app-release.aab",
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true
    )
  end
end
```

---

## 🔍 Monitoring & Logging

### **Application Logging**

**Serilog Configuration (.NET)**
```csharp
Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .WriteTo.File(
        path: "/var/log/ubermensch/core-service-.log",
        rollingInterval: RollingInterval.Day,
        retainedFileCountLimit: 30
    )
    .WriteTo.Seq("http://seq:5341") // Optional: centralized logging
    .CreateLogger();
```

### **Health Checks**

**Backend Health Check Endpoint:**
```csharp
app.MapHealthChecks("/health", new HealthCheckOptions
{
    ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
});

app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("ready")
});

app.MapHealthChecks("/health/live", new HealthCheckOptions
{
    Predicate = _ => false
});
```

### **Prometheus Metrics**

**Setup Prometheus:**
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'ubermensch-backend'
    static_configs:
      - targets: ['core-service:8080', 'auth-service:8080']
```

**Grafana Dashboard:**
- Request rate
- Error rate
- Response time (p50, p95, p99)
- Database query time
- Cache hit rate
- Active users

---

## 🔐 Security Hardening

### **Server Security**

```bash
# Firewall setup (UFW)
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw enable

# Fail2ban (prevent brute force)
sudo apt install fail2ban
sudo systemctl enable fail2ban
```

### **Database Security**

```sql
-- Create read-only user untuk read replicas
CREATE USER readonly_user WITH PASSWORD 'secure_password';
GRANT CONNECT ON DATABASE ubermensch TO readonly_user;
GRANT USAGE ON SCHEMA public TO readonly_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly_user;
```

### **Secrets Management**

**Option 1: Environment Variables**
```bash
# .env file (never commit!)
DB_PASSWORD=secure_password_here
JWT_SECRET_KEY=very_long_secret_key_here
```

**Option 2: HashiCorp Vault (Advanced)**
- Centralized secrets management
- Dynamic secrets rotation
- Audit logging

---

## 📊 Performance Tuning

### **PostgreSQL Optimization**

**postgresql.conf (Production):**
```conf
# Memory
shared_buffers = 4GB
effective_cache_size = 12GB
work_mem = 64MB
maintenance_work_mem = 1GB

# Connections
max_connections = 200

# Checkpoint
checkpoint_completion_target = 0.9
wal_buffers = 16MB

# Query Planner
random_page_cost = 1.1  # For SSD
effective_io_concurrency = 200
```

### **Connection Pooling**

**PgBouncer Setup:**
```ini
[databases]
ubermensch = host=postgres port=5432 dbname=ubermensch

[pgbouncer]
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 25
```

---

## 🚨 Disaster Recovery

### **Backup Strategy**

**Database Backups:**
```bash
# Daily backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
pg_dump -U ubermensch_user ubermensch | gzip > /backups/ubermensch_$DATE.sql.gz

# Keep last 30 days
find /backups -name "*.sql.gz" -mtime +30 -delete
```

**Automated Backups:**
- Daily full backup
- Weekly backup retention (4 weeks)
- Monthly backup retention (12 months)

### **Recovery Procedure**

1. Stop services
2. Restore database from backup
3. Verify data integrity
4. Start services
5. Monitor for issues

---

## 📈 Cost Optimization

### **Infrastructure Costs (1M Users)**

**Self-Hosted:**
- Servers: $500-1000/month
- Bandwidth: $100-300/month
- Storage: $50-100/month
- **Total: ~$650-1400/month**

**Cloud Managed (Alternative):**
- Backend hosting: $200-500/month
- Database: $200-400/month
- Storage: $50-100/month
- CDN: $100-200/month
- **Total: ~$550-1200/month**

### **Cost Reduction Tips**

1. Use CDN untuk static assets (Cloudflare free tier)
2. Compress responses (gzip)
3. Cache aggressively (reduce database load)
4. Use read replicas (cheaper than primary)
5. Archive old data (move to cold storage)

---

## ✅ Deployment Checklist

### **Pre-Deployment**
- [ ] All tests passing
- [ ] Security scan completed
- [ ] Performance testing done
- [ ] Database migrations tested
- [ ] Backup strategy in place
- [ ] Monitoring configured
- [ ] SSL certificates valid
- [ ] Environment variables set

### **Deployment**
- [ ] Deploy to staging first
- [ ] Smoke tests on staging
- [ ] Deploy to production
- [ ] Verify health checks
- [ ] Monitor error rates
- [ ] Check database connections
- [ ] Verify API endpoints

### **Post-Deployment**
- [ ] Monitor for 24 hours
- [ ] Check error logs
- [ ] Verify user signups working
- [ ] Check sync functionality
- [ ] Monitor performance metrics
- [ ] Gather user feedback

---

**Last Updated**: 2024  
**Maintained By**: DevOps Team

