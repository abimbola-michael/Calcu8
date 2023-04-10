extension DoubleExtensions on double {
  double get toDegrees => (this * (180.0 / 3.14159265));
  double get toRadians => (this * (3.14159265 / 180.0));
}
