# Script para instalar Android SDK automáticamente
# Ejecutar como Administrador

Write-Host "🔧 Instalador Automático de Android SDK para Flutter" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Yellow

# Crear directorio para Android SDK
$androidSdkPath = "C:\Android\Sdk"
if (!(Test-Path $androidSdkPath)) {
    New-Item -ItemType Directory -Path $androidSdkPath -Force
    Write-Host "✅ Directorio creado: $androidSdkPath" -ForegroundColor Green
}

# Descargar command line tools
Write-Host "📥 Descargando Android Command Line Tools..." -ForegroundColor Yellow
$downloadUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$zipPath = "$env:TEMP\commandlinetools-win.zip"
$extractPath = "$env:TEMP\cmdline-tools"

try {
    # Descargar usando Invoke-WebRequest
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath
    Write-Host "✅ Descarga completada" -ForegroundColor Green
    
    # Extraer
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
    Write-Host "✅ Archivos extraídos" -ForegroundColor Green
    
    # Mover a la estructura correcta
    $toolsPath = "$androidSdkPath\cmdline-tools\latest"
    if (!(Test-Path $toolsPath)) {
        New-Item -ItemType Directory -Path $toolsPath -Force
    }
    
    Get-ChildItem "$extractPath\cmdline-tools" | Move-Item -Destination $toolsPath
    
    # Configurar variables de entorno
    [Environment]::SetEnvironmentVariable("ANDROID_HOME", $androidSdkPath, "User")
    [Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $androidSdkPath, "User")
    
    $pathValue = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($pathValue -notlike "*$androidSdkPath*") {
        [Environment]::SetEnvironmentVariable("PATH", "$pathValue;$androidSdkPath\cmdline-tools\latest\bin;$androidSdkPath\platform-tools", "User")
    }
    
    Write-Host "✅ Variables de entorno configuradas" -ForegroundColor Green
    
    # Instalar paquetes necesarios
    Write-Host "📦 Instalando paquetes Android SDK..." -ForegroundColor Yellow
    & "$toolsPath\bin\sdkmanager.bat" "platform-tools" "platforms;android-34" "build-tools;34.0.0"
    
    Write-Host "🎉 ¡Android SDK instalado exitosamente!" -ForegroundColor Green
    Write-Host "📍 Ubicación: $androidSdkPath" -ForegroundColor Cyan
    Write-Host "🔄 Reinicia tu terminal para que los cambios surtan efecto" -ForegroundColor Yellow
    
} catch {
    Write-Host "❌ Error durante la instalación: $_" -ForegroundColor Red
    Write-Host "💡 Alternativa: Instala Android Studio manualmente desde https://developer.android.com/studio" -ForegroundColor Yellow
}

# Limpiar archivos temporales
Remove-Item $zipPath -ErrorAction SilentlyContinue
Remove-Item $extractPath -Recurse -ErrorAction SilentlyContinue

Write-Host "=================================================" -ForegroundColor Yellow
Write-Host "✨ Proceso completado" -ForegroundColor Cyan
