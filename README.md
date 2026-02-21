# Yalitza Salas

Aplicación móvil para ayudar a llevar el control del trabajo diario de **Yalitza Salas**: clientes, servicios, citas y suministros.

La información se guarda en la nube con **Supabase**, para que puedas ver los cambios reflejados cuando tengas conexión.

## Qué puedes hacer con la app

### Inicio
- Ver un resumen rápido del día.
- Consultar cifras del mes (ingresos, costos y ganancias).

### Clientes
- Agregar, editar y eliminar clientes.
- Buscar clientes por nombre.

### Citas
- Ver las citas en un calendario.
- Crear, editar y eliminar citas.
- Marcar una cita como completada o cancelada.

### Servicios
- Crear, editar y eliminar servicios.
- Guardar precio, duración y una descripción.

### Suministros
- Agregar, editar y eliminar suministros.
- Actualizar el stock.

## Nota importante

- La app **necesita internet** para leer y guardar datos en Supabase.
- Si algo no se guarda, revisa tu conexión y vuelve a intentar.

## Cómo ejecutar el proyecto

1. Instala Flutter.
2. En la carpeta del proyecto:

```bash
flutter pub get
flutter run
```

## Generar APK

```bash
flutter build apk --release
```

El archivo sale en:

`build\app\outputs\flutter-apk\app-release.apk`


modificar apartado gastos para poner que tipo de gasto es y separar los tipos de gastos y impplementar gastos como de la casa y la luz
