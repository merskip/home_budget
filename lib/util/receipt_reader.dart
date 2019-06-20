
import '../data/receipt.dart';

class ReceiptReader {


  Receipt read(List<String> textLines) {
    final products = _readProducts(textLines);
    final totalAmount = _findTotalAmount(textLines);

    return Receipt(products, totalAmount);
  }

  List<ReceiptProduct> _readProducts(List<String> textLines) {
    var products = List<ReceiptProduct>();
    var bufferLine = "";

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
      }
    }
    return products;
  }

  double _findTotalAmount(List<String> textLines) {
    final regex = RegExp(r"SUMA\s+PLN\s+(\d+[,.]\d{2})", caseSensitive: false);
    final text = textLines.join(" ");
    final match = regex.firstMatch(text);
    return _parseDouble(match.group(1));
  }

  ReceiptProduct _parseProduct(String line) {
    final regex = RegExp(r"^(.+)\s(\d+(?:[,.]\d{2})?)[\sxX*]+(\d+[,.]\d{2})\s*z?ł?[^a-zA-Z0-9]+(\d+[,.]\d{2}).*?([A-Z])?$");
    final match = regex.firstMatch(line);
    if (match == null) return null;
    return ReceiptProduct(
      text: match.group(1).trim(),
      amount: double.parse(match.group(2).replaceAll(",", ".")),
      unitPrice: double.parse(match.group(3).replaceAll(",", ".")),
      totalAmount: double.parse(match.group(4).replaceAll(",", ".")),
      taxLevel: match.group(5)
    );
  }

  double _parseDouble(String text) {
    return double.tryParse(text.replaceAll(",", "."));
  }
}