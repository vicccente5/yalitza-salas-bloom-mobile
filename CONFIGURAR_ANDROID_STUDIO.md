# 🔧 Configuración Completa de Android Studio para Flutter

## 📋 Pasos para Configurar Android Studio

### 1. **Instalar Command-line Tools**

1. **Abre Android Studio**
2. Ve a **File → Settings** (o **Android Studio → Settings** en Mac)
3. Navega a **Appearance & Behavior → System Settings → Android SDK**
4. Haz clic en la pestaña **SDK Tools**
5. **Marca las siguientes casillas:**
   - ✅ **Android SDK Command-line Tools (latest)**
   - ✅ **Android SDK Build-Tools**
   - ✅ **Android SDK Platform-Tools**
   - ✅ **Android SDK Tools**
6. Haz clic en **Apply** y luego **OK** para instalar

### 2. **Configurar Variables de Entorno**

#### Método Automático (Recomendado)
Ejecuta el script:
```cmd
SCRIPTS\configurar_android.bat
```

#### Método Manual
1. **Busca la ubicación del Android SDK:**
   - Generalmente en: `C:\Users\{tu_usuario}\AppData\Local\Android\Sdk`
   - O en: `C:\Program Files\Android\Android Studio\..\..`

2. **Configura las variables de entorno:**
   - Presiona `Win + R`, escribe `sysdm.cpl` y presiona Enter
   - Ve a la pestaña **Opciones avanzadas**
   - Haz clic en **Variables de entorno**
   - En **Variables del sistema**, haz clic en **Nueva**:
     - **Nombre:** `ANDROID_HOME`
     - **Valor:** `C:\Users\{tu_usuario}\AppData\Local\Android\Sdk`
   - Edita la variable **Path** y agrega:
     - `%ANDROID_HOME%\tools`
     - `%ANDROID_HOME%\tools\bin`
     - `%ANDROID_HOME%\platform-tools`

### 3. **Aceptar Licencias de Android**

Abre una terminal y ejecuta:
```cmd
flutter doctor --android-licenses
```
Escribe `y` y presiona Enter para aceptar todas las licencias.

### 4. **Verificar Configuración**

Ejecuta:
```cmd
flutter doctor
```

Deberías ver algo como:
```
[✓] Flutter (Channel stable)
[✓] Android toolchain - develop for Android devices
[✓] Chrome - develop for the web
[✓] Connected device (1 available)
```

## 📱 Crear y Usar Emulador

### 1. **Crear Emulador**

1. **Abre Android Studio**
2. Ve a **Tools → AVD Manager** (o **Tools → Device Manager**)
3. Haz clic en **Create Virtual Device**
4. **Selecciona un dispositivo:**
   - Pixel 6 (recomendado)
   - Pixel 4a
   - Cualquier dispositivo con Android 8.0+
5. **Selecciona una imagen del sistema:**
   - Descarga una imagen recomendada (API 30+)
6. **Configura el AVD:**
   - Nombre: `pixel_6_api_30`
   - Avanzado → RAM: 4096 MB (o más)
   - Avanzado → Internal Storage: 6000 MB
7. Haz clic en **Finish**

### 2. **Iniciar Emulador**

#### Método 1: Desde Android Studio
- En AVD Manager, haz clic en el botón ▶️ junto a tu emulador

#### Método 2: Desde terminal
```cmd
flutter emulators --launch pixel_6_api_30
```

## 🚀 Probar la Aplicación

### Opción 1: En Emulador
```cmd
flutter emulators --launch <nombre_emulador>
flutter run
```

### Opción 2: En Navegador Web
```cmd
flutter run -d chrome
```

### Opción 3: En Dispositivo Físico
1. Conecta tu teléfono Android con cable USB
2. Activa "Depuración USB" en el teléfono
3. Ejecuta:
```cmd
flutter devices
flutter run
```

## 📦 Generar APK

### APK de Debug (para pruebas)
```cmd
flutter build apk --debug
```

### APK de Release (para producción)
```cmd
flutter build apk --release
```

### App Bundle (para Google Play)
```cmd
flutter build appbundle --release
```

## 🔧 Scripts Automatizados

### Configurar Android
```cmd
SCRIPTS\configurar_android.bat
```

### Probar Aplicación
```cmd
SCRIPTS\probar_emulador.bat
```

### Generar APK
```cmd
SCRIPTS\generar_apk_simple.bat
```

## 🆘 Solución de Problemas Comunes

### "Android sdkmanager not found"
**Solución:** Instala Android SDK Command-line Tools desde Android Studio SDK Manager.

### "cmdline-tools component is missing"
**Solución:** Ve a SDK Manager → SDK Tools y marca "Android SDK Command-line Tools".

### "Android license status unknown"
**Solución:** Ejecuta `flutter doctor --android-licenses` y acepta todas las licencias.

### "No connected devices"
**Solución:** 
1. Inicia un emulador, o
2. Conecta un dispositivo físico con depuración USB activada

### "Failed to install app"
**Solución:**
```cmd
flutter clean
flutter pub get
flutter run
```

## 📋 Checklist Final

Antes de continuar:

- [ ] Android Studio instalado
- [ ] Command-line tools instalados
- [ ] Variables de entorno configuradas
- [ ] Licencias aceptadas
- [ ] Emulador creado y funcionando
- [ ] `flutter doctor` muestra todo en verde
- [ ] Aplicación corre en emulador

## 🎯 Siguientes Pasos

Una vez configurado todo:

1. **Prueba la aplicación actual** en el emulador
2. **Experimenta con la interfaz**
3. **Si quieres la versión completa con base de datos**, avísame y la implementamos
4. **Personaliza colores y funcionalidades** según necesites

---

## 📞 Si tienes problemas

1. Ejecuta `flutter doctor -v` para diagnóstico detallado
2. Revisa que todas las herramientas estén instaladas
3. Reinicia Android Studio y tu PC si es necesario
4. Usa los scripts automatizados para facilitar la configuración
