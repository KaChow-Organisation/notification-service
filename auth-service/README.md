# @kachow-organisation/auth-service

> **Authentication and authorization service for KaChow microservices**

Handles user authentication, token generation, and token validation for the entire microservices ecosystem.

---

## Table of Contents

1. [Purpose](#purpose)
2. [API Endpoints](#api-endpoints)
3. [Dependencies](#dependencies)
4. [Running the Service](#running-the-service)
5. [Example Requests](#example-requests)
6. [Architecture Notes](#architecture-notes)

---

## Purpose

The auth-service is responsible for:
- **User Authentication** - Validating user credentials and issuing tokens
- **Token Generation** - Creating mock JWT tokens for authenticated users
- **Token Validation** - Verifying token validity and extracting user information
- **Identity Management** - Basic user credential storage

This service acts as the security gateway for the entire microservices architecture.

---

## API Endpoints

### POST `/login`

Authenticate a user with username and password.

**Request Body:**
```json
{
  "username": "john_doe",
  "password": "password123"
}
```

**Success Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "userId": "usr-001",
  "expiresAt": "2024-12-31T23:59:59.000Z"
}
```

**Error Response (401) - Invalid credentials:**
```json
{
  "error": "Invalid credentials"
}
```

**Error Response (400) - Validation error:**
```json
{
  "error": "Invalid request",
  "details": [...]
}
```

---

### POST `/validate`

Validate an authentication token.

**Request Body:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Success Response (200) - Valid token:**
```json
{
  "valid": true,
  "userId": "usr-001"
}
```

**Success Response (200) - Invalid token:**
```json
{
  "valid": false
}
```

---

### GET `/health`

Health check endpoint.

**Response:**
```json
{
  "service": "auth-service",
  "status": "healthy",
  "timestamp": "2024-01-20T14:30:00.000Z"
}
```

---

## Dependencies

### HTTP Dependencies (Outbound)

This service has **no outbound HTTP dependencies**. It operates independently and only validates its own issued tokens.

### Inbound Dependencies

| Service | Purpose |
|---------|---------|
| api-gateway | Routes authentication requests to this service |

### Event Dependencies

This service does **not** participate in the event-driven architecture. It is a synchronous-only service.

---

## Running the Service

### Prerequisites

- Node.js 16+
- npm

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
| PORT | 3001 | Service port (defined in shared-contracts) |

---

## Example Requests

### Login

```bash
curl -X POST http://localhost:3001/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "password": "password123"
  }'
```

### Validate Token

```bash
curl -X POST http://localhost:3001/validate \
  -H "Content-Type: application/json" \
  -d '{
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }'
```

### Health Check

```bash
curl http://localhost:3001/health
```

---

## Architecture Notes

### In-Memory Data Store

This service uses an in-memory Map to store user credentials and tokens. In a production environment, this should be replaced with:
- A database (PostgreSQL, MongoDB)
- Redis for token storage with TTL
- A proper JWT library (jsonwebtoken package)

### Security Considerations

⚠️ **WARNING**: This is a demo service with simplified security:
- Passwords are stored in plaintext (never do this in production)
- Tokens are mock JWTs (not cryptographically secure)
- No rate limiting implemented
- No HTTPS enforcement
- No refresh token mechanism

For production use, implement:
- Password hashing (bcrypt)
- Proper JWT signing with secrets
- Rate limiting
- HTTPS/TLS
- Refresh tokens
- Token revocation

### Integration Points

```
┌─────────────┐      ┌─────────────┐
│ API Gateway │─────▶│ Auth Service│
└─────────────┘      └─────────────┘
                            │
                            ▼
                     ┌─────────────┐
                     │ In-Memory   │
                     │ Token Store │
                     └─────────────┘
```

---

## License

MIT © KaChow Organisation
