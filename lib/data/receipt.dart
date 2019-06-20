

import '../util/double.dart';

class Receipt {

  final List<ReceiptProduct> products;
  final double totalAmount;

  Receipt(this.products, this.totalAmount);

  bool isMalformed() {
    final malformedProducts = products.where((p) => p.isMalformed());
    if (malformedProducts.isNotEmpty)
      return true;

    final double productsTotalAmount = products.map((p) => p.totalAmount).fold(0, (p, c) => p + c);
    if (!equalsDouble(productsTotalAmount, totalAmount, epsilon: 0.01))
      return true;
    return false;
  }
}

class ReceiptProduct {

  final String text;
  final double amount;
  final double unitPrice;
  final double totalAmount;
  final String taxLevel;

  String get capitalizedText {
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

  ReceiptProduct({this.text, this.amount, this.unitPrice, this.totalAmount, this.taxLevel});

  bool isMalformed() {
    if (text == null || text.isEmpty)
      return true;
    if (taxLevel == null || taxLevel.isEmpty)
      return true;

    final calculatedTotalAmount = amount * unitPrice;
    if (!equalsDouble(calculatedTotalAmount, totalAmount, epsilon: 0.01))
      return true;
    return false;
  }

  @override
  String toString() {
    return '\"$text\" $totalAmount zł' + (isMalformed() ? " (⚠)" : '');
  }

}
