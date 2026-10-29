# Dulce Antojo 🍰

Aplicación sencilla hecha en Flutter para la **Actividad Integradora 1** de Desarrollo de Aplicaciones Móviles.
Es un catálogo de postres con dos pantallas.

## Pantallas

- **Pantalla 1 (HomeScreen):** muestra los postres en una cuadrícula con foto, nombre, precio y el botón "Ver más".
- **Pantalla 2 (DetailScreen):** muestra el detalle del postre y un formulario para reservarlo (nombre y cantidad).

## Navegación

Se usan **rutas con nombre** (`/` y `/detalle`).
Al tocar "Ver más" se llama a `Navigator.pushNamed` y se envía el postre en `arguments`.
Al reservar, `Navigator.pop` regresa a la Pantalla 1 con un mensaje que se muestra en un `SnackBar`.

## Estructura

```
lib/
  main.dart
  models/postre.dart
  screens/home_screen.dart
  screens/detail_screen.dart
  widgets/postre_card.dart
assets/images/   (fotos de los postres)
```

## Cómo ejecutar

```
flutter pub get
flutter run
```

Las fotos son de Wikimedia Commons.

Autora: Cinthia Marisol Guamán Montaño
