@echo off
echo 🔧 Configurando Android Studio para Flutter
echo.

REM Verificar si Flutter está instalado
"C:\Users\xvice\Desktop\flutter\bin\flutter.bat" --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter no está instalado
    pause
    exit /b 1
)

echo ✅ Flutter encontrado
echo.

echo 📋 Pasos para configurar Android Studio:
echo.
echo 1. Abre Android Studio
echo 2. Ve a File → Settings → Appearance & Behavior → System Settings → Android SDK
echo 3. Asegúrate de que esté instalado el "Android SDK Command-line Tools"
echo 4. Si no está instalado, haz clic en "SDK Tools" y marca "Android SDK Command-line Tools (latest)"
echo 5. Haz clic en "Apply" para instalar
echo 6. Una vez instalado, ejecuta este script nuevamente
echo.

REM Intentar configurar variables de entorno automáticamente
echo 🔍 Buscando instalación de Android Studio...

REM Buscar en ubicaciones comunes
set "ANDROID_STUDIO_HOME="
if exist "C:\Program Files\Android\Android Studio\bin\studio64.exe" (
    set "ANDROID_STUDIO_HOME=C:\Program Files\Android\Android Studio"
    echo ✅ Android Studio encontrado en: %ANDROID_STUDIO_HOME%
) else if exist "C:\Program Files (x86)\Android\Android Studio\bin\studio64.exe" (
    set "ANDROID_STUDIO_HOME=C:\Program Files (x86)\Android\Android Studio"
    echo ✅ Android Studio encontrado en: %ANDROID_STUDIO_HOME%
) else (
    echo ❌ Android Studio no encontrado en ubicaciones estándar
    echo Por favor, abre Android Studio manualmente
)

REM Configurar ANDROID_HOME si existe
if defined ANDROID_STUDIO_HOME (
    set "ANDROID_HOME=%ANDROID_STUDIO_HOME%\..\.."
    echo.
    echo 📱 Configurando ANDROID_HOME: %ANDROID_HOME%
    
    REM Agregar al PATH del usuario
    setx ANDROID_HOME "%ANDROID_HOME%" /M >nul 2>&1
    setx PATH "%PATH%;%ANDROID_HOME%\tools;%ANDROID_HOME%\tools\bin;%ANDROID_HOME%\platform-tools" /M >nul 2>&1
    
    echo ✅ Variables de entorno configuradas
    echo ⚠️ Es posible que necesites reiniciar el PC para que los cambios surtan efecto
)

echo.
echo 🔄 Después de instalar las herramientas de línea de comandos, ejecuta:
echo flutter doctor --android-licenses
echo.

REM Verificar estado actual
echo 📊 Estado actual de Flutter:
"C:\Users\xvice\Desktop\flutter\bin\flutter.bat" doctor

echo.
echo 📱 Para probar la aplicación en emulador:
echo 1. Abre Android Studio
echo 2. Ve a Tools → AVD Manager
echo 3. Crea un nuevo dispositivo virtual
echo 4. Inicia el emulador
echo 5. Ejecuta: flutter run
echo.

pause
