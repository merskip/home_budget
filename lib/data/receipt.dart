

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

  String get prettyText {
    var text = this.text;
    if (text.endsWith("$taxLevel")) text = text.substring(0, text.length - 1);
    if (text.endsWith("($taxLevel)")) text = text.substring(0, text.length - 3);
    text = text.trim();

    final isUppercase = text == text.toUpperCase();
    if (isUppercase)
      return text[0].toUpperCase() + text.substring(1).toLowerCase();
    else
      return text;
}

  ReceiptProduct({this.text, this.amount, this.unitPrice, this.totalAmount, this.taxLevel});

  bool isMalformed() {
    if (text == null || text.isEmpty)
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
