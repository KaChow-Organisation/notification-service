# @kachow-organisation/user-service

> **User management service for KaChow microservices**

Manages user profiles, user data, and provides user information to other services in the ecosystem.

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

The user-service is responsible for:
- **User Profile Management** - Storing and retrieving user information
- **User Data Access** - Providing user details to other services
- **User Creation** - Registering new users in the system
- **Event Publishing** - Notifying other services when users are created/updated

This service acts as the single source of truth for user data across the microservices ecosystem.

---

## API Endpoints

### GET `/users`

Retrieve a list of all users (simplified view).

**Response (200):**
```json
{
  "users": [
    {
      "id": "usr-001",
      "username": "john_doe",
      "email": "john@example.com",
      "fullName": "John Doe",
      "createdAt": "2024-01-15T10:30:00Z"
    },
    {
      "id": "usr-002",
      "username": "jane_smith",
      "email": "jane@example.com",
      "fullName": "Jane Smith",
      "createdAt": "2024-01-16T11:00:00Z"
    }
  ],
  "count": 2
}
```

---

### GET `/users/:id`

Retrieve detailed information for a specific user.

**Parameters:**
- `id` (path) - User ID (e.g., `usr-001`)

**Success Response (200):**
```json
{
  "id": "usr-001",
  "username": "john_doe",
  "email": "john@example.com",
  "fullName": "John Doe",
  "phone": "+1-555-0101",
  "address": {
    "street": "123 Main St",
    "city": "New York",
    "zipCode": "10001",
    "country": "USA"
  },
  "createdAt": "2024-01-15T10:30:00Z",
  "lastLoginAt": "2024-01-20T14:30:00Z"
}
```

**Error Response (404):**
```json
{
  "error": "User not found",
  "userId": "usr-999"
}
```

---

### POST `/users`

Create a new user.

**Request Body:**
```json
{
  "username": "alice_wonder",
  "email": "alice@example.com",
  "fullName": "Alice Wonderland"
}
```

**Success Response (201):**
```json
{
  "id": "usr-k9x2m8p3",
  "username": "alice_wonder",
  "email": "alice@example.com",
  "fullName": "Alice Wonderland",
  "phone": null,
  "address": null,
  "createdAt": "2024-01-21T10:15:30.000Z",
  "lastLoginAt": null
}
```

**Error Response (409) - Duplicate:**
```json
{
  "error": "Username already exists",
  "username": "john_doe"
}
```

---

### GET `/health`

Health check endpoint.

**Response:**
```json
{
  "service": "user-service",
  "status": "healthy",
  "userCount": 3,
  "timestamp": "2024-01-21T10:15:30.000Z"
}
```

---

## Dependencies

### HTTP Dependencies (Outbound)

| Service | Purpose | Endpoint Used |
|---------|---------|---------------|
| analytics-service | Send events for tracking | `POST /events` |

### Inbound Dependencies

| Service | Purpose | Endpoints Used |
|---------|---------|----------------|
| api-gateway | Routes user requests | All endpoints |
| order-service | Fetch user information for orders | `GET /users/:id` |
| notification-service | Fetch user contact info | `GET /users/:id` |

### Event Dependencies (Outbound Events)

| Event Type | Description | Payload |
|------------|-------------|---------|
| `UserCreated` | Fired when a new user is registered | `{ userId, username, email }` |

### Event Dependencies (Inbound Events)

None - This service does not listen for events.

---

## Running the Service

### Prerequisites

- Node.js 16+
- npm
- Other services should be running for full functionality

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
| PORT | 3002 | Service port (defined in shared-contracts) |

---

## Example Requests

### List All Users

```bash
curl http://localhost:3002/users
```

### Get User by ID

```bash
curl http://localhost:3002/users/usr-001
```

### Create New User

```bash
curl -X POST http://localhost:3002/users \
  -H "Content-Type: application/json" \
  -d '{
    "username": "alice_wonder",
    "email": "alice@example.com",
    "fullName": "Alice Wonderland"
  }'
```

### Health Check

```bash
curl http://localhost:3002/health
```

---

## Architecture Notes

### In-Memory Data Store

This service uses an in-memory Map to store user data. In a production environment, this should be replaced with:
- A database (PostgreSQL, MongoDB, MySQL)
- A caching layer (Redis) for frequently accessed users
- Persistent storage with backups

### Pre-seeded Data

The service comes with 3 pre-seeded users for testing:
- `usr-001`: john_doe
- `usr-002`: jane_smith
- `usr-003`: bob_wilson

### Service Communication Flow

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│ Order Svc   │─────▶│ User Svc    │      │ Analytics   │
│             │      │             │─────▶│ Service     │
└─────────────┘      └─────────────┘      └─────────────┘
                            ▲
┌─────────────┐             │
│ Notification│─────────────┤
│ Service     │             │
└─────────────┘      ┌──────┴──────┐
                     │ In-Memory   │
                     │ User Store  │
                     └─────────────┘
```

### Integration Notes

- **order-service** calls this service to validate users and get shipping addresses
- **notification-service** calls this service to get user contact information
- Events are sent to **analytics-service** for tracking user registrations

---

## License

MIT © KaChow Organisation
