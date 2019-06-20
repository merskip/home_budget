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

    expect(receipt.totalAmount, equals(2.0));
    expect(receipt.isMalformed(), equals(false));
  });

  test("Multi simple product", () {
    final receipt = receiptReader.read(["Name  1 * 2.00 2.00A", "Second name  2.00 * 3.00 6.00B", "SUMA PLN 8.00"]);

    expect(receipt.products.length, 2);

    expect(receipt.products[0].text, "Name");
    expect(receipt.products[0].amount, 1.0);
    expect(receipt.products[0].unitPrice, 2.0);
    expect(receipt.products[0].totalAmount, 2.0);
    expect(receipt.products[0].taxLevel, "A");

    expect(receipt.products[1].text, "Second name");
    expect(receipt.products[1].amount, 2.0);
    expect(receipt.products[1].unitPrice, 3.0);
    expect(receipt.products[1].totalAmount, 6.0);
    expect(receipt.products[1].taxLevel, "B");

    expect(receipt.totalAmount, equals(8.0));
    expect(receipt.isMalformed(), equals(false));
  });


  test("Multiline products", () {
    final receipt = receiptReader.read(["Name", "1 * 2.00 2.00A", "Second name 2 * 3.00", "6.00B", "SUMA PLN 8.00"]);

    expect(receipt.products.length, 2);

    expect(receipt.products[0].text, "Name");
    expect(receipt.products[0].amount, 1.0);
    expect(receipt.products[0].unitPrice, 2.0);
    expect(receipt.products[0].totalAmount, 2.0);
    expect(receipt.products[0].taxLevel, "A");

    expect(receipt.products[1].text, "Second name");
    expect(receipt.products[1].amount, 2.0);
    expect(receipt.products[1].unitPrice, 3.0);
    expect(receipt.products[1].totalAmount, 6.0);
    expect(receipt.products[1].taxLevel, "B");

    expect(receipt.totalAmount, equals(8.0));
    expect(receipt.isMalformed(), equals(false));
  });
}
