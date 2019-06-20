import 'package:home_budget/util/receipt_reader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  final receiptReader = ReceiptReader();

  test("Single simple product", () {
    final receipt = receiptReader.read(["Name  1 * 2.00 2.00A", "SUMA PLN 2.00"]);

    expect(receipt.products.length, 1);
    expect(receipt.products[0].text, "Name");
    expect(receipt.products[0].amount, 1.0);
    expect(receipt.products[0].unitPrice, 2.0);
    expect(receipt.products[0].totalAmount, 2.0);
    expect(receipt.products[0].taxLevel, "A");
    expect(receipt.isMalformed(), equals(false));
  });
}
