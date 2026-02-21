const express = require('express');
const cors = require('cors');
const { ServicePorts, schemas, validate } = require('@kachow-organisation/shared-contracts');

// Simple in-memory store for users (simulating a database)
const users = new Map([
  ['usr-001', { id: 'usr-001', username: 'john_doe', password: 'password123', email: 'john@example.com' }],
  ['usr-002', { id: 'usr-002', username: 'jane_smith', password: 'securepass456', email: 'jane@example.com' }],
  ['usr-003', { id: 'usr-003', username: 'bob_wilson', password: 'bobpass789', email: 'bob@example.com' }]
]);

// In-memory token store
const tokens = new Map();

const app = express();
const PORT = ServicePorts.AUTH_SERVICE;

// Middleware
app.use(cors());
app.use(express.json());

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

/**
 * Generate a simple mock JWT-like token
 * In production, use a proper JWT library like jsonwebtoken
 */
function generateToken(userId) {
  const header = Buffer.from(JSON.stringify({ alg: 'HS256', typ: 'JWT' })).toString('base64');
  const payload = Buffer.from(JSON.stringify({
    sub: userId,
    iat: Date.now(),
    exp: Date.now() + 24 * 60 * 60 * 1000 // 24 hours
  })).toString('base64');
  const signature = Buffer.from(`mock-signature-${userId}-${Date.now()}`).toString('base64');
  
  const token = `${header}.${payload}.${signature}`;
  
  // Store token for validation
  tokens.set(token, {
    userId,
    expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000)
  });
  
  return token;
}

function isTokenValid(token) {
  if (!tokens.has(token)) return false;
  
  const tokenData = tokens.get(token);
  return new Date() < tokenData.expiresAt;
}

// ============================================================================
// API ENDPOINTS
// ============================================================================

/**
 * POST /login
 * Authenticate user and return JWT token
 */
app.post('/login', (req, res) => {
  console.log('[AUTH-SERVICE] Login attempt:', req.body.username);
  
  // Validate request body
  const validation = validate(schemas.LoginRequestSchema, req.body);
  if (validation.error) {
    return res.status(400).json({
      error: 'Invalid request',
      details: validation.error.details
    });
  }
  
  const { username, password } = req.body;
  
  // Find user
  let foundUser = null;
  for (const user of users.values()) {
    if (user.username === username && user.password === password) {
      foundUser = user;
      break;
    }
  }
  
  if (!foundUser) {
    console.log('[AUTH-SERVICE] Login failed: Invalid credentials');
    return res.status(401).json({
      error: 'Invalid credentials'
    });
  }
  
  // Generate token
  const token = generateToken(foundUser.id);
  const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);
  
  console.log('[AUTH-SERVICE] Login successful for user:', foundUser.id);
  
  res.json({
    token,
    userId: foundUser.id,
    expiresAt: expiresAt.toISOString()
  });
});

/**
 * POST /validate
 * Validate a JWT token
 */
app.post('/validate', (req, res) => {
  console.log('[AUTH-SERVICE] Token validation request');
  
  // Validate request body
  const validation = validate(schemas.ValidateRequestSchema, req.body);
  if (validation.error) {
    return res.status(400).json({
      error: 'Invalid request',
      details: validation.error.details
    });
  }
  
  const { token } = req.body;
  const valid = isTokenValid(token);
  
  console.log('[AUTH-SERVICE] Token validation result:', valid);
  
  const response = { valid };
  if (valid) {
    response.userId = tokens.get(token).userId;
  }
  
  res.json(response);
});

// ============================================================================
// HEALTH CHECK
// ============================================================================

app.get('/health', (req, res) => {
  res.json({
    service: 'auth-service',
    status: 'healthy',
    timestamp: new Date().toISOString()
  });
});

// ============================================================================
// ERROR HANDLING
// ============================================================================

app.use((err, req, res, next) => {
  console.error('[AUTH-SERVICE] Error:', err);
  res.status(500).json({
    error: 'Internal server error'
  });
});

// ============================================================================
// START SERVER
// ============================================================================

app.listen(PORT, () => {
  console.log(`
========================================
  AUTH-SERVICE
  Listening on port ${PORT}
========================================
  Endpoints:
    POST /login    - Authenticate user
    POST /validate - Validate token
    GET  /health   - Health check
========================================
  `);
});

module.exports = app;
