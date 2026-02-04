# Script de Instalación Automática de Flutter y Dependencias
# Ejecutar como Administrador en PowerShell

Write-Host "🚀 Iniciando instalación de Flutter SDK..." -ForegroundColor Green

# Verificar si Chocolatey está instalado
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "📦 Instalando Chocolatey..." -ForegroundColor Yellow
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Instalar Flutter
Write-Host "📦 Instalando Flutter SDK..." -ForegroundColor Yellow
choco install flutter -y

# Instalar Git
Write-Host "📦 Instalando Git..." -ForegroundColor Yellow
choco install git -y

# Instalar Android Studio
Write-Host "📦 Instalando Android Studio..." -ForegroundColor Yellow
choco install androidstudio -y

# Configurar variables de entorno
Write-Host "⚙️ Configurando variables de entorno..." -ForegroundColor Yellow
$flutterPath = "C:\ProgramData\chocolatey\lib\flutter\tools\flutter"
if (Test-Path $flutterPath) {
    [Environment]::SetEnvironmentVariable("FLUTTER_ROOT", $flutterPath, "Machine")
    $path = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($path -notlike "*$flutterPath\bin*") {
        [Environment]::SetEnvironmentVariable("Path", $path + ";$flutterPath\bin", "Machine")
    }
}

Write-Host "✅ Instalación completada!" -ForegroundColor Green
Write-Host "🔄 Por favor, reinicia tu PC y ejecuta los siguientes comandos:" -ForegroundColor Cyan
Write-Host "   flutter --version" -ForegroundColor White
Write-Host "   flutter doctor" -ForegroundColor White
Write-Host "   flutter doctor --android-licenses" -ForegroundColor White
