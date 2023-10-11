import 'package:flutter/material.dart';

 ColorScheme myColorScheme = const ColorScheme(
  primary: Colors.blue,
  secondary: Colors.green,
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
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

