import 'dart:ui';
import 'package:flutter/cupertino.dart';

/// A class for setting themes for color gradients
class ColorGradients {

  const ColorGradients();

  static const Color loginGradientStart = Color(0xFF004C7F);
  static const Color loginGradientEnd = Color(0xFF061D5C);

  static const primaryGradient = const LinearGradient(
    colors: const [loginGradientStart, loginGradientEnd],
    stops: const [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}