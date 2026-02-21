# @kachow-organisation/order-service

> **Order management service for KaChow microservices**

Handles order creation, management, and orchestrates the order fulfillment process across multiple services.

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

The order-service is responsible for:
- **Order Creation** - Creating new orders and validating order data
- **User Validation** - Verifying users through user-service
- **Payment Coordination** - Initiating payments through payment-service
- **Order Tracking** - Managing order status throughout its lifecycle
- **Event Publishing** - Notifying other services about order changes

This service acts as the orchestrator for the order fulfillment process.

---

## API Endpoints

### POST `/orders`

Create a new order.

**Request Body:**
```json
{
  "userId": "usr-001",
  "items": [
    {
      "productId": "prod-001",
      "quantity": 2,
      "unitPrice": 29.99
    },
    {
      "productId": "prod-002",
      "quantity": 1,
      "unitPrice": 49.99
    }
  ]
}
```

**Success Response (201):**
```json
{
  "order": {
    "id": "ord-a1b2c3d4",
    "userId": "usr-001",
    "items": [
      {
        "productId": "prod-001",
        "quantity": 2,
        "unitPrice": 29.99
      },
      {
        "productId": "prod-002",
        "quantity": 1,
        "unitPrice": 49.99
      }
    ],
    "totalAmount": 109.97,
    "status": "confirmed",
    "paymentId": "pay-e5f6g7h8",
    "createdAt": "2024-01-21T10:15:30.000Z",
    "updatedAt": "2024-01-21T10:15:35.000Z"
  },
  "payment": {
    "id": "pay-e5f6g7h8",
    "orderId": "ord-a1b2c3d4",
    "amount": 109.97,
    "currency": "USD",
    "status": "completed",
    "processedAt": "2024-01-21T10:15:35.000Z"
  },
  "message": "Order created successfully"
}
```

**Error Response (400) - Invalid user:**
```json
{
  "error": "Invalid user",
  "message": "User usr-999 not found or user-service unavailable"
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

### GET `/orders/:id`

Get order details by ID.

**Parameters:**
- `id` (path) - Order ID (e.g., `ord-001`)

**Success Response (200):**
```json
{
  "id": "ord-001",
  "userId": "usr-001",
  "items": [
    {
      "productId": "prod-001",
      "quantity": 2,
      "unitPrice": 29.99
    },
    {
      "productId": "prod-002",
      "quantity": 1,
      "unitPrice": 49.99
    }
  ],
  "totalAmount": 109.97,
  "status": "confirmed",
  "paymentId": "pay-001",
  "createdAt": "2024-01-20T10:00:00Z",
  "updatedAt": "2024-01-20T10:05:00Z"
}
```

**Error Response (404):**
```json
{
  "error": "Order not found",
  "orderId": "ord-999"
}
```

---

### GET `/orders`

List all orders.

**Response (200):**
```json
{
  "orders": [
    {
      "id": "ord-001",
      "userId": "usr-001",
      "items": [...],
      "totalAmount": 109.97,
      "status": "confirmed",
      ...
    }
  ],
  "count": 2
}
```

---

### PUT `/orders/:id/status`

Update order status.

**Parameters:**
- `id` (path) - Order ID

**Request Body:**
```json
{
  "status": "shipped"
}
```

**Valid Status Values:**
- `pending` - Order created, awaiting payment
- `confirmed` - Payment received, order confirmed
- `shipped` - Order shipped to customer
- `delivered` - Order delivered to customer
- `cancelled` - Order cancelled

**Response (200):**
```json
{
  "order": {
    "id": "ord-001",
    "status": "shipped",
    "updatedAt": "2024-01-21T11:00:00.000Z",
    ...
  },
  "message": "Status updated successfully"
}
```

---

### GET `/health`

Health check endpoint.

**Response:**
```json
{
  "service": "order-service",
  "status": "healthy",
  "orderCount": 2,
  "timestamp": "2024-01-21T10:15:30.000Z"
}
```

---

## Dependencies

### HTTP Dependencies (Outbound)

| Service | Purpose | Endpoint Used | Critical |
|---------|---------|---------------|----------|
| user-service | Validate user exists | `GET /users/:id` | Yes |
| payment-service | Process payment | `POST /payments` | Yes |
| notification-service | Send order events | `POST /events` | No |
| analytics-service | Send order events | `POST /events` | No |

### Inbound Dependencies

| Service | Purpose | Endpoints Used |
|---------|---------|----------------|
| api-gateway | Routes order requests | All endpoints |
| notification-service | Fetch order details | `GET /orders/:id` |

### Event Dependencies (Outbound Events)

| Event Type | Description | When Emitted | Payload |
|------------|-------------|--------------|---------|
| `OrderCreated` | New order created | After successful order creation | `{ orderId, userId, totalAmount, items, status, paymentId }` |
| `OrderUpdated` | Order status changed | After status update | `{ orderId, userId, status, previousStatus }` |

### Event Dependencies (Inbound Events)

None - This service does not listen for events.

---

## Running the Service

### Prerequisites

- Node.js 16+
- npm
- user-service must be running on port 3002
- payment-service must be running on port 3004
- notification-service and analytics-service optional

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
| PORT | 3003 | Service port (defined in shared-contracts) |

---

## Example Requests

### Create New Order

```bash
curl -X POST http://localhost:3003/orders \
  -H "Content-Type: application/json" \
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

### Get Order by ID

```bash
curl http://localhost:3003/orders/ord-001
```

### List All Orders

```bash
curl http://localhost:3003/orders
```

### Update Order Status

```bash
curl -X PUT http://localhost:3003/orders/ord-001/status \
  -H "Content-Type: application/json" \
  -d '{
    "status": "shipped"
  }'
```

### Health Check

```bash
curl http://localhost:3003/health
```

---

## Architecture Notes

### Order Creation Flow

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │ POST /orders
       ▼
┌─────────────┐
│    Order    │
│   Service   │
└──────┬──────┘
       │
       ├─────────────────┐
       │                 │
       ▼                 ▼
┌─────────────┐    ┌─────────────┐
│User Service │    │Payment Svc  │
│ GET /users  │    │POST /pay    │
└─────────────┘    └─────────────┘
       │                 │
       │                 ▼
       │          ┌─────────────┐
       │          │Payment      │
       │          │Processed    │
       │          │Event        │
       │          └─────────────┘
       │
       ▼
┌─────────────┐
│OrderCreated │
│Event        │
└──────┬──────┘
       │
       ├───────────────┐
       │               │
       ▼               ▼
┌─────────────┐  ┌─────────────┐
│Notification │  │ Analytics   │
│  Service    │  │  Service    │
└─────────────┘  └─────────────┘
```

### Error Handling

The service implements graceful degradation:
- If user-service is unavailable, order creation fails (critical dependency)
- If payment-service is unavailable, order is still created with `pending` status
- If notification-service is unavailable, order succeeds but events may be lost
- If analytics-service is unavailable, order succeeds but metrics not tracked

### Pre-seeded Data

The service comes with 2 pre-seeded orders:
- `ord-001`: John Doe's order (confirmed)
- `ord-002`: Jane Smith's order (pending)

### Integration Points

1. **User Validation**: Calls user-service to ensure user exists before creating order
2. **Payment Processing**: Creates payment through payment-service
3. **Event Publishing**: Sends OrderCreated and OrderUpdated events to:
   - notification-service (to send notifications)
   - analytics-service (to track metrics)

---

## License

MIT © KaChow Organisation
