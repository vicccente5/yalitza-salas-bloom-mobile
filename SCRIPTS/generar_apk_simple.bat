@echo off
echo 🚀 Generando APK para Yalitza Salas Bloom Mobile
echo.

REM Verificar si Flutter está instalado
"C:\Users\xvice\Desktop\flutter\bin\flutter.bat" --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter no está instalado o no está en la ruta correcta
    echo Por favor, verifica que Flutter esté en C:\Users\xvice\Desktop\flutter\bin\
    pause
    exit /b 1
)

echo ✅ Flutter encontrado
echo.

REM Instalar dependencias
echo 📦 Instalando dependencias...
"C:\Users\xvice\Desktop\flutter\bin\flutter.bat" pub get
if %errorlevel% neq 0 (
    echo ❌ Error al instalar dependencias
    pause
    exit /b 1
)

echo ✅ Dependencias instaladas
echo.

REM Generar código Drift (si es necesario)
echo 🔧 Generando código de base de datos...
"C:\Users\xvice\Desktop\flutter\bin\flutter.bat" packages pub run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo ⚠️ Advertencias en generación de código, pero continuando...
)

echo ✅ Código generado
echo.

REM Limpiar proyecto
echo 🧹 Limpiando proyecto...
"C:\Users\xvice\Desktop\flutter\bin\flutter.bat" clean
"C:\Users\xvice\Desktop\flutter\bin\flutter.bat" pub get

echo ✅ Proyecto limpio
echo.

REM Verificar si Android toolchain está disponible
echo 🔍 Verificando Android toolchain...
"C:\Users\xvice\Desktop\flutter\bin\flutter.bat" doctor --android-licenses >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️ Android toolchain no está completamente configurado
    echo Intentando generar APK de todos modos...
    echo.
    echo Si esto falla, necesitas:
    echo 1. Instalar Android Studio
    echo 2. Crear un emulador Android
    echo 3. Aceptar licencias: flutter doctor --android-licenses
    echo.
)

REM Generar APK Release
echo 📱 Generando APK Release...
"C:\Users\xvice\Desktop\flutter\bin\flutter.bat" build apk --release
if %errorlevel% neq 0 (
    echo ❌ Error al generar APK
    echo.
    echo Posibles soluciones:
    echo 1. Instalar Android Studio desde: https://developer.android.com/studio
    echo 2. Configurar ANDROID_HOME environment variable
    echo 3. Aceptar licencias Android: flutter doctor --android-licenses
    echo.
    pause
    exit /b 1
)

echo.
echo ✅ APK generada exitosamente!
echo 📂 Ubicación: build\app\outputs\flutter-apk\app-release.apk
echo.

REM Verificar si el archivo existe
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo 📊 Tamaño del APK:
    dir "build\app\outputs\flutter-apk\app-release.apk" | find "app-release.apk"
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
    echo 📱 La aplicación incluye:
    echo - ✅ Base de datos local (SQLite)
    echo - ✅ 6 módulos completos
    echo - ✅ Interfaz profesional
    echo - ✅ 100% offline-first
    echo.
) else (
    echo ❌ No se encontró el archivo APK generado
    echo Revisa los mensajes de error arriba
)

pause
