import 'package:flutter/material.dart';
import 'package:googleapis/sheets/v4.dart';

import 'BudgetProperties.dart';
import 'Product.dart';
import 'main.dart';

class BudgetPreviewPage extends StatefulWidget {

  final String sheetId;

  BudgetPreviewPage({Key key, this.sheetId}) : super(key: key);

  @override
  _BudgetPreviewPageState createState() => _BudgetPreviewPageState();
}

class _BudgetPreviewPageState extends State<BudgetPreviewPage> {

  Sheet sheet;
  BudgetProperties budgetProperties;
  List<Product> products;

  @override
  void initState() {
    super.initState();

    _fetchSheet();
  }

  _fetchSheet() async {
    final spreadsheet = await SheetsApi(httpClient).spreadsheets.get(widget.sheetId, includeGridData: true);
    final firstSheet = spreadsheet.sheets[0];
    final products = _getProductsFromSheet(firstSheet);

    final firstProductRow = firstSheet.data.first.rowData[2];
    final categories = await _getDataValidationValues(_getValueAtRange, firstProductRow.values[4]);
    final owners = await _getDataValidationValues(_getValueAtRange, firstProductRow.values[5]);
    final types = await _getDataValidationValues(_getValueAtRange, firstProductRow.values[6]);
    final budgetProperties = BudgetProperties(spreadsheet, firstSheet, categories, owners, types, products.length + 3);

    print(products);
    setState(() {
      this.sheet = firstSheet;
      this.budgetProperties = budgetProperties;
      this.products = products;
    });
  }

  List<Product> _getProductsFromSheet(Sheet sheet) {
    return sheet.data.first.rowData
      .skip(2)
      .where((gridData) => gridData.values[1].formattedValue != null)
      .map((rowData) => Product.fromRowData(rowData))
      .toList();
  }

  Future<List<String>> _getValueAtRange(String range) async {
    final values = await SheetsApi(httpClient).spreadsheets.values.get(widget.sheetId, range, majorDimension: "COLUMNS");
    return values.values.first.map((object) => object.toString()).toList();
  }

  static Future<List<String>> _getDataValidationValues(GetValuesAtRange getValueAtRange, CellData cell) async {
    final condition = cell.dataValidation?.condition;
    if (condition == null) return [];

    switch (condition.type) {
      case "ONE_OF_LIST":
        return condition.values.map((conditionValue) => conditionValue.userEnteredValue).toList();
      case "ONE_OF_RANGE":
        final range = condition.values.first.userEnteredValue.substring(1);
        return await getValueAtRange(range);

      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sheet != null ? sheet.properties.title : "Loading budget...")
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => Divider(color: Colors.grey),
        itemCount: products?.length ?? 0,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text('${product.productName}, ${product.amount} zł, ${product.category}, ${product.owner}, ${product.type}'),
          );
        },
      ),
      floatingActionButton: sheet != null ? FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text("Add"),
        onPressed: () => Navigator.of(context).pushNamed("/add_product", arguments: {"budget_properties": budgetProperties})
      ) : null
    );
  }
}
