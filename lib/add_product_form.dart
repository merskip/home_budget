import 'package:flutter/material.dart';

import 'BudgetProperties.dart';

class AddProductForm extends StatefulWidget {

  final BudgetProperties budgetProperties;

  AddProductForm(this.budgetProperties);

  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {

  final _formKey = GlobalKey<FormState>();

  dynamic _selectedCategory;
  dynamic _selectedOwner;
  dynamic _selectedType;

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
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    Scaffold.of(context).showSnackBar(SnackBar(content: Text('Processing Data')));
                  }
                },
                child: Text('Add product'),
              ),
            ),
          ]
        )
      )
    );
}