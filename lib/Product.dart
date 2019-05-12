import 'package:googleapis/sheets/v4.dart';
import 'constants.dart';

class Product {
  final String productName;
  final double amount;
  final String date;
  final String category;
  final String owner;
  final String type;

  Product(this.productName, this.amount, this.date, this.category, this.owner, this.type);

  factory Product.fromRowData(RowData rowData) {
    final productName = rowData.values[budgetNameIndex].formattedValue;
    final amount = rowData.values[budgetAmountIndex].effectiveValue.numberValue;
    final date = rowData.values[budgetDateIndex].formattedValue;
    final category = rowData.values[budgetCategoryIndex].formattedValue;
    final owner = rowData.values[budgetOwnerIndex].formattedValue;
    final type = rowData.values[budgetTypeIndex].formattedValue;
    return Product(productName, amount, date, category, owner, type);
  }

  @override
  String toString() {
    return 'Product{$productName, amount: $amount}';
  }


}