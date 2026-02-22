# 📱 Generar APK para Yalitza Salas

## 🎯 Estado Actual

✅ **Flutter encontrado en**: `C:\flutter\bin\flutter.bat`  
❌ **Android SDK**: No encontrado  
❌ **Variables de entorno**: No configuradas  

---

## 🚀 Opción 1: Instalación Automática (Recomendada)

### Paso 1: Ejecutar script de instalación
```powershell
# Abre PowerShell como Administrador y ejecuta:
cd "C:\Users\vicentee\Desktop\programacion\yalitza-salas-bloom-mobile"
.\instalar_android_sdk.ps1
```

### Paso 2: Reiniciar terminal
```powershell
# Cierra y vuelve a abrir PowerShell
```

### Paso 3: Generar APK
```powershell
cd "C:\Users\vicentee\Desktop\programacion\yalitza-salas-bloom-mobile"
C:\flutter\bin\flutter.bat build apk --release
```

---

## 🔧 Opción 2: Instalación Manual

### Paso 1: Descargar Android Studio
1. Ve a: https://developer.android.com/studio
2. Descarga Android Studio
3. Instala con configuración por defecto

### Paso 2: Configurar variables
```powershell
# Agrega al PATH del sistema:
C:\Users\vicentee\AppData\Local\Android\Sdk\cmdline-tools\latest\bin
C:\Users\vicentee\AppData\Local\Android\Sdk\platform-tools
```

### Paso 3: Aceptar licencias
```powershell
C:\flutter\bin\flutter.bat doctor --android-licenses
```

### Paso 4: Generar APK
```powershell
cd "C:\Users\vicentee\Desktop\programacion\yalitza-salas-bloom-mobile"
C:\flutter\bin\flutter.bat build apk --release
```

---

## 📂 Ubicación de la APK Generada

Una vez completado el proceso, la APK estará en:
```
C:\Users\vicentee\Desktop\programacion\yalitza-salas-bloom-mobile\build\app\outputs\flutter-apk\app-release.apk
```

---

## 📱 Para Instalar en tu Celular

1. **Activa fuentes desconocidas**:
   - Android: Configuración → Seguridad → Instalar apps desconocidas ✅
2. **Transfiere la APK**:
   - USB, email, WhatsApp, etc.
3. **Instala la APK**:
   - Toca el archivo descargado
4. **¡Listo!** 🎉

---

## 🌟 Características de la APK

✅ **7 secciones organizadas**  
✅ **Sistema de gastos categorizados**  
✅ **Sincronización con Supabase**  
✅ **Interfaz moderna**  
✅ **Funciona offline** (con datos locales)  

---

## 🆘 Solución de Problemas

### Error: "No Android SDK found"
```powershell
# Configura manualmente:
C:\flutter\bin\flutter.bat config --android-sdk "C:\Android\Sdk"
```

### Error: "Flutter not in PATH"
```powershell
# Agrega temporalmente:
$env:PATH += ";C:\flutter\bin"
```

### Error: "Licenses not accepted"
```powershell
C:\flutter\bin\flutter.bat doctor --android-licenses
# Responde "y" a todo
```

---

## 🎯 Comandos Útiles

```powershell
# Verificar estado
C:\flutter\bin\flutter.bat doctor

# APK optimizada (más pequeña)
C:\flutter\bin\flutter.bat build apk --split-per-abi --release

# App Bundle (para Play Store)
C:\flutter\bin\flutter.bat build appbundle --release

# Limpiar antes de construir
C:\flutter\bin\flutter.bat clean
C:\flutter\bin\flutter.bat pub get
```

---

## 🚀 Recomendación

**Usa primero la Opción 1 (automática)** - es más rápida y menos propensa a errores.

**Si falla, usa la Opción 2 (manual)** - es más controlada.

**¡Tu app Yalitza Salas estará lista para Android en minutos!** 📱✨
