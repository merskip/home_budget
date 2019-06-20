

bool equalsDouble(double a, double b, {double epsilon}) {
  return (a - b).abs() < epsilon;
}

double parseDouble(String text) {
  if (text == null) return null;
  return double.tryParse(text.replaceAll(",", "."));
}