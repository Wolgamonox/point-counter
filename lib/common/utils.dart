import 'package:flutter/painting.dart';

Color progressToColor(double progress) {
  double hue = progress.clamp(0.0, 1.0) * (120.0 - 10.0) + 10.0;
  return HSLColor.fromAHSL(1.0, hue, 1.0, 0.4).toColor();
}