import 'package:flutter/material.dart';

/// MarketOS Design Tokens & Palettes
/// Matches variables.scss from the MarketOS customer web application
class MarketOSTheme {
  MarketOSTheme._();

  // Brand Gold
  static const Color goldLight = Color(0xFFB8862A);
  static const Color goldDark = Color(0xFFD4A438);

  static const Color gold2Light = Color(0xFFD4A438);
  static const Color gold2Dark = Color(0xFFF0CE7A);

  static const Color goldFadeLight = Color(0x1AB8862A);
  static const Color goldFadeDark = Color(0x24D4A438);

  // Semantics
  static const Color greenLight = Color(0xFF1F8F5F);
  static const Color greenDark = Color(0xFF3FB27F);

  static const Color redLight = Color(0xFFC23F2C);
  static const Color redDark = Color(0xFFE5644E);

  static const Color amberLight = Color(0xFFB87A1E);
  static const Color amberDark = Color(0xFFE0A030);

  static const Color blueLight = Color(0xFF2A6FA8);
  static const Color blueDark = Color(0xFF5A9BD8);

  // Surfaces
  static const Color bgLight = Color(0xFFF7F5F0);
  static const Color bgDark = Color(0xFF0B0F14);

  static const Color surfLight = Color(0xFFFFFFFF);
  static const Color surfDark = Color(0xFF121A23);

  static const Color surf2Light = Color(0xFFF1EEE6);
  static const Color surf2Dark = Color(0xFF18222D);

  static const Color surf3Light = Color(0xFFE8E3D8);
  static const Color surf3Dark = Color(0xFF1F2B38);

  static const Color lineLight = Color(0xFFE2DDD0);
  static const Color lineDark = Color(0xFF26323F);

  static const Color line2Light = Color(0xFFD3CCBA);
  static const Color line2Dark = Color(0xFF324150);

  // Text
  static const Color textLight = Color(0xFF1B2430);
  static const Color textDark = Color(0xFFE6EDF3);

  static const Color mutedLight = Color(0xFF5B6B7A);
  static const Color mutedDark = Color(0xFF8B9AAB);

  static const Color dimLight = Color(0xFF93A0AC);
  static const Color dimDark = Color(0xFF5D6D7E);

  // Dynamic getters based on brightness
  static Color gold(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? goldDark : goldLight;

  static Color gold2(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? gold2Dark : gold2Light;

  static Color goldFade(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? goldFadeDark
          : goldFadeLight;

  static Color green(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? greenDark : greenLight;

  static Color red(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? redDark : redLight;

  static Color amber(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? amberDark : amberLight;

  static Color blue(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? blueDark : blueLight;

  static Color bg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? bgDark : bgLight;

  static Color surf(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? surfDark : surfLight;

  static Color surf2(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? surf2Dark : surf2Light;

  static Color surf3(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? surf3Dark : surf3Light;

  static Color line(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? lineDark : lineLight;

  static Color line2(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? line2Dark : line2Light;

  static Color text(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textDark : textLight;

  static Color muted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? mutedDark : mutedLight;

  static Color dim(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dimDark : dimLight;
}
