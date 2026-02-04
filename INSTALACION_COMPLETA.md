# 📋 Guía de Instalación Completa - Yalitza Salas Bloom Mobile

## 🔧 Requisitos Previos

### 1. Instalar Flutter SDK

#### Opción A: Descarga Manual (Recomendada)
1. **Descargar Flutter SDK:**
   - Ve a: https://flutter.dev/docs/get-started/install/windows
   - Descarga el ZIP de Flutter SDK (última versión estable)
   - Descomprime en: `C:\flutter`

2. **Configurar Variables de Entorno:**
   - Abre "Variables de entorno" del sistema
   - En "Variables del sistema", agrega:
     - `FLUTTER_ROOT` = `C:\flutter`
     - A `Path` agrega: `C:\flutter\bin`

3. **Verificar Instalación:**
   ```cmd
   flutter --version
   flutter doctor
   ```

#### Opción B: Usar Chocolatey
```cmd
choco install flutter
```

### 2. Instalar Android Studio

1. **Descargar Android Studio:**
   - Ve a: https://developer.android.com/studio
   - Descarga e instala Android Studio

2. **Configurar Android Studio:**
   - Durante instalación, selecciona "Android Virtual Device"
   - Instala "Flutter plugin" y "Dart plugin"
   - Reinicia Android Studio

3. **Crear AVD (Android Virtual Device):**
   - Abre Android Studio
   - Tools → AVD Manager
   - Create Virtual Device
   - Selecciona Pixel 6 (o similar)
   - Descarga una imagen (API 30+ recomendado)
   - Finaliza creación

### 3. Instalar Git (si no está instalado)
```cmd
choco install git
```
O descarga desde: https://git-scm.com/download/win

## 🚀 Configuración del Proyecto

### 1. Instalar Dependencias del Proyecto
```cmd
cd C:\Users\xvice\Desktop\progamacion\yalitza-salas-bloom-mobile
flutter pub get
```

### 2. Generar Código Drift (Base de Datos)
```cmd
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 3. Verificar Configuración
```cmd
flutter doctor
```
Asegúrate que todo esté en verde (✓)

## 📱 Ejecutar la Aplicación

### Opción 1: Emulador Android
```cmd
flutter emulators
flutter emulators --launch <emulator_name>
flutter run
```

### Opción 2: Dispositivo Físico
1. Habilita "Depuración USB" en tu teléfono
2. Conecta el teléfono al PC
3. Acepta la autorización en el teléfono
4. Ejecuta:
```cmd
flutter devices
flutter run
```

### Opción 3: Web (para pruebas rápidas)
```cmd
flutter run -d chrome
```

## 📦 Generar APK

### 1. APK para Pruebas (Debug)
```cmd
flutter build apk --debug
```
- Ubicación: `build\app\outputs\flutter-apk\app-debug.apk`
- Más rápida de generar
- Puede depurarse

### 2. APK para Producción (Release)
```cmd
flutter build apk --release
```
- Ubicación: `build\app\outputs\flutter-apk\app-release.apk`
- Optimizada
- No puede depurarse
- Lista para distribución

### 3. App Bundle (para Google Play)
```cmd
flutter build appbundle --release
```
- Ubicación: `build\app\outputs\bundle\release\app-release.aab`
- Formato preferido para Google Play Store

## 🔧 Solución de Problemas Comunes

### Problema: "flutter command not found"
**Solución:**
1. Verifica que `C:\flutter\bin` esté en el PATH
2. Reinicia la terminal/PowerShell
3. Ejecuta `refreshenv` o reinicia el PC

### Problema: "Android licenses not accepted"
**Solución:**
```cmd
flutter doctor --android-licenses
```
Acepta todas las licencias escribiendo 'y'

### Problema: "Failed to install app"
**Solución:**
1. Limpia el proyecto: `flutter clean`
2. Vuelve a ejecutar: `flutter pub get`
3. Intenta de nuevo: `flutter run`

### Problema: Emulador lento
**Solución:**
1. En AVD Manager, edita el dispositivo
2. Habilita "Use Host GPU"
3. Asigna más RAM (4GB+)
4. Usa "Hardware - GLES 2.0"

## 📋 Checklist Final

Antes de generar la APK final:

- [ ] `flutter doctor` muestra todo en verde
- [ ] `flutter pub get` completado sin errores
- [ ] `flutter packages pub run build_runner build` ejecutado
- [ ] Aplicación funciona en emulador/dispositivo
- [ ] Todas las pantallas funcionan correctamente
- [ ] Base de datos local funciona
- [ ] No hay errores en consola

## 🎯 Probar la Aplicación

### 1. Pruebas en Emulador
```cmd
flutter emulators --launch <nombre_emulador>
flutter run
```

### 2. Pruebas en Web
```cmd
flutter run -d chrome
```
Abre: http://localhost:3000

### 3. Pruebas en Dispositivo Físico
1. Conecta teléfono con depuración USB
2. `flutter run`
3. La app se instalará automáticamente

## 📱 Instalar APK en Teléfono

### Método 1: USB
1. Copia `app-release.apk` al teléfono
2. En el teléfono, activa "Fuentes desconocidas"
3. Instala el APK

### Método 2: ADB
```cmd
adb install build\app\outputs\flutter-apk\app-release.apk
```

## 🚀 Listo para Producción

Una vez que todo funcione correctamente:

1. **Firma la APK** (para Google Play)
2. **Sube a Google Play Console**
3. **Publica la aplicación**

---

## 📞 Soporte

Si tienes problemas:
1. Ejecuta `flutter doctor -v` para diagnóstico detallado
2. Revisa los logs con `flutter logs`
3. Limpia y reconstruye: `flutter clean && flutter pub get && flutter run`
