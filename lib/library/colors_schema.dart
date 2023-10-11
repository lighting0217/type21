import 'package:flutter/material.dart';

ColorScheme myColorScheme = ColorScheme(
  primary: Colors.blue.withOpacity(0.7),
  secondary: Colors.green.withOpacity(0.9),
  surface: Colors.white,
  background: Colors.grey,
  error: Colors.red,
  onPrimary: Colors.white,
  onSecondary: Colors.black,
  onSurface: Colors.black,
  onBackground: Colors.black,
  onError: Colors.white,
  brightness: Brightness.light,
);
LinearGradient myGradient = LinearGradient(
  colors: [myColorScheme.primary, myColorScheme.secondary],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
