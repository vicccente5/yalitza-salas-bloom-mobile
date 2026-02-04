# 📜 Scripts Automatizados - Yalitza Salas Bloom Mobile

## 🚀 Scripts Disponibles

### 1. instalar_flutter.ps1
**Propósito:** Instalación automática de Flutter y dependencias
**Uso:**
```powershell
# Ejecutar como Administrador
.\SCRIPTS\instalar_flutter.ps1
```

**Instala:**
- Flutter SDK
- Git
- Android Studio
- Configura variables de entorno

### 2. generar_apk.bat
**Propósito:** Generar APK para distribución
**Uso:**
```cmd
.\SCRIPTS\generar_apk.bat
```

**Realiza:**
- Instala dependencias (`flutter pub get`)
- Genera código Drift (`build_runner`)
- Limpia proyecto
- Genera APK Release
- Abre carpeta con el APK

### 3. probar_app.bat
**Propósito:** Probar la aplicación en diferentes plataformas
**Uso:**
```cmd
.\SCRIPTS\probar_app.bat
```

**Opciones:**
1. Emulador Android
2. Navegador Web (Chrome)
3. Dispositivo Físico
4. Ver dispositivos disponibles

## 📋 Flujo de Trabajo Recomendado

### Paso 1: Instalación Inicial
```powershell
# Como Administrador
.\SCRIPTS\instalar_flutter.ps1
# Reiniciar PC
```

### Paso 2: Configuración Android
1. Abrir Android Studio
2. Crear AVD (emulador)
3. Aceptar licencias: `flutter doctor --android-licenses`

### Paso 3: Probar Aplicación
```cmd
.\SCRIPTS\probar_app.bat
```

### Paso 4: Generar APK
```cmd
.\SCRIPTS\generar_apk.bat
```

## 🔧 Problemas Comunes

### "Script no se puede ejecutar"
**Solución:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Flutter no encontrado"
**Solución:**
1. Reinicia PowerShell/CMD
2. Verifica instalación: `flutter --version`

### "Error de permisos"
**Solución:**
- Ejecutar como Administrador
- O cambiar política de ejecución

## 📱 Ubicación de Archivos

### APK Generada
```
build\app\outputs\flutter-apk\app-release.apk
```

### Logs de Flutter
```cmd
flutter logs
```

### Emuladores
```
C:\Users\{usuario}\.android\avd\
```

## 🎯 Comandos Útiles

### Verificar instalación
```cmd
flutter doctor
flutter doctor -v
```

### Limpiar proyecto
```cmd
flutter clean
flutter pub get
```

### Ver dispositivos
```cmd
flutter devices
flutter emulators
```

### Instalar APK en dispositivo
```cmd
adb install build\app\outputs\flutter-apk\app-release.apk
```

## 📞 Soporte

Si los scripts fallan:
1. Revisa la guía INSTALACION_COMPLETA.md
2. Ejecuta `flutter doctor -v` para diagnóstico
3. Verifica que Android Studio esté correctamente instalado
4. Asegúrate de tener un emulador creado
