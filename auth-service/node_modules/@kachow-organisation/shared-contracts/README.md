# @kachow-organisation/shared-contracts

> **Shared contracts, schemas, and types for KaChow microservices**

This package contains all shared contracts, JSON schemas, type definitions, and event definitions used across the KaChow microservices ecosystem.

---

## Table of Contents

1. [Purpose](#purpose)
2. [Installation](#installation)
3. [Contents](#contents)
   - [Schemas](#schemas)
   - [Event Types](#event-types)
   - [Example Payloads](#example-payloads)
   - [Service Configuration](#service-configuration)
4. [Usage](#usage)
5. [Known Issues & Architectural Violations](#known-issues--architectural-violations)
6. [Contributing](#contributing)

---

## Purpose

The `shared-contracts` package serves as the single source of truth for:
- **API request/response schemas** - Validation schemas for all service endpoints
- **Event definitions** - Event types and schemas for event-driven communication
- **Type definitions** - Shared data models and structures
- **Service configurations** - Ports and URLs for all microservices

---

## Installation

```bash
npm install @kachow-organisation/shared-contracts
```

---

## Contents

### Schemas

All schemas use [Joi](https://joi.dev/) for validation.

#### Auth Service Schemas
- `LoginRequestSchema`
- `LoginResponseSchema`
- `ValidateRequestSchema`
- `ValidateResponseSchema`

#### User Service Schemas
- `UserSchema`
- `CreateUserRequestSchema`

#### Order Service Schemas
- `OrderSchema`
- `CreateOrderRequestSchema`
- `OrderItemSchema`

#### Payment Service Schemas
- `PaymentSchema`
- `PaymentRequestSchema`

#### Notification Service Schemas
- `NotificationSchema`
- `NotificationRequestSchema`

#### Analytics Service Schemas
- `MetricSchema`
- `ReportSchema`

---

### Event Types

| Event Type | Description | Producer | Consumers |
|------------|-------------|----------|-----------|
| `OrderCreated` | Fired when a new order is created | order-service | notification-service, analytics-service |
| `OrderUpdated` | Fired when an order status changes | order-service | notification-service, analytics-service |
| `OrderCancelled` | Fired when an order is cancelled | order-service | notification-service, analytics-service |
| `PaymentProcessed` | Fired when a payment is completed/failed | payment-service | notification-service, analytics-service |
| `PaymentFailed` | Fired when a payment fails | payment-service | notification-service, analytics-service |
| `UserCreated` | Fired when a new user is created | user-service | notification-service, analytics-service |
| `UserUpdated` | Fired when a user is updated | user-service | notification-service, analytics-service |
| `NotificationSent` | Fired when a notification is sent | notification-service | analytics-service |
| `NotificationFailed` | Fired when a notification fails | notification-service | analytics-service |

---

### Example Payloads

```javascript
// Login Request
{
  username: 'john_doe',
  password: 'securePassword123'
}

// Login Response
{
  token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  userId: 'usr-001',
  expiresAt: '2024-12-31T23:59:59Z'
}

// Order Created Event
{
  eventId: 'evt-001',
  eventType: 'OrderCreated',
  timestamp: '2024-01-20T14:30:00Z',
  payload: {
    orderId: 'ord-001',
    userId: 'usr-001',
    totalAmount: 59.98,
    items: [
      {
        productId: 'prod-001',
        quantity: 2,
        unitPrice: 29.99
      }
    ]
  }
}
```

---

### Service Configuration

```javascript
// Service Ports (localhost)
{
  AUTH_SERVICE: 3001,
  USER_SERVICE: 3002,
  ORDER_SERVICE: 3003,
  PAYMENT_SERVICE: 3004,
  NOTIFICATION_SERVICE: 3005,
  API_GATEWAY: 3000,
  ANALYTICS_SERVICE: 3006
}

// Service URLs
{
  AUTH_SERVICE: 'http://localhost:3001',
  USER_SERVICE: 'http://localhost:3002',
  ORDER_SERVICE: 'http://localhost:3003',
  PAYMENT_SERVICE: 'http://localhost:3004',
  NOTIFICATION_SERVICE: 'http://localhost:3005',
  API_GATEWAY: 'http://localhost:3000',
  ANALYTICS_SERVICE: 'http://localhost:3006'
}
```

---

## Usage

```javascript
const contracts = require('@kachow-organisation/shared-contracts');

// Validate data against a schema
const result = contracts.validate(
  contracts.schemas.LoginRequestSchema,
  { username: 'john', password: 'secret' }
);

if (result.error) {
  console.error('Validation failed:', result.error.details);
}

// Access event types
console.log(contracts.EventTypes.ORDER_CREATED); // 'OrderCreated'

// Use service URLs
const userServiceUrl = contracts.ServiceUrls.USER_SERVICE;
```

---

## Known Issues & Architectural Violations

### ⚠️ ARCHITECTURAL VIOLATION: Shared Contracts Anti-Pattern

**Issue**: This package creates tight coupling between all microservices.

**Why it's a violation**:
- In a true microservices architecture, each service should own its own API contract
- Services should not share a common schema package
- Changes to one service's contract require updating this shared package
- This creates a deployment bottleneck and coordination overhead
- Services become tightly coupled to the shared contracts versioning

**Impact**:
- If `order-service` needs to change its schema, all services must update their dependency
- This breaks the independence principle of microservices
- Teams cannot deploy independently

**Recommended approach**:
- Each service should publish its own contract (e.g., as an OpenAPI spec)
- Consumers should import only the contracts they need
- Use schema registries like Confluent Schema Registry for event schemas
- Consumer-driven contracts (CDC) testing instead of shared schemas

### ⚠️ ARCHITECTURAL VIOLATION: Implicit Circular Dependency

**Issue**: This package creates an implicit circular dependency.

**Why it's a violation**:
- Services depend on shared-contracts
- shared-contracts "knows" about all services and their data structures
- If a service changes its data model, shared-contracts must be updated
- This creates a backwards dependency flow

**Diagram**:
```
service-a → shared-contracts
service-b → shared-contracts
            ↑
shared-contracts knows about service-a and service-b's models
```

This is backwards - the shared package should not have knowledge of specific services.

---

## Contributing

When updating this package:
1. Ensure all schemas are validated with Joi
2. Add example payloads for new schemas
3. Update the event types documentation
4. Mark any breaking changes clearly

---

## License

MIT © KaChow Organisation
