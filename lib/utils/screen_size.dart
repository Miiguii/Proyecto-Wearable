import 'package:flutter/material.dart';

/// Categorías de tamaño de pantalla, pensadas para teléfonos Android
/// (desde compactos tipo Android Go hasta tablets pequeñas).
enum ScreenSizeClass { compact, normal, large, tablet }

/// Helper de responsividad para `app_wearable` (lado teléfono).
/// Uso típico:
/// ```dart
/// final ss = ScreenSize.of(context);
/// Text('Hola', style: TextStyle(fontSize: ss.font(16)))
/// Padding(padding: ss.padding(20))
/// ```
class ScreenSize {
  final Size size;
  final double scale;
  final ScreenSizeClass sizeClass;
  final bool isTablet;

  ScreenSize._(this.size, this.scale, this.sizeClass, this.isTablet);

  factory ScreenSize.of(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final shortestSide = mq.size.shortestSide;

    // Ancho de referencia: 390dp (iPhone/Android "normal" promedio).
    // Se limita el rango para no achicar/agrandar demasiado en extremos.
    final scale = (width / 390).clamp(0.85, 1.35);

    ScreenSizeClass sizeClass;
    if (shortestSide >= 600) {
      sizeClass = ScreenSizeClass.tablet;
    } else if (width >= 430) {
      sizeClass = ScreenSizeClass.large;
    } else if (width >= 360) {
      sizeClass = ScreenSizeClass.normal;
    } else {
      sizeClass = ScreenSizeClass.compact;
    }

    return ScreenSize._(mq.size, scale, sizeClass, shortestSide >= 600);
  }

  /// Escala una fuente en base al ancho de pantalla.
  double font(double base) => base * scale;

  /// Escala un ícono.
  double icon(double base) => base * scale;

  /// Escala un espaciado/gap (SizedBox, margin entre elementos).
  double gap(double base) => base * scale;

  /// Padding horizontal simétrico ya escalado.
  EdgeInsets padding(double base) =>
      EdgeInsets.symmetric(horizontal: base * scale);

  /// Padding en las 4 direcciones, escalado.
  EdgeInsets paddingAll(double base) => EdgeInsets.all(base * scale);

  /// Cantidad de columnas sugerida para grids (cards, stats, etc.)
  int gridColumns({int compact = 2, int tablet = 3}) =>
      isTablet ? tablet : compact;

  /// Ancho máximo de contenido, para no estirar demasiado en tablets.
  double get maxContentWidth => isTablet ? 600 : size.width;
}
