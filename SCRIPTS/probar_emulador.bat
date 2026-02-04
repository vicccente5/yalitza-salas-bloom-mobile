@echo off
echo 📱 Probando aplicación en emulador Android
echo.

REM Verificar si Flutter está disponible
"C:\Users\xvice\Desktop\flutter\bin\flutter.bat" --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter no está disponible
    pause
    exit /b 1
)

echo ✅ Flutter encontrado
echo.

REM Verificar dispositivos disponibles
echo 📋 Dispositivos disponibles:
"C:\Users\xvice\Desktop\flutter\bin\flutter.bat" devices

echo.
REM Verificar emuladores disponibles
echo 📱 Emuladores disponibles:
"C:\Users\xvice\Desktop\flutter\bin\flutter.bat" emulators

echo.
echo 🚀 Opciones para probar:
echo.
echo 1. Iniciar emulador y ejecutar aplicación
echo 2. Ejecutar en navegador web (Chrome)
echo 3. Ver dispositivos conectados
echo 4. Salir
echo.

set /p opcion=Selecciona una opción (1-4): 

if "%opcion%"=="1" (
    echo 🔄 Iniciando emulador...
    "C:\Users\xvice\Desktop\flutter\bin\flutter.bat" emulators --launch <emulator_name>
    timeout /t 10 /nobreak >nul
    echo 📱 Ejecutando aplicación...
    "C:\Users\xvice\Desktop\flutter\bin\flutter.bat" run
) else if "%opcion%"=="2" (
    echo 🌐 Ejecutando en navegador web...
    "C:\Users\xvice\Desktop\flutter\bin\flutter.bat" run -d chrome
) else if "%opcion%"=="3" (
    echo 📋 Verificando dispositivos...
    "C:\Users\xvice\Desktop\flutter\bin\flutter.bat" devices
    echo.
    echo Para ejecutar en un dispositivo específico:
    echo flutter run -d <device_id>
    pause
) else if "%opcion%"=="4" (
    echo 👋 Saliendo...
    exit /b 0
) else (
    echo ❌ Opción no válida
    pause
)

echo.
echo 🎯 Si quieres generar una nueva APK:
echo flutter build apk --release
echo.

pause
