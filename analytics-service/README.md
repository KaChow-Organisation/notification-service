# @kachow-organisation/analytics-service

> **Analytics and metrics service for KaChow microservices**

Collects events from all services, generates metrics, and produces reports for business intelligence.

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

The analytics-service is responsible for:
- **Event Collection** - Receiving events from all microservices
- **Metrics Aggregation** - Calculating statistics from event data
- **Report Generation** - Creating daily, weekly, and monthly reports
- **Data Analysis** - Providing insights into system behavior
- **Business Intelligence** - Supporting data-driven decisions

This service acts as the data warehouse and observability hub for the microservices ecosystem.

---

## API Endpoints

### POST `/events`

Receive events from other services for tracking and analysis.

**Request Body:**
```json
{
  "eventId": "evt-001",
  "eventType": "OrderCreated",
  "timestamp": "2024-01-21T14:30:00Z",
  "payload": {
    "orderId": "ord-001",
    "userId": "usr-001",
    "totalAmount": 109.97,
    "items": [...]
  }
}
```

**Response (200):**
```json
{
  "received": true,
  "eventType": "OrderCreated",
  "timestamp": "2024-01-21T14:30:01Z"
}
```

---

### GET `/metrics`

Retrieve metrics with optional filtering.

**Query Parameters:**
- `service` - Filter by service name (e.g., `order-service`)
- `metric` - Filter by metric name (e.g., `orders_created`)
- `from` - Start date (ISO 8601)
- `to` - End date (ISO 8601)
- `limit` - Maximum results (default: 100)

**Example:** `GET /metrics?service=order-service&from=2024-01-01`

**Response (200):**
```json
{
  "metrics": [
    {
      "id": "mtr-001",
      "service": "order-service",
      "metric": "orders_created",
      "value": 109.97,
      "timestamp": "2024-01-21T14:30:00Z",
      "tags": {
        "orderId": "ord-001",
        "userId": "usr-001"
      }
    }
  ],
  "count": 1,
  "summary": {
    "order-service.orders_created": {
      "count": 1,
      "total": 109.97,
      "avg": 109.97,
      "min": 109.97,
      "max": 109.97
    }
  },
  "totalRecorded": 150,
  "filters": {
    "service": "order-service",
    "metric": null,
    "from": "2024-01-01",
    "to": null
  }
}
```

---

### POST `/metrics`

Submit a metric directly (without an event).

**Request Body:**
```json
{
  "service": "custom-service",
  "metric": "custom_metric",
  "value": 42,
  "tags": {
    "environment": "production"
  }
}
```

**Response (201):**
```json
{
  "metric": {
    "id": "mtr-002",
    "service": "custom-service",
    "metric": "custom_metric",
    "value": 42,
    "timestamp": "2024-01-21T15:00:00Z",
    "tags": {
      "environment": "production"
    }
  },
  "message": "Metric recorded successfully"
}
```

---

### GET `/reports`

Generate analytics reports.

**Query Parameters:**
- `type` - Report type: `daily`, `weekly`, `monthly` (default: `daily`)
- `service` - Filter by specific service (optional)

**Example:** `GET /reports?type=daily&service=order-service`

**Response (200):**
```json
{
  "id": "rpt-001",
  "type": "daily",
  "service": "order-service",
  "generatedAt": "2024-01-21T15:00:00Z",
  "periodStart": "2024-01-20T15:00:00Z",
  "periodEnd": "2024-01-21T15:00:00Z",
  "totalEvents": 50,
  "data": [
    {
      "service": "order-service",
      "metric": "orders_created",
      "count": 10,
      "total": 1099.70,
      "average": 109.97,
      "min": 29.99,
      "max": 299.99
    }
  ]
}
```

---

### GET `/reports/:id`

Retrieve a previously generated report.

**Response (200):**
```json
{
  "id": "rpt-001",
  "type": "daily",
  "service": "all",
  "generatedAt": "2024-01-21T15:00:00Z",
  ...
}
```

**Error Response (404):**
```json
{
  "error": "Report not found",
  "reportId": "rpt-999"
}
```

---

### GET `/events`

List all recorded events.

**Query Parameters:**
- `type` - Filter by event type
- `from` - Start date
- `to` - End date
- `limit` - Maximum results (default: 50)

**Response (200):**
```json
{
  "events": [
    {
      "eventId": "evt-001",
      "eventType": "OrderCreated",
      "timestamp": "2024-01-21T14:30:00Z",
      "payload": {...},
      "receivedAt": "2024-01-21T14:30:01Z"
    }
  ],
  "count": 1,
  "totalRecorded": 100,
  "eventTypes": ["OrderCreated", "PaymentProcessed", "UserCreated"]
}
```

---

### GET `/health`

Health check endpoint.

**Response:**
```json
{
  "service": "analytics-service",
  "status": "healthy",
  "stats": {
    "totalEvents": 100,
    "totalMetrics": 150,
    "totalReports": 5,
    "eventTypes": 3
  },
  "recordedEventTypes": ["OrderCreated", "PaymentProcessed", "UserCreated"],
  "timestamp": "2024-01-21T15:00:00Z"
}
```

---

## Dependencies

### HTTP Dependencies (Outbound)

None - This service is purely a consumer of events and does not make outbound HTTP calls.

### Inbound Dependencies

| Service | Purpose | Endpoints Used |
|---------|---------|----------------|
| api-gateway | Routes analytics requests | All endpoints |
| order-service | Send order events | `POST /events` |
| payment-service | Send payment events | `POST /events` |
| user-service | Send user events | `POST /events` |
| notification-service | Send notification events | `POST /events` |

### Event Dependencies (Inbound Events)

| Event Type | Source | Description |
|------------|--------|-------------|
| `OrderCreated` | order-service | Track order metrics |
| `OrderUpdated` | order-service | Track order changes |
| `PaymentProcessed` | payment-service | Track payment success/failure |
| `UserCreated` | user-service | Track user registrations |
| `NotificationSent` | notification-service | Track notification delivery |
| `NotificationFailed` | notification-service | Track notification failures |

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
| PORT | 3006 | Service port (defined in shared-contracts) |

---

## Example Requests

### Submit Event

```bash
curl -X POST http://localhost:3006/events \
  -H "Content-Type: application/json" \
  -d '{
    "eventId": "evt-001",
    "eventType": "OrderCreated",
    "timestamp": "2024-01-21T14:30:00Z",
    "payload": {
      "orderId": "ord-001",
      "userId": "usr-001",
      "totalAmount": 109.97,
      "items": [{"productId": "prod-001", "quantity": 2, "unitPrice": 29.99}]
    }
  }'
```

### Get Metrics

```bash
curl "http://localhost:3006/metrics?service=order-service&limit=10"
```

### Generate Report

```bash
curl "http://localhost:3006/reports?type=daily"
```

### Get Events

```bash
curl "http://localhost:3006/events?type=OrderCreated&limit=5"
```

### Submit Direct Metric

```bash
curl -X POST http://localhost:3006/metrics \
  -H "Content-Type: application/json" \
  -d '{
    "service": "custom-service",
    "metric": "response_time_ms",
    "value": 150,
    "tags": {"endpoint": "/api/users"}
  }'
```

### Health Check

```bash
curl http://localhost:3006/health
```

---

## Architecture Notes

### Event Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Order     │     │   Payment   │     │    User     │
│   Service   │     │   Service   │     │   Service   │
└──────┬──────┘     └──────┬──────┘     └──────┬──────┘
       │ Emit Event         │ Emit Event         │ Emit Event
       │                    │                    │
       └────────────────────┼────────────────────┘
                            │
                            ▼
                    ┌─────────────┐
                    │  Analytics  │
                    │   Service   │
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
        ┌─────────┐  ┌─────────┐  ┌─────────┐
        │ Events  │  │ Metrics │  │ Reports │
        │  Store  │  │  Store  │  │  Store  │
        └─────────┘  └─────────┘  └─────────┘
```

### Metric Generation

Events automatically generate metrics:
- **OrderCreated** → `orders_created` metric (value = order total)
- **PaymentProcessed** → `payments_successful` or `payments_failed` (value = amount)
- **UserCreated** → `users_created` metric (value = 1)

### Storage

This service uses in-memory storage:
- `events[]` - Array of all received events
- `metrics[]` - Array of all recorded metrics
- `reports` - Map of generated reports

In production, use:
- Time-series database (InfluxDB, TimescaleDB)
- Data warehouse (BigQuery, Snowflake)
- Message queue for event buffering (Kafka, RabbitMQ)

### ⚠️ ARCHITECTURAL VIOLATION: Direct Order Data Access

**Issue**: The service has an undocumented endpoint `/orders/summary` that reconstructs order data directly from events.

**Why this is a violation**:
- Order data is the responsibility of `order-service`
- Reconstructing state from events creates data inconsistency risks
- Events may be incomplete or out of order
- No guarantee of data accuracy
- Violates the single responsibility principle

**Proper approach**:
- Call `GET /orders` on order-service to get order data
- Use events only for metrics, not for state reconstruction
- Maintain clear service boundaries

**Location**: `@c:\Documents\kachow_4\analytics-service\src\index.js:300-330`

---

## License

MIT © KaChow Organisation
