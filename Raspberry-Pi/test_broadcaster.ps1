# STEMSight Broadcaster Pre-Flight Test Script

Write-Host "`n🧪 STEMSight Broadcaster Testing" -ForegroundColor Cyan
Write-Host "=================================`n" -ForegroundColor Cyan

$allPassed = $true

# 1. Check backend
Write-Host "1. Testing backend connection..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    Write-Host "   ✅ Backend running" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Backend not accessible" -ForegroundColor Red
    $allPassed = $false
}

# 2. Check frontend
Write-Host "`n2. Testing frontend connection..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    Write-Host "   ✅ Frontend running" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Frontend not accessible" -ForegroundColor Red
    $allPassed = $false
}

# 3. Check Python environment
Write-Host "`n3. Checking Python environment..." -ForegroundColor Yellow
if (Test-Path ".\venv\Scripts\python.exe") {
    Write-Host "   ✅ Virtual environment found" -ForegroundColor Green
} else {
    Write-Host "   ❌ Virtual environment not found" -ForegroundColor Red
    $allPassed = $false
}

# 4. Check FFMPEG
Write-Host "`n4. Checking FFMPEG..." -ForegroundColor Yellow
try {
    $null = ffmpeg -version 2>&1
    Write-Host "   ✅ FFMPEG installed" -ForegroundColor Green
} catch {
    Write-Host "   ❌ FFMPEG not found" -ForegroundColor Red
    $allPassed = $false
}

# Summary
Write-Host "`n==================================================" -ForegroundColor Cyan
if ($allPassed) {
    Write-Host "✅ All checks passed! Ready to test.`n" -ForegroundColor Green
    Write-Host "Quick Start Commands:" -ForegroundColor Yellow
    Write-Host "  .\venv\Scripts\Activate.ps1"
    Write-Host "  python rpi_broadcaster.py --ambulance_number 001 --room 001 --video_device 'Logitech BRIO'"
    Write-Host "  python rpi_multi_broadcaster.py --config config\multi_camera_config.json`n"
} else {
    Write-Host "❌ Some checks failed. Fix issues above.`n" -ForegroundColor Red
}
