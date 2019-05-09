import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart';

import 'BudgetProperties.dart';
import 'Product.dart';
import 'google_http_client.dart';
import 'main.dart';


class BudgetPreviewPage extends StatefulWidget {

  final File budgetFile;

  BudgetPreviewPage({Key key, this.budgetFile}) : super(key: key);

  @override
  _BudgetPreviewPageState createState() => _BudgetPreviewPageState();
}

class _BudgetPreviewPageState extends State<BudgetPreviewPage> {

  Map<String, String> authHeaders;

  Sheet sheet;
  BudgetProperties budgetProperties;
  List<Product> products;

  @override
  void initState() {
    super.initState();

    _fetchSheet();
  }

  _fetchSheet() async {
    authHeaders = await googleSignIn.currentUser.authHeaders;
    final httpClient = GoogleHttpClient(authHeaders);

    final spreadsheet = await SheetsApi(httpClient).spreadsheets.get(widget.budgetFile.id, includeGridData: true);
    final firstSheet = spreadsheet.sheets[0];
    final products = _getProductsFromSheet(firstSheet);

    final budgetProperties = await BudgetProperties.fromSheet(firstSheet, (range) async {
      final values = await SheetsApi(httpClient).spreadsheets.values.get(widget.budgetFile.id, range, majorDimension: "COLUMNS");
      return values.values.first.map((object) => object.toString()).toList();
    });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sheet != null ? "Sheet ${sheet.properties.title}" : "Loading ${widget.budgetFile.name}...")
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
