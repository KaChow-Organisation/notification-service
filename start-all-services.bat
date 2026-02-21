@echo off
REM ============================================
REM KaChow Microservices Startup Script
REM ============================================

echo Starting KaChow Microservices...
echo.

REM Kill any existing node processes on these ports (optional)
echo Cleaning up existing processes...
for /f "tokens=5" %%a in ('netstat -aon ^| find ":3000" ^| find "LISTENING"') do taskkill /F /PID %%a 2>nul
for /f "tokens=5" %%a in ('netstat -aon ^| find ":3001" ^| find "LISTENING"') do taskkill /F /PID %%a 2>nul
for /f "tokens=5" %%a in ('netstat -aon ^| find ":3002" ^| find "LISTENING"') do taskkill /F /PID %%a 2>nul
for /f "tokens=5" %%a in ('netstat -aon ^| find ":3003" ^| find "LISTENING"') do taskkill /F /PID %%a 2>nul
for /f "tokens=5" %%a in ('netstat -aon ^| find ":3004" ^| find "LISTENING"') do taskkill /F /PID %%a 2>nul
for /f "tokens=5" %%a in ('netstat -aon ^| find ":3005" ^| find "LISTENING"') do taskkill /F /PID %%a 2>nul
for /f "tokens=5" %%a in ('netstat -aon ^| find ":3006" ^| find "LISTENING"') do taskkill /F /PID %%a 2>nul
timeout /t 2 /nobreak >nul

echo.
echo ============================================
echo Starting Services in Order
echo ============================================
echo.

REM 1. Start shared-contracts (just installs, no server)
echo [1/8] Installing shared-contracts...
cd /d "%~dp0shared-contracts"
call npm install >nul 2>&1
cd /d "%~dp0"

REM 2. Start auth-service
echo [2/8] Starting auth-service on port 3001...
start "auth-service (3001)" cmd /k "cd /d "%~dp0auth-service" && npm install && npm start"
timeout /t 3 /nobreak >nul

REM 3. Start user-service
echo [3/8] Starting user-service on port 3002...
start "user-service (3002)" cmd /k "cd /d "%~dp0user-service" && npm install && npm start"
timeout /t 3 /nobreak >nul

REM 4. Start order-service
echo [4/8] Starting order-service on port 3003...
start "order-service (3003)" cmd /k "cd /d "%~dp0order-service" && npm install && npm start"
timeout /t 3 /nobreak >nul

REM 5. Start payment-service
echo [5/8] Starting payment-service on port 3004...
start "payment-service (3004)" cmd /k "cd /d "%~dp0payment-service" && npm install && npm start"
timeout /t 3 /nobreak >nul

REM 6. Start notification-service
echo [6/8] Starting notification-service on port 3005...
start "notification-service (3005)" cmd /k "cd /d "%~dp0notification-service" && npm install && npm start"
timeout /t 3 /nobreak >nul

REM 7. Start analytics-service
echo [7/8] Starting analytics-service on port 3006...
start "analytics-service (3006)" cmd /k "cd /d "%~dp0analytics-service" && npm install && npm start"
timeout /t 3 /nobreak >nul

REM 8. Start API Gateway (last)
echo [8/8] Starting api-gateway on port 3000...
start "api-gateway (3000)" cmd /k "cd /d "%~dp0api-gateway" && npm install && npm start"

echo.
echo ============================================
echo All Services Starting...
echo ============================================
echo.
echo Service URLs:
echo   API Gateway:     http://localhost:3000
echo   Auth Service:    http://localhost:3001
echo   User Service:    http://localhost:3002
echo   Order Service:   http://localhost:3003
echo   Payment Service: http://localhost:3004
echo   Notification:    http://localhost:3005
echo   Analytics:       http://localhost:3006
echo.
echo Testing Commands:
echo   curl http://localhost:3000/health
echo   curl http://localhost:3000/auth/login -X POST -H "Content-Type: application/json" -d "{\"username\":\"john_doe\",\"password\":\"password123\"}"
echo.
echo Press Ctrl+C in each window to stop services.
echo.
pause
