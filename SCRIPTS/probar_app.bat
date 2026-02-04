@echo off
echo 🧪 Probando Yalitza Salas Bloom Mobile
echo.

REM Verificar si Flutter está instalado
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter no está instalado
    pause
    exit /b 1
)

echo ✅ Flutter encontrado
echo.

REM Verificar dependencias
echo 📦 Verificando dependencias...
flutter pub get

REM Generar código Drift si es necesario
echo 🔧 Verificando código de base de datos...
flutter packages pub run build_runner build --delete-conflicting-outputs

echo.
echo 📱 Opciones de prueba:
echo.
echo 1. Emulador Android
echo 2. Navegador Web (Chrome)
echo 3. Dispositivo Físico Conectado
echo 4. Ver dispositivos disponibles
echo.

set /p opcion=Selecciona una opción (1-4): 

if "%opcion%"=="1" (
    echo 🚀 Iniciando emulador...
    flutter emulators
    set /p emulator=Nombre del emulador: 
    flutter emulators --launch %emulator%
    timeout /t 10 /nobreak >nul
    flutter run
) else if "%opcion%"=="2" (
    echo 🌐 Iniciando en navegador web...
    flutter run -d chrome
) else if "%opcion%"=="3" (
    echo 📱 Verificando dispositivos conectados...
    flutter devices
    echo.
    echo Asegúrate de que tu dispositivo esté conectado con depuración USB activada
    pause
    flutter run
) else if "%opcion%"=="4" (
    echo 📋 Dispositivos disponibles:
    flutter devices
    echo.
    echo Para usar un dispositivo específico:
    echo flutter run -d <device_id>
    pause
) else (
    echo ❌ Opción no válida
    pause
)

echo.
echo 🎯 Si la aplicación funciona correctamente, puedes generar la APK con:
echo SCRIPTS\generar_apk.bat
echo.

pause
