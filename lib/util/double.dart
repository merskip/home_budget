

import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

bool equalsDouble(double a, double b, {double epsilon}) {
  if (a == null || b == null) return false;
  return (a - b).abs() < epsilon;
}

double parseDouble(String text) {
  if (text == null) return null;
  return double.tryParse(text.replaceAll(",", "."));
}

String moneyFormat({@required double amount, bool simple = true}) {
  if (amount == null) amount = 0;
  final format = simple ? NumberFormat.simpleCurrency(locale: "pl_PL") : NumberFormat.currency(locale: "pl_PL");
  return format.format(amount);
}