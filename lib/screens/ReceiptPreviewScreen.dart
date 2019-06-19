
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';

class Product {

  final String text;
  final double amount;
  final double unitPrice;
  final double totalAmount;
  final String taxLevel;

  Product({this.text, this.amount, this.unitPrice, this.totalAmount, this.taxLevel});
}

class ReceiptPreviewScreen extends StatefulWidget {

  final File imageFile;

  const ReceiptPreviewScreen({Key key, this.imageFile}) : super(key: key);

  @override
  _ReceiptPreviewScreenState createState() => _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends State<ReceiptPreviewScreen> {

  List<Product> products;
  List<ListItem> listItems;

  List<Product> selectedProducts = [];

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
    final productsText = fullText.split("\n")
      .skipWhile((line) => line != "PARAGON FISKALNY")
      .skip(1)
      .takeWhile((line) => !line.startsWith("SPRZEDAZ OPODATKOWANA"));
    print(productsText.join("\n"));

    products = _getProducts(productsText.toList());
    setState(() {
      List<ListItem> listItems = [ReceiptImageListItem(widget.imageFile)];
      listItems.addAll(products.map((product) => ProductListItem(product)));
      this.listItems = listItems;
    });
  }

  List<Product> _getProducts(List<String> textLines) {
    var products = List<Product>();
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

  Product _parseProduct(String line) {
    final regex = RegExp(r"^(.*)\s((?:\d+[,.])?\d+)\s*.\s*(\d+[,.]\d+)\s+(\d+[,.]\d+)\s?([A-Z])$");
    final match = regex.firstMatch(line);
    if (match == null) return null;
    return Product(
      text: match.group(1).trim(),
      amount: double.parse(match.group(2).replaceAll(",", ".")),
      unitPrice: double.parse(match.group(3).replaceAll(",", ".")),
      totalAmount: double.parse(match.group(4).replaceAll(",", ".")),
      taxLevel: match.group(5).trim()
    );
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

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: AppBar(title: Text("Receipt")),
      body: listItems != null ? _productsList() : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: Card(
        child: ListTile(
          title: Text("Selected ${selectedProducts.length} of ${products?.length ?? 0}"),
          subtitle: Text("Total $totalSelectedAmount PLN"),
          trailing: RaisedButton(onPressed: () {}, child: Text("Add")),
        )

      ),
    );

  _productsList() =>
    ListView.builder(
      itemCount: listItems.length,
      itemBuilder: (context, index) {
        final listItem = listItems[index];

        if (listItem is ReceiptImageListItem) {
          return Image.file(listItem.imageFile);
        }
        else if (listItem is ProductListItem) {
          final product = listItem.product;
          return ListTile(
            leading: Checkbox(
              value: selectedProducts.contains(product),
              onChanged: (_) => _toggleSelectionProduct(product)
            ),
            title: Text(product.text),
            subtitle: Text(product.amount != 1.0 ? "${product.amount} × ${product.unitPrice} zł (${product.taxLevel})" : "(${product.taxLevel})"),
            trailing: Text("${product.totalAmount} zł", style: Theme.of(context).textTheme.title),
            selected: selectedProducts.contains(product),
            onTap: () => _toggleSelectionProduct(product),
          );
        }
      }
    );

  _toggleSelectionProduct(Product product) {
    setState(() {
      if (selectedProducts.contains(product))
        selectedProducts.remove(product);
      else
        selectedProducts.add(product);
    });
  }
}

abstract class ListItem {}

class ReceiptImageListItem extends ListItem {

  final File imageFile;

  ReceiptImageListItem(this.imageFile);
}

class ProductListItem extends ListItem {

  final Product product;

  ProductListItem(this.product);
}
