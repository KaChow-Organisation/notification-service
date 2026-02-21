# @kachow-organisation/payment-service

> **Payment processing service for KaChow microservices**

Handles payment authorization, processing, and transaction management for the KaChow e-commerce platform.

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

The payment-service is responsible for:
- **Payment Processing** - Authorizing and processing payments
- **Transaction Management** - Tracking payment status and history
- **Payment Validation** - Ensuring payment data is correct
- **Refund Processing** - Handling payment refunds
- **Event Publishing** - Notifying other services about payment status

This service acts as the financial gateway for the order processing workflow.

---

## API Endpoints

### POST `/payments`

Create and process a new payment.

**Request Body:**
```json
{
  "orderId": "ord-001",
  "amount": 109.97,
  "currency": "USD",
  "paymentMethod": "card"
}
```

**Payment Methods:**
- `card` - Credit/Debit card
- `bank_transfer` - Bank wire transfer
- `paypal` - PayPal payment

**Currencies:**
- `USD` - US Dollar (default)
- `EUR` - Euro
- `GBP` - British Pound

**Success Response (201):**
```json
{
  "id": "pay-001",
  "orderId": "ord-001",
  "amount": 109.97,
  "currency": "USD",
  "status": "completed",
  "paymentMethod": "card",
  "transactionId": "txn_abc123xyz789",
  "processedAt": "2024-01-21T14:32:15.000Z"
}
```

**Failed Response (402):**
```json
{
  "id": "pay-002",
  "orderId": "ord-002",
  "amount": 59.97,
  "currency": "USD",
  "status": "failed",
  "paymentMethod": "card",
  "transactionId": null,
  "processedAt": "2024-01-21T14:33:20.000Z",
  "error": "Payment declined by processor"
}
```

**Error Response (400) - Validation:**
```json
{
  "error": "Invalid request",
  "details": [...]
}
```

---

### GET `/payments/:id`

Get payment details by ID.

**Parameters:**
- `id` (path) - Payment ID (e.g., `pay-001`)

**Response (200):**
```json
{
  "id": "pay-001",
  "orderId": "ord-001",
  "amount": 109.97,
  "currency": "USD",
  "status": "completed",
  "paymentMethod": "card",
  "createdAt": "2024-01-20T10:00:00Z",
  "processedAt": "2024-01-20T10:05:00Z",
  "transactionId": "txn_1234567890"
}
```

**Error Response (404):**
```json
{
  "error": "Payment not found",
  "paymentId": "pay-999"
}
```

---

### GET `/payments`

List all payments.

**Response (200):**
```json
{
  "payments": [
    {
      "id": "pay-001",
      "orderId": "ord-001",
      "amount": 109.97,
      "currency": "USD",
      "status": "completed",
      ...
    }
  ],
  "count": 1
}
```

---

### POST `/payments/:id/refund`

Refund a completed payment.

**Parameters:**
- `id` (path) - Payment ID

**Response (200) - Success:**
```json
{
  "payment": {
    "id": "pay-001",
    "orderId": "ord-001",
    "amount": 109.97,
    "currency": "USD",
    "status": "refunded",
    "refundedAt": "2024-01-21T15:00:00Z",
    "refundTransactionId": "txn_refund_abc123"
  },
  "message": "Payment refunded successfully"
}
```

**Error Response (400) - Not completed:**
```json
{
  "error": "Cannot refund",
  "message": "Payment status is pending, only completed payments can be refunded"
}
```

---

### GET `/health`

Health check endpoint.

**Response:**
```json
{
  "service": "payment-service",
  "status": "healthy",
  "stats": {
    "total": 1,
    "completed": 1,
    "failed": 0,
    "pending": 0
  },
  "timestamp": "2024-01-21T14:32:00.000Z"
}
```

---

## Dependencies

### HTTP Dependencies (Outbound)

| Service | Purpose | Endpoint Used | Critical |
|---------|---------|---------------|----------|
| notification-service | Send payment events | `POST /events` | No |
| analytics-service | Send payment events | `POST /events` | No |

### Inbound Dependencies

| Service | Purpose | Endpoints Used |
|---------|---------|----------------|
| api-gateway | Routes payment requests | All endpoints |
| order-service | Create payments for orders | `POST /payments` |

### Event Dependencies (Outbound Events)

| Event Type | Description | When Emitted | Payload |
|------------|-------------|--------------|---------|
| `PaymentProcessed` | Payment completed or failed | After payment processing | `{ paymentId, orderId, status, amount, currency, transactionId, processedAt, error }` |
| `PaymentFailed` | Payment refund processed | After refund | `{ paymentId, orderId, reason, amount, refundedAt, refundTransactionId }` |

### Event Dependencies (Inbound Events)

None - This service does not listen for events.

---

## Running the Service

### Prerequisites

- Node.js 16+
- npm
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
| PORT | 3004 | Service port (defined in shared-contracts) |

---

## Example Requests

### Create Payment

```bash
curl -X POST http://localhost:3004/payments \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "ord-001",
    "amount": 99.99,
    "currency": "USD",
    "paymentMethod": "card"
  }'
```

### Get Payment

```bash
curl http://localhost:3004/payments/pay-001
```

### List All Payments

```bash
curl http://localhost:3004/payments
```

### Refund Payment

```bash
curl -X POST http://localhost:3004/payments/pay-001/refund
```

### Health Check

```bash
curl http://localhost:3004/health
```

---

## Architecture Notes

### Payment Processing Flow

```
┌─────────────┐
│   Order     │
│   Service   │
└──────┬──────┘
       │ POST /payments
       ▼
┌─────────────┐
│  Payment    │
│  Service    │
└──────┬──────┘
       │
       ├─▶ Validate request
       ├─▶ Create payment record (pending)
       ├─▶ Process payment (simulated)
       ├─▶ Update payment record (completed/failed)
       └─▶ Emit PaymentProcessed event
       │
       ▼
┌─────────────┐      ┌─────────────┐
│Notification │      │  Analytics  │
│  Service    │      │  Service    │
└─────────────┘      └─────────────┘
```

### Payment Simulation

This service uses simulated payment processing:
- 90% success rate (random)
- 1-second processing delay
- Mock transaction IDs generated
- No real payment gateway integration

For production use, integrate with:
- Stripe
- PayPal
- Square
- Braintree
- Or other payment processor

### Payment States

```
┌─────────┐    ┌───────────┐    ┌───────────┐
│ PENDING │───▶│COMPLETED  │───▶│ REFUNDED  │
└─────────┘    └───────────┘    └───────────┘
       │
       ▼
┌───────────┐
│  FAILED   │
└───────────┘
```

### Pre-seeded Data

The service comes with 1 pre-seeded payment:
- `pay-001`: Completed payment for order `ord-001`

### Integration Points

1. **Called by**: order-service creates payments when processing orders
2. **Event Publishing**: Sends PaymentProcessed events to:
   - notification-service (to send payment confirmations)
   - analytics-service (to track revenue metrics)

---

## License

MIT © KaChow Organisation
