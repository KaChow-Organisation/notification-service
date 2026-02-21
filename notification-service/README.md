# @kachow-organisation/notification-service

> **Notification service for KaChow microservices**

Handles email, SMS, and push notifications by listening to events and sending notifications to users.

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

The notification-service is responsible for:
- **Event-Driven Notifications** - Listening to events and sending automatic notifications
- **Direct Notifications** - Accepting direct notification requests
- **Multi-Channel Support** - Email, SMS, and push notifications
- **User Context** - Fetching user details to personalize notifications
- **Notification Tracking** - Tracking notification delivery status

This service acts as the communication hub for all user-facing notifications.

---

## API Endpoints

### POST `/events`

Webhook endpoint for receiving events from other services.

**Request Body (OrderCreated):**
```json
{
  "eventId": "evt-001",
  "eventType": "OrderCreated",
  "timestamp": "2024-01-21T14:30:00Z",
  "payload": {
    "orderId": "ord-001",
    "userId": "usr-001",
    "totalAmount": 109.97,
    "items": [...],
    "status": "pending"
  }
}
```

**Request Body (PaymentProcessed):**
```json
{
  "eventId": "evt-002",
  "eventType": "PaymentProcessed",
  "timestamp": "2024-01-21T14:31:00Z",
  "payload": {
    "paymentId": "pay-001",
    "orderId": "ord-001",
    "status": "completed",
    "amount": 109.97,
    "transactionId": "txn_abc123"
  }
}
```

**Response (200):**
```json
{
  "received": true,
  "eventType": "OrderCreated"
}
```

---

### POST `/notify`

Send a direct notification to a user.

**Request Body:**
```json
{
  "userId": "usr-001",
  "type": "email",
  "subject": "Welcome to KaChow!",
  "message": "Hi John, welcome to our platform! We're excited to have you."
}
```

**Notification Types:**
- `email` - Email notification
- `sms` - SMS text message
- `push` - Push notification

**Success Response (201):**
```json
{
  "notification": {
    "id": "ntf-001",
    "userId": "usr-001",
    "type": "email",
    "subject": "Welcome to KaChow!",
    "message": "Hi John, welcome to our platform!...",
    "status": "sent",
    "createdAt": "2024-01-21T15:00:00Z",
    "sentAt": "2024-01-21T15:00:01Z"
  },
  "message": "Notification sent successfully"
}
```

**Error Response (404) - User not found:**
```json
{
  "error": "User not found",
  "userId": "usr-999"
}
```

---

### GET `/notifications`

List all notifications.

**Response (200):**
```json
{
  "notifications": [
    {
      "id": "ntf-001",
      "userId": "usr-001",
      "type": "email",
      "subject": "Order Confirmation",
      "message": "...",
      "status": "sent",
      "relatedOrderId": "ord-001",
      "eventType": "OrderCreated",
      "createdAt": "2024-01-21T14:30:00Z",
      "sentAt": "2024-01-21T14:30:01Z"
    }
  ],
  "count": 1
}
```

---

### GET `/notifications/:id`

Get notification by ID.

**Response (200):**
```json
{
  "id": "ntf-001",
  "userId": "usr-001",
  "type": "email",
  "subject": "Order Confirmation",
  "message": "...",
  "status": "sent",
  ...
}
```

---

### GET `/health`

Health check endpoint.

**Response:**
```json
{
  "service": "notification-service",
  "status": "healthy",
  "stats": {
    "total": 5,
    "sent": 4,
    "failed": 1,
    "pending": 0
  },
  "timestamp": "2024-01-21T15:00:00Z"
}
```

---

## Dependencies

### HTTP Dependencies (Outbound)

| Service | Purpose | Endpoint Used | Critical |
|---------|---------|---------------|----------|
| user-service | Get user contact info | `GET /users/:id` | Yes |
| order-service | Get order details | `GET /orders/:id` | Yes (for payment events) |

### Inbound Dependencies

| Service | Purpose | Endpoints Used |
|---------|---------|----------------|
| api-gateway | Routes notification requests | All public endpoints |
| order-service | Send order events | `POST /events` |
| payment-service | Send payment events | `POST /events` |
| analytics-service | Send analytics events | `POST /events` |

### Event Dependencies (Inbound Events)

| Event Type | Source | Description | Action Taken |
|------------|--------|-------------|--------------|
| `OrderCreated` | order-service | New order placed | Send order confirmation email |
| `PaymentProcessed` | payment-service | Payment status update | Send payment confirmation or failure email |

### Event Dependencies (Outbound Events)

None - This service does not emit events.

---

## Running the Service

### Prerequisites

- Node.js 16+
- npm
- user-service must be running on port 3002
- order-service must be running on port 3003 (for payment notifications)

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
| PORT | 3005 | Service port (defined in shared-contracts) |

---

## Example Requests

### Receive Event (OrderCreated)

```bash
curl -X POST http://localhost:3005/events \
  -H "Content-Type: application/json" \
  -d '{
    "eventId": "evt-001",
    "eventType": "OrderCreated",
    "timestamp": "2024-01-21T14:30:00Z",
    "payload": {
      "orderId": "ord-001",
      "userId": "usr-001",
      "totalAmount": 109.97,
      "items": [
        {
          "productId": "prod-001",
          "quantity": 2,
          "unitPrice": 29.99
        }
      ]
    }
  }'
```

### Send Direct Notification

```bash
curl -X POST http://localhost:3005/notify \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "usr-001",
    "type": "email",
    "subject": "Welcome!",
    "message": "Hi there! Welcome to KaChow."
  }'
```

### List Notifications

```bash
curl http://localhost:3005/notifications
```

### Health Check

```bash
curl http://localhost:3005/health
```

---

## Architecture Notes

### Event-Driven Notification Flow

```
┌─────────────┐
│ Order/Pmt   │
│  Service    │
└──────┬──────┘
       │ Emit Event
       ▼
┌─────────────┐
│   Event     │
│    Bus      │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│Notification │
│  Service    │
└──────┬──────┘
       │
       ├───────────────┐
       ▼               ▼
┌─────────────┐  ┌─────────────┐
│User Service │  │Order Service│
│  GET /user  │  │ GET /order  │
└─────────────┘  └─────────────┘
       │
       ▼
┌─────────────┐
│  Send Email │
│  Send SMS   │
│  Push Notif │
└─────────────┘
```

### Notification Processing

1. **Event Reception**: Service receives event via `POST /events`
2. **Acknowledgment**: Returns 200 immediately (async processing)
3. **Context Gathering**: 
   - Fetches user details from user-service
   - Fetches order details from order-service (if needed)
4. **Message Generation**: Creates personalized message
5. **Delivery**: Attempts to send via specified channel
6. **Tracking**: Records notification status (sent/failed)

### Notification Simulation

This service uses simulated notification delivery:
- 95% success rate (random)
- 500ms simulated delay
- No real email/SMS gateway integration

For production use, integrate with:
- **Email**: SendGrid, AWS SES, Mailgun
- **SMS**: Twilio, AWS SNS, Vonage
- **Push**: Firebase FCM, AWS SNS, OneSignal

### Integration Points

1. **Listens to**: OrderCreated and PaymentProcessed events
2. **Calls**: user-service for contact info, order-service for order details
3. **Tracks**: All notifications with delivery status

---

## License

MIT © KaChow Organisation
