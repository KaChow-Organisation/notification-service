@echo off
REM ============================================
REM KaChow Microservices Test Script
REM Run this after starting all services
REM ============================================

echo ============================================
echo KaChow Microservices Test Suite
echo ============================================
echo.
echo Make sure all services are running first!
echo Run: start-all-services.bat
echo.
pause

echo.
echo [TEST 1/10] Testing API Gateway Health...
curl -s http://localhost:3000/health | findstr "api-gateway" >nul && (
    echo [PASS] API Gateway is running
) || (
    echo [FAIL] API Gateway not responding
)

echo.
echo [TEST 2/10] Testing Auth Service...
curl -s -X POST http://localhost:3000/auth/login -H "Content-Type: application/json" -d "{\"username\":\"john_doe\",\"password\":\"password123\"}" | findstr "token" >nul && (
    echo [PASS] Auth login working
) || (
    echo [FAIL] Auth login failed
)

echo.
echo [TEST 3/10] Testing User Service...
curl -s http://localhost:3000/users | findstr "john_doe" >nul && (
    echo [PASS] User list working
) || (
    echo [FAIL] User list failed
)

curl -s http://localhost:3000/users/usr-001 | findstr "John Doe" >nul && (
    echo [PASS] Get user by ID working
) || (
    echo [FAIL] Get user by ID failed
)

echo.
echo [TEST 4/10] Testing Order Service...
curl -s http://localhost:3000/orders | findstr "ord-001" >nul && (
    echo [PASS] Order list working
) || (
    echo [FAIL] Order list failed
)

curl -s http://localhost:3000/orders/ord-001 | findstr "totalAmount" >nul && (
    echo [PASS] Get order by ID working
) || (
    echo [FAIL] Get order by ID failed
)

echo.
echo [TEST 5/10] Testing Payment Service...
curl -s http://localhost:3000/payments | findstr "pay-001" >nul && (
    echo [PASS] Payment list working
) || (
    echo [FAIL] Payment list failed
)

echo.
echo [TEST 6/10] Testing Notification Service...
curl -s http://localhost:3000/notifications | findstr "notification" >nul && (
    echo [PASS] Notification list accessible
) || (
    echo [FAIL] Notification list failed
)

echo.
echo [TEST 7/10] Testing Analytics Service...
curl -s http://localhost:3000/analytics/health | findstr "analytics-service" >nul && (
    echo [PASS] Analytics service running
) || (
    echo [FAIL] Analytics service not responding
)

echo.
echo [TEST 8/10] Testing Cross-Service: Create Order...
curl -s -X POST http://localhost:3000/orders -H "Content-Type: application/json" -d "{\"userId\":\"usr-001\",\"items\":[{\"productId\":\"prod-001\",\"quantity\":1,\"unitPrice\":29.99}]}" | findstr "order\"" >nul && (
    echo [PASS] Order creation (cross-service) working
) || (
    echo [FAIL] Order creation failed - user-service may not be running
)

echo.
echo [TEST 9/10] Testing Event Flow...
timeout /t 2 /nobreak >nul
curl -s http://localhost:3000/analytics/events | findstr "OrderCreated" >nul && (
    echo [PASS] Event tracking working
) || (
    echo [INFO] No events yet (notification-service may not have sent events)
)

echo.
echo [TEST 10/10] Testing Metrics...
curl -s http://localhost:3000/analytics/metrics | findstr "metrics" >nul && (
    echo [PASS] Metrics endpoint working
) || (
    echo [FAIL] Metrics endpoint failed
)

echo.
echo ============================================
echo Test Suite Complete!
echo ============================================
echo.
echo If all tests pass, your microservices are ready!
echo.
pause
