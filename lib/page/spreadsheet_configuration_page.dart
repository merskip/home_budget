import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:home_budget/model/budget_configuration.dart';

import 'main.dart';

class SpreadsheetConfigurationPage extends StatefulWidget {

  final File spreadsheet;

  final Function(BudgetConfiguration) callback;

  const SpreadsheetConfigurationPage(this.spreadsheet, this.callback, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SpreadsheetConfigurationState();
}

class SpreadsheetConfigurationState extends State<SpreadsheetConfigurationPage> with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();

  Spreadsheet spreadsheet;

  Sheet selectedSheet;
  String enteredDataRange;

  @override
  void initState() {
    super.initState();

    SheetsApi(httpClient).spreadsheets.get(widget.spreadsheet.id, includeGridData: false)
      .then((spreadsheet) {
      setState(() {
        this.spreadsheet = spreadsheet;
      });
    });
  }

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: AppBar(title: Text("Configuration spreadsheet")),
      body: spreadsheet == null
        ? Center(child: CircularProgressIndicator())
        : _configurationForm(context)
    );

  Widget _configurationForm(BuildContext context) =>
    Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _sheetsChips(context),
            if (selectedSheet != null) _sheetConfiguration(selectedSheet, context)
          ],
        )
      ),
    );

  Widget _sheetsChips(BuildContext context) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Select spreadsheet with budget entries"),
        Wrap(
          spacing: 8,
          children: spreadsheet.sheets.map((sheet) =>
            ChoiceChip(
              label: Text(sheet.properties.title),
              selected: selectedSheet == sheet,
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected)
                    selectedSheet = sheet;
                  else if (!isSelected && selectedSheet == sheet)
                    selectedSheet = null;
                });
              },
            )
          ).toList(),
        )
      ]);

  Widget _sheetConfiguration(Sheet sheet, BuildContext context) =>
    Column(
      children: <Widget>[
        SizedBox(height: 16),
        _dataRangeTextField(context)
      ]
    );

  Widget _dataRangeTextField(BuildContext context) =>
    TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Data range",
        hintText: "A1:D"
      ),
      autofocus: true,
      textInputAction: TextInputAction.next,
      onSubmitted: (input) {
        setState(() {
          this.enteredDataRange = input;
        });
      },
    );
}