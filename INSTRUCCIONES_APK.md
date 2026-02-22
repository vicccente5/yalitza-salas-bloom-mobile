# 📱 Instrucciones para Instalar Yalitza Salas en tu Celular

## 🌐 Opción 1: Versión Web (Recomendada para probar ahora)

La aplicación ya está construida para web y puedes usarla en tu celular:

1. **Abre el navegador** en tu celular (Chrome, Safari, etc.)
2. **Visita**: `http://localhost:8080` (después de iniciar el servidor)
3. **Añade a pantalla de inicio**:
   - Android: Chrome → Menú ⋮ → "Añadir a pantalla de inicio"
   - iPhone: Safari → Compartir → "Añadir a pantalla de inicio"

### Para iniciar la versión web:
```bash
flutter run -d web-server --web-port 8080 --release
```

---

## 📲 Opción 2: APK para Android (Requiere configuración)

### 🔧 Configuración Necesaria:

1. **Instalar Android Studio**:
   - Descarga: https://developer.android.com/studio
   - Instala con la configuración por defecto

2. **Instalar Android SDK**:
   - Abre Android Studio
   - Ve a `File → Settings → Appearance & Behavior → System Settings → Android SDK`
   - Instala el SDK más reciente

3. **Configurar variables de entorno**:
   - Agrega `ANDROID_HOME` apuntando a la carpeta del SDK
   - Agrega `%ANDROID_HOME%\platform-tools` al PATH

4. **Aceptar licencias**:
   ```bash
   flutter doctor --android-licenses
   ```

### 🏗️ Para generar la APK:

Una vez configurado el entorno:

```bash
# APK normal
flutter build apk --release

# APK optimizada para diferentes arquitecturas
flutter build apk --split-per-abi --release

# App Bundle (para Play Store)
flutter build appbundle --release
```

### 📂 Ubicación de la APK:

La APK generada estará en:
```
build\app\outputs\flutter-apk\app-release.apk
```

---

## 🚀 Instrucciones Rápidas (si ya tienes Android Studio)

Si ya tienes Android Studio instalado:

```bash
# Configurar Flutter para que encuentre el SDK
flutter config --android-sdk "C:\Users\tu_usuario\AppData\Local\Android\Sdk"

# Aceptar licencias
flutter doctor --android-licenses

# Generar APK
flutter build apk --release
```

---

## 📱 Para instalar la APK en tu celular:

1. **Activa "Fuentes desconocidas"** en tu celular:
   - Android: Configuración → Seguridad → Instalar apps desconocidas
2. **Transfiere la APK** a tu celular (USB, email, etc.)
3. **Instala la APK** tocando el archivo
4. **Disfruta la app!** 🎉

---

## 🌟 Características de la Aplicación:

✅ **7 secciones organizadas**  
✅ **Sistema de gastos categorizados**  
✅ **Sincronización con Supabase**  
✅ **Interfaz moderna e intuitiva**  
✅ **Gestión completa de clientes y citas**  

---

## 🆘 Si tienes problemas:

1. **Revisa `flutter doctor`** para ver qué falta
2. **Asegúrate de tener espacio suficiente** en el celular
3. **Verifica que tu Android sea 5.0+** (API 21+)
4. **Contacta para soporte técnico**

---

**🎯 Recomendación**: Usa primero la versión web para probar, luego genera la APK cuando tengas el entorno configurado.
