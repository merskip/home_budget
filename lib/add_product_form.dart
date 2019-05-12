import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'BudgetProperties.dart';
import 'Product.dart';
import 'main.dart';
import 'constants.dart';

class AddProductForm extends StatefulWidget {

  final BudgetProperties budgetProperties;

  AddProductForm(this.budgetProperties);

  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {

  final _formKey = GlobalKey<FormState>();

  String _enteredProductName;
  String _enteredAmount;
  String _selectedCategory;
  String _selectedOwner;
  String _selectedType;

  _onSubmit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      final newProduct = _getProductFromForm();
      _addProductToSheet(newProduct);
    }
  }

  Product _getProductFromForm() {
    final todayDate = DateFormat("dd.MM.yyyy").format(DateTime.now());
    return Product(_enteredProductName, double.parse(_enteredAmount), todayDate, _selectedCategory, _selectedOwner, _selectedType);
  }

  _addProductToSheet(Product product) async {
    final spreadsheetId = widget.budgetProperties.spreadsheet.spreadsheetId;
    final valueRange = sheets.ValueRange()
      ..range = budgetDataRange
      ..values = [[product.productName, product.amount, product.date, product.category, product.owner, product.type]]
      ..majorDimension = "ROWS";

    await sheets.SheetsApi(httpClient).spreadsheets.values
      .append(valueRange, spreadsheetId, valueRange.range, valueInputOption: "USER_ENTERED");
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: AppBar(
        title: Text("Add new prdouct"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                labelText: "Product name",
                hintText: "Food"
              ),
              validator: (value) {
                if (value.isEmpty) return 'Please enter some product name';
              },
              onSaved: (value) {
                _enteredProductName = value;
              }
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Amount",
                hintText: "1,00"
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
              validator: (value) {
                if (value.isEmpty) return 'Please enter some amount';
              },
              onSaved: (value) {
                _enteredAmount = value;
              }
            ),
            Row(
              children: <Widget>[
                Text("Category: "),
                DropdownButton(
                  value: _selectedCategory,
                  items: widget.budgetProperties.categories.map((category) {
                    return DropdownMenuItem(value: category, child: Text(category));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value),
                )
              ]
            ),
            Row(
              children: <Widget>[
                Text("Owner: "),
                DropdownButton(
                  value: _selectedOwner,
                  items: widget.budgetProperties.owners.map((owner) {
                    return DropdownMenuItem(value: owner, child: Text(owner));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedOwner = value),
                )
              ]
            ),
            Row(
              children: <Widget>[
                Text("Type: "),
                DropdownButton(
                  value: _selectedType,
                  items: widget.budgetProperties.types.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedType = value),
                )
              ]
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                onPressed: _onSubmit,
                child: Text('Add product'),
              ),
            ),
          ]
        )
      )
    );
}