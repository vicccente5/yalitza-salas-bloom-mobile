@echo off
echo 🔍 Verificando configuración de Android Studio
echo.

echo 📊 Estado actual de Flutter:
"C:\Users\xvice\Desktop\flutter\bin\flutter.bat" doctor

echo.
echo 📱 Verificando emuladores disponibles:
"C:\Users\xvice\Desktop\flutter\bin\flutter.bat" emulators

echo.
echo 🔌 Verificando dispositivos conectados:
"C:\Users\xvice\Desktop\flutter\bin\flutter.bat" devices

echo.
echo 📋 Resumen de configuración:
echo.

REM Verificar variables de entorno
echo %ANDROID_HOME% | findstr /C:"ANDROID_HOME" >nul
if %errorlevel% equ 0 (
    echo ✅ ANDROID_HOME está configurada
) else (
    echo ❌ ANDROID_HOME no está configurada
)

echo %PATH% | findstr /C:"platform-tools" >nul
if %errorlevel% equ 0 (
    echo ✅ Android platform-tools está en el PATH
) else (
    echo ❌ Android platform-tools no está en el PATH
)

REM Verificar si existe el directorio de Android SDK
if exist "%ANDROID_HOME%" (
    echo ✅ Directorio Android SDK encontrado
) else (
    echo ❌ Directorio Android SDK no encontrado
)

echo.
echo 🎯 Próximos pasos recomendados:
echo 1. Si hay ❌ en alguna sección, sigue la guía CONFIGURAR_ANDROID_STUDIO.md
echo 2. Si todo está ✅, puedes ejecutar: flutter run
echo 3. Para crear emulador: abre Android Studio → Tools → AVD Manager
echo.

pause
