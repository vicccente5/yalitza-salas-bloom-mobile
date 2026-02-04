# 🚀 Inicio Rápido - Yalitza Salas Bloom Mobile

## ⚡ Si Flutter ya está instalado

### 1. Instalar dependencias
```cmd
cd C:\Users\xvice\Desktop\progamacion\yalitza-salas-bloom-mobile
flutter pub get
```

### 2. Generar código de base de datos
```cmd
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 3. Probar la aplicación
```cmd
# Opción A: En navegador (más rápido)
flutter run -d chrome

# Opción B: En emulador Android
flutter emulators --launch <nombre_emulador>
flutter run

# Opción C: Con script automatizado
.\SCRIPTS\probar_app.bat
```

### 4. Generar APK
```cmd
# APK para pruebas
flutter build apk --debug

# APK para producción
flutter build apk --release

# O con script automatizado
.\SCRIPTS\generar_apk.bat
```

## 📱 Ubicación de la APK

**Debug APK:** `build\app\outputs\flutter-apk\app-debug.apk`
**Release APK:** `build\app\outputs\flutter-apk\app-release.apk`

## 🧪 Probar la APK en tu teléfono

### Método 1: USB
1. Conecta tu teléfono al PC
2. Copia el APK al teléfono
3. Activa "Instalar de fuentes desconocidas"
4. Abre el APK e instala

### Método 2: ADB
```cmd
adb install build\app\outputs\flutter-apk\app-release.apk
```

## 🔧 Si Flutter NO está instalado

### Opción 1: Instalación Automática (Recomendada)
```powershell
# Ejecutar como Administrador
.\SCRIPTS\instalar_flutter.ps1
# Reiniciar PC
```

### Opción 2: Manual
1. Descarga Flutter: https://flutter.dev/docs/get-started/install/windows
2. Descomprime en `C:\flutter`
3. Agrega `C:\flutter\bin` al PATH
4. Reinicia terminal

## ✅ Verificación

Ejecuta estos comandos para verificar todo está funcionando:
```cmd
flutter --version
flutter doctor
flutter devices
```

## 🎯 Checklist Antes de Usar

- [ ] Flutter instalado y en PATH
- [ ] Android Studio instalado
- [ ] Emulador Android creado
- [ ] `flutter pub get` ejecutado
- [ ] `build_runner build` ejecutado
- [ ] Aplicación funciona en emulador/web

## 🆘 Problemas Comunes

### "flutter command not found"
**Solución:** Reinicia terminal o PC después de instalar Flutter

### "Android licenses not accepted"
**Solución:** `flutter doctor --android-licenses`

### "Failed to install app"
**Solución:** `flutter clean && flutter pub get && flutter run`

---

## 📞 ¿Necesitas ayuda?

1. Revisa `INSTALACION_COMPLETA.md` para guía detallada
2. Usa los scripts en `SCRIPTS/` para automatización
3. Ejecuta `flutter doctor -v` para diagnóstico completo

¡Listo para usar! 🎉
