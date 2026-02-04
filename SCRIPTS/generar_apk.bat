@echo off
echo 🚀 Generando APK para Yalitza Salas Bloom Mobile
echo.

REM Verificar si Flutter está instalado
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter no está instalado o no está en el PATH
    echo Por favor, instala Flutter primero siguiendo la guía INSTALACION_COMPLETA.md
    pause
    exit /b 1
)

echo ✅ Flutter encontrado
echo.

REM Instalar dependencias
echo 📦 Instalando dependencias...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Error al instalar dependencias
    pause
    exit /b 1
)

echo ✅ Dependencias instaladas
echo.

REM Generar código Drift
echo 🔧 Generando código de base de datos...
flutter packages pub run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo ❌ Error al generar código Drift
    pause
    exit /b 1
)

echo ✅ Código generado
echo.

REM Limpiar proyecto
echo 🧹 Limpiando proyecto...
flutter clean
flutter pub get

echo ✅ Proyecto limpio
echo.

REM Generar APK Release
echo 📱 Generando APK Release...
flutter build apk --release
if %errorlevel% neq 0 (
    echo ❌ Error al generar APK
    pause
    exit /b 1
)

echo.
echo ✅ APK generada exitosamente!
echo 📂 Ubicación: build\app\outputs\flutter-apk\app-release.apk
echo.

REM Preguntar si quiere abrir la carpeta
set /p abrir=¿Deseas abrir la carpeta de la APK? (S/N): 
if /i "%abrir%"=="S" (
    explorer "build\app\outputs\flutter-apk"
)

echo.
echo 🎯 Para probar la aplicación:
echo 1. Conecta un teléfono Android con depuración USB
echo 2. Ejecuta: adb install build\app\outputs\flutter-apk\app-release.apk
echo 3. O copia el archivo APK al teléfono e instálalo manualmente
echo.

pause
