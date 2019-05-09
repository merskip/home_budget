import 'package:googleapis/sheets/v4.dart';


class Product {
  final String productName;
  final double amount;
  final String date;
  final String category;
  final String owner;
  final String type;

  Product(this.productName, this.amount, this.date, this.category, this.owner, this.type);

  factory Product.fromRowData(RowData rowData) {
    final productName = rowData.values[1].formattedValue;
    final amount = rowData.values[2].effectiveValue.numberValue;
    final date = rowData.values[3].formattedValue;
    final category = rowData.values[4].formattedValue;
    final owner = rowData.values[5].formattedValue;
    final type = rowData.values[6].formattedValue;
    return Product(productName, amount, date, category, owner, type);
  }

  @override
  String toString() {
    return 'Product{$productName, amount: $amount}';
  }


}