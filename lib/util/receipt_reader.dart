import '../data/receipt.dart';
import '../util/double.dart';

class ReceiptReader {

  Receipt read(List<String> textLines) {
    final totalAmount = _findTotalAmount(textLines);
    final products = _readProducts(textLines, targetTotalAmount: totalAmount);

    return Receipt(products, totalAmount);
  }

  List<ReceiptProduct> _readProducts(List<String> textLines, {double targetTotalAmount}) {
    var products = List<ReceiptProduct>();
    var bufferLine = "";
    var totalAmount = 0.0;

    if (textLines.contains("PARAGON FISKALNY")) {
      textLines = textLines
        .skipWhile((line) => line != "PARAGON FISKALNY")
        .skip(1)
        .toList();
    }

    for (var line in textLines) {
      final productLine = bufferLine + " " + line;

      final product = _parseProduct(productLine);
      if (product == null) {
        bufferLine = productLine;
        continue;
      }
      else {
        bufferLine = "";
        products.add(product);

        totalAmount += product.totalAmount;
        if (equalsDouble(totalAmount, targetTotalAmount, epsilon: 0.01))
          break;
      }
    }
    return products;
  }

  double _findTotalAmount(List<String> textLines) {
    final regex = RegExp(r"SUMA:?\s+PLN\s+(\d+[,.]\d{2})", caseSensitive: false);
    final text = textLines.join(" ");
    final match = regex.firstMatch(text);
    return parseDouble(match?.group(1));
  }

  ReceiptProduct _parseProduct(String line) {
    final regex = RegExp(r"^(.+)\s(\d+(?:[,.]\d*)?)(?:szt.?)?[\sxX*#]+(\d+[,.]\d*)\s*z?ł?[^a-zA-Z0-9]+(\d+[,.]\d{2}).*?([A-Z08(])?$");
    final match = regex.firstMatch(line);
    if (match == null) return null;

    final text = match.group(1).trim();
    final amount = parseDouble(match.group(2));
    final unitPrice = parseDouble(match.group(3));
    final totalAmount = parseDouble(match.group(4));
    final taxLevel = _getFixedTaxLevel(match.group(5));

    return ReceiptProduct(
      text: text,
      amount: amount,
      unitPrice: unitPrice,
      totalAmount: totalAmount,
      taxLevel: taxLevel
    );
  }

  String _getFixedTaxLevel(String taxLevel) {
    switch (taxLevel) {
      case "0": return "D";
      case "8": return "B";
      case "(": return "C";
      default: return taxLevel;
    }
  }
}