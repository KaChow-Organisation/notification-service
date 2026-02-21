# @kachow-organisation/api-gateway

> **API Gateway for KaChow microservices - Unified entry point**

Acts as a single entry point for all client requests, routing them to the appropriate microservices.

---

## Table of Contents

1. [Purpose](#purpose)
2. [API Routes](#api-routes)
3. [Dependencies](#dependencies)
4. [Running the Service](#running-the-service)
5. [Example Requests](#example-requests)
6. [Architecture Notes](#architecture-notes)

---

## Purpose

The API Gateway is responsible for:
- **Request Routing** - Directing requests to the appropriate microservice
- **Unified Entry Point** - Providing a single URL for all API access
- **Request Logging** - Tracking all incoming requests
- **Error Handling** - Graceful handling of service failures
- **Load Balancing** - (Future) Distributing requests across instances
- **Authentication** - (Future) JWT validation at the edge

This service acts as the facade for the entire microservices ecosystem.

---

## API Routes

All routes are prefixed through the gateway. The gateway forwards requests to backend services.

### Auth Routes (`/auth/*`)

Forwarded to **auth-service** (port 3001)

| Gateway Path | Service Path | Method | Description |
|--------------|--------------|--------|-------------|
| `/auth/login` | `/login` | POST | Authenticate user |
| `/auth/validate` | `/validate` | POST | Validate token |
| `/auth/health` | `/health` | GET | Auth service health |

**Example:**
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "john_doe", "password": "password123"}'
```

---

### User Routes (`/users/*`)

Forwarded to **user-service** (port 3002)

| Gateway Path | Service Path | Method | Description |
|--------------|--------------|--------|-------------|
| `/users` | `/users` | GET | List all users |
| `/users/:id` | `/users/:id` | GET | Get user by ID |
| `/users` | `/users` | POST | Create user |
| `/users/health` | `/health` | GET | User service health |

**Example:**
```bash
curl http://localhost:3000/users/usr-001
```

---

### Order Routes (`/orders/*`)

Forwarded to **order-service** (port 3003)

| Gateway Path | Service Path | Method | Description |
|--------------|--------------|--------|-------------|
| `/orders` | `/orders` | GET | List all orders |
| `/orders` | `/orders` | POST | Create order |
| `/orders/:id` | `/orders/:id` | GET | Get order by ID |
| `/orders/:id/status` | `/orders/:id/status` | PUT | Update order status |
| `/orders/health` | `/health` | GET | Order service health |

**Example:**
```bash
curl -X POST http://localhost:3000/orders \
  -H "Content-Type: application/json" \
  -d '{"userId": "usr-001", "items": [{"productId": "prod-001", "quantity": 2, "unitPrice": 29.99}]}'
```

---

### Payment Routes (`/payments/*`)

Forwarded to **payment-service** (port 3004)

| Gateway Path | Service Path | Method | Description |
|--------------|--------------|--------|-------------|
| `/payments` | `/payments` | GET | List all payments |
| `/payments` | `/payments` | POST | Create payment |
| `/payments/:id` | `/payments/:id` | GET | Get payment by ID |
| `/payments/:id/refund` | `/payments/:id/refund` | POST | Refund payment |
| `/payments/health` | `/health` | GET | Payment service health |

**Example:**
```bash
curl http://localhost:3000/payments/pay-001
```

---

### Notification Routes (`/notifications/*`)

Forwarded to **notification-service** (port 3005)

| Gateway Path | Service Path | Method | Description |
|--------------|--------------|--------|-------------|
| `/notifications` | `/notifications` | GET | List notifications |
| `/notifications/:id` | `/notifications/:id` | GET | Get notification |
| `/notify` | `/notify` | POST | Send notification |
| `/notifications/health` | `/health` | GET | Notification service health |

**Example:**
```bash
curl -X POST http://localhost:3000/notify \
  -H "Content-Type: application/json" \
  -d '{"userId": "usr-001", "type": "email", "subject": "Hello", "message": "Test"}'
```

---

### Analytics Routes (`/analytics/*`)

Forwarded to **analytics-service** (port 3006)

| Gateway Path | Service Path | Method | Description |
|--------------|--------------|--------|-------------|
| `/analytics/metrics` | `/metrics` | GET | Get metrics |
| `/analytics/reports` | `/reports` | GET | Get reports |
| `/analytics/events` | `/events` | POST | Submit event |
| `/analytics/health` | `/health` | GET | Analytics service health |

**Example:**
```bash
curl http://localhost:3000/analytics/metrics
```

---

### Gateway Endpoints

#### GET `/`

Gateway information.

**Response:**
```json
{
  "name": "KaChow API Gateway",
  "version": "1.0.0",
  "description": "Unified entry point for KaChow microservices",
  "services": {
    "auth": { "path": "/auth", "port": 3001 },
    "users": { "path": "/users", "port": 3002 },
    ...
  }
}
```

#### GET `/health`

Gateway health check.

**Response:**
```json
{
  "service": "api-gateway",
  "status": "healthy",
  "timestamp": "2024-01-21T15:00:00Z",
  "routes": [
    "/auth/* -> auth-service",
    "/users/* -> user-service",
    ...
  ]
}
```

---

## Dependencies

### HTTP Dependencies (Outbound)

| Service | Purpose | Endpoints Used | Critical |
|---------|---------|----------------|----------|
| auth-service | Route auth requests | All | Yes |
| user-service | Route user requests | All | Yes |
| order-service | Route order requests | All | Yes |
| payment-service | Route payment requests | All | Yes |
| notification-service | Route notification requests | All | No |
| analytics-service | Route analytics requests | All | No |

### Inbound Dependencies

| Source | Purpose |
|--------|---------|
| All clients | Single entry point for all API calls |

### Event Dependencies

None - This is a pure request routing service.

---

## Running the Service

### Prerequisites

- Node.js 16+
- npm
- All backend services should be running

### Installation

```bash
# Install dependencies
npm install

# Run in development mode
npm run dev

# Run in production mode
npm start
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| PORT | 3000 | Gateway port (defined in shared-contracts) |

---

## Example Requests

### Login through Gateway

```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "john_doe", "password": "password123"}'
```

### Create Order through Gateway

```bash
curl -X POST http://localhost:3000/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "userId": "usr-001",
    "items": [
      {
        "productId": "prod-001",
        "quantity": 2,
        "unitPrice": 29.99
      }
    ]
  }'
```

### Check Payment Status

```bash
curl http://localhost:3000/payments/pay-001
```

### Send Notification

```bash
curl -X POST http://localhost:3000/notify \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "usr-001",
    "type": "email",
    "subject": "Welcome!",
    "message": "Hello from KaChow!"
  }'
```

---

## Architecture Notes

### Request Flow

```
┌─────────────┐
│   Client    │
│  (Browser)  │
└──────┬──────┘
       │ Single API Call
       ▼
┌─────────────┐
│  API        │
│  Gateway    │◀──── Routing & Logging
│  (Port 3000)│
└──────┬──────┘
       │
       ├────────┬────────┬────────┬────────┐
       ▼        ▼        ▼        ▼        ▼
  ┌────────┐┌────────┐┌────────┐┌────────┐┌────────┐
  │Auth    ││User    ││Order   ││Payment ││Notif.  │
  │Service ││Service ││Service ││Service ││Service│
  │:3001   ││:3002   ││:3003   ││:3004   ││:3005  │
  └────────┘└────────┘└────────┘└────────┘└────────┘
```

### Service Discovery Violation

⚠️ **ARCHITECTURAL VIOLATION: Hardcoded Service URLs**

The gateway currently uses hardcoded service URLs from `shared-contracts`:

```javascript
const { ServiceUrls } = require('@kachow-organisation/shared-contracts');
// ServiceUrls.USER_SERVICE = 'http://localhost:3002'
```

**Why this is a violation**:
- In a proper microservices architecture, services should use service discovery
- Hardcoded URLs prevent dynamic scaling and failover
- If a service moves to a different host/port, the gateway must be updated
- No load balancing across multiple instances

**Recommended approach**:
- Use a service registry (Consul, Eureka)
- Use Kubernetes DNS for service discovery
- Use a service mesh (Istio, Linkerd)
- Implement client-side load balancing

### Timeout Configuration

Different services have different timeout configurations:
- **Auth/User/Notification/Analytics**: 10 seconds
- **Order/Payment**: 15 seconds (allows for payment processing delays)

### Error Handling

The gateway provides consistent error responses:
- **503 Service Unavailable**: Backend service is down
- **502 Bad Gateway**: Backend returned error
- **504 Gateway Timeout**: Backend took too long to respond

---

## License

MIT © KaChow Organisation
