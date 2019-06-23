import 'dart:convert';
import 'dart:io';

import 'package:home_budget/data/application_config.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:home_budget/util/double.dart';
import 'package:home_budget/util/receipt_reader.dart';
import 'package:http/http.dart';

import '../main.dart';
import '../data/receipt.dart';
import '../data/budget_sheet_config.dart';
import 'budget_add_entry_screen.dart';

class ReceiptRecognizeScreen extends StatefulWidget {

  final File imageFile;

  const ReceiptRecognizeScreen({Key key, this.imageFile}) : super(key: key);

  @override
  _ReceiptRecognizeScreenState createState() => _ReceiptRecognizeScreenState();
}

class _ReceiptRecognizeScreenState extends State<ReceiptRecognizeScreen> {

  Receipt receipt;
  List<ListItem> listItems;

  List<ReceiptProduct> get selectedProducts {
    return listItems.map((listItem) {
      if (listItem is ProductListItem && listItem.isSelected)
        return listItem.product;
      else
        return null;
    }).where((p) => p != null).toList() ?? [];
  }

  List<ReceiptProduct> get selectableProducts {
    return listItems.map((listItem) {
      if (listItem is ProductListItem && listItem.isSelectable)
        return listItem.product;
      else
        return null;
    }).where((p) => p != null).toList() ?? [];
  }

  double get totalSelectedAmount {
    return selectedProducts.map((p) => p.totalAmount).fold(0, (p, c) => p + c);
  }

  @override
  void initState() {
    super.initState();
    _recognizeImage();
  }

  _recognizeImage() async {
    final fullText = await _recognizeTextFromImage(widget.imageFile);
    print("Recognized text: $fullText");
    final textLines = fullText.split("\n");
    this.receipt = ReceiptReader().read(textLines);

    setState(() {
      List<ListItem> listItems = [];
      if (receipt.isMalformed())
        listItems.add(MalformedWarningListItem());
      listItems.add(ReceiptSummaryListItem(receipt));
      listItems.addAll(receipt.products.map((product) => ProductListItem(product)));
      this.listItems = listItems;
    });
  }

  Future<String> _recognizeTextFromImage(File imageFile) async {
    final imageData = await imageFile.readAsBytes();
    final imageBase64 = base64Encode(imageData);

    final request = Request("POST", Uri.parse("https://vision.googleapis.com/v1/images:annotate"));
    request.headers["Content-Type"] = "application/json; charset=utf-8";
    request.headers["Authorization"] = "Bearer ";
    request.body = """
{
  "requests": [
    {
      "image": {
        "content": "$imageBase64"
      },
      "features": [
        {
          "type": "DOCUMENT_TEXT_DETECTION"
        }
      ]
    }
  ]
}
          """;
    final response = await httpClient.send(request);
    final jsonBody = await response.stream.bytesToString();
    final json = jsonDecode(jsonBody);
    return json["responses"][0]["fullTextAnnotation"]["text"];
  }

  _onSelectToggleSelection() {
    setState(() {
      final isAllSelected = selectedProducts.length == selectableProducts.length;
      listItems.forEach((listItem)  {
        if (listItem is ProductListItem && listItem.isSelectable) {
          listItem.isSelected = !isAllSelected;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      body: listItems != null ? _productsList() : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: receipt != null ? _receiptBottomBar() : null
    );

  _receiptBottomBar() =>
    Card(
      child: ListTile(
        title: Text("Selected ${moneyFormat(amount: totalSelectedAmount)}"),
        subtitle: Text("${selectedProducts.length} of ${selectableProducts?.length ?? 0}"),
        trailing: RaisedButton(
          child: Text("Add"),
          onPressed: selectedProducts.isNotEmpty ? () async {
            final title = selectedProducts.map((product) => product.text).join(", ");

            final preferences = await ApplicationConfig.readFromPreferences();
            final appendedEntry = await Navigator.push(context, MaterialPageRoute(builder: (context) =>
              BudgetAddEntryScreen(
                preferences.defaultBudgetSheetConfig,
                initialTitle: title,
                initialAmount: totalSelectedAmount,
                initialDate: receipt.dateOfPurchase)
            )) ?? false;
            if (appendedEntry) {
              setState(() {
                listItems = listItems.map((listItem) {
                  if (listItem is ProductListItem && listItem.isSelected) {
                    listItem.isCompleted = true;
                    listItem.isSelected = false;
                  }
                  return listItem;
                }).toList();

                final allProductsAreCompleted = listItems.where((listItem) {
                  return listItem is ProductListItem && listItem.isCompleted;
                }).length == receipt.products.length;

                if (allProductsAreCompleted) {
                  Navigator.of(context).pop(true);
                }
              });
            }
          } : null,
        ),
      )
    );

  _productsList() =>
    CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          forceElevated: true,
          elevation: 4,
          expandedHeight: 128,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.file(widget.imageFile, fit: BoxFit.cover,
              color: Colors.black38,
              colorBlendMode: BlendMode.srcATop),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.select_all),
              onPressed: () => _onSelectToggleSelection()
            )
          ],
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final listItem = listItems[index];

            if (listItem is ReceiptSummaryListItem) {
              return _receiptSummary(listItem.receipt);
            }
            else if (listItem is MalformedWarningListItem) {
              return _malformedWarningListItem();
            }
            else if (listItem is ProductListItem) {
              return _productListItem(listItem);
            }
          }, childCount: listItems.length)
        )
      ]
    );

  _receiptSummary(Receipt receipt) =>
    ListTile(
      leading: Container(
        width: 48,
        alignment: Alignment.center,
        child: Icon(Icons.receipt)
      ),
      title: Text("Total amount"),
      subtitle: Text(_formatPurchaseDate(receipt.dateOfPurchase)),
      trailing: Text(moneyFormat(amount: receipt.totalAmount, simple: false),
        style: Theme.of(context).textTheme.title
      ),
    );

  _formatPurchaseDate(DateTime date) {
    if (date == null) return "Unknown date of purchse";
    return DateFormat("dd.MM.yyyy").format(date);
  }

  _malformedWarningListItem() =>
    ListTile(
      leading: Container(
        width: 48,
        alignment: Alignment.center,
        child: Icon(Icons.warning,
          color: Theme.of(context).errorColor
        )
      ),
      title: Text("The receipt seems malformed")
    );

  _productListItem(ProductListItem listItem) {
    final product = listItem.product;
    return ListTile(
      leading: listItem.isCompleted ? Container(
        width: 48,
        alignment: Alignment.center,
        child: Icon(Icons.check, color: Colors.green)
      ) : Checkbox(
        value: listItem.isSelected,
        onChanged: listItem.isSelectable ? (_) => _toggleSelectionProduct(listItem) : null
      ),
      title: Text(product.prettyText + " (${product.taxLevel ?? "?"})"),
      subtitle: product.amount != 1.0 ? Text("${product.amount} × ${moneyFormat(amount: product.unitPrice)}") : null,
      trailing: Text(moneyFormat(amount: product.totalAmount),
        style: Theme.of(context).textTheme.body2),
      selected: listItem.isSelected,
      enabled: listItem.isSelectable,
      onTap: () => _toggleSelectionProduct(listItem),
    );
  }

  _toggleSelectionProduct(ProductListItem listItem) {
    setState(() {
      listItem.isSelected = !listItem.isSelected;
    });
  }
}

abstract class ListItem {}

class ReceiptSummaryListItem extends ListItem {

  final Receipt receipt;

  ReceiptSummaryListItem(this.receipt);
}

class MalformedWarningListItem extends ListItem {
}

class ProductListItem extends ListItem {

  final ReceiptProduct product;
  bool isSelected = false;
  bool isCompleted = false;

  bool get isSelectable {
    return !isCompleted && !product.isMalformed();
  }

  ProductListItem(this.product);
}
