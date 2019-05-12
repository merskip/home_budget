import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart' show SheetsApi, Spreadsheet, Sheet;
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

  Spreadsheet spreadsheet;

  Sheet selectedSheet;

  final _dataRangeFormKey = GlobalKey<FormState>();
  String enteredDataRange;

  final _startColumnController = TextEditingController();
  final _startRowController = TextEditingController();
  final _startRowFocusNode = FocusNode();
  final _endColumnController = TextEditingController();
  final _endColumnFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _fetchSpreadsheet();
  }

  _fetchSpreadsheet() async {
    final spreadsheet = await SheetsApi(httpClient).spreadsheets.get(widget.spreadsheet.id, includeGridData: false);
    setState(() {
      this.spreadsheet = spreadsheet;
    });
  }

  _onSubmitDataRangeForm() async {
    if (_dataRangeFormKey.currentState.validate()) {
      final sheetTitle = selectedSheet.properties.title;
      final startColumn = _startColumnController.text;
      final startRow = _startRowController.text;
      final endColumn = _endColumnController.text;
      final dataRange = "'$sheetTitle'!$startColumn$startRow:$endColumn";
      final firstRowDataRange = dataRange + startRow;
      _fetchFirstDataRow(firstRowDataRange);
    }
  }

  _fetchFirstDataRow(rowRange) async {
    final spreadsheetWithData = await SheetsApi(httpClient).spreadsheets.get(widget.spreadsheet.id, ranges: [rowRange], includeGridData: true);
    final singleSheet = spreadsheetWithData.sheets.first;
    final gridData = singleSheet.data.first;
    final firstRowCells = gridData.rowData.first.values;
    print(firstRowCells);
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
    Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _sheetsChips(context),
          if (selectedSheet != null) _sheetConfiguration(selectedSheet, context)
        ],
      )
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
    Column(children: <Widget>[
      SizedBox(height: 16),
      _dataRangeForm(context)
    ]);

  Widget _dataRangeForm(BuildContext context) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Range of data entries"),
        SizedBox(height: 12),
        Form(
          key: _dataRangeFormKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.ideographic,
            children: <Widget>[
              Flexible(child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Start column",
                  hintText: "A"
                ),
                autofocus: true,
                controller: _startColumnController,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (!RegExp(r'^[A-Z]+$').hasMatch(value)) return "Must be A-Z";
                },
                autovalidate: true,
                onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(_startRowFocusNode)
              )),
              SizedBox(width: 4),
              Flexible(child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Start row",
                  hintText: "2"
                ),
                focusNode: _startRowFocusNode,
                controller: _startRowController,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) return "Must be 0-9";
                },
                autovalidate: true,
                onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(_endColumnFocusNode)
              )),
              SizedBox(width: 4),
              Text(":"),
              SizedBox(width: 4),
              Flexible(child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "End column",
                  hintText: "D"
                ),
                focusNode: _endColumnFocusNode,
                controller: _endColumnController,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (!RegExp(r'^[A-Z]+$').hasMatch(value)) return "Must be A-Z";
                },
                autovalidate: true,
                onFieldSubmitted: (input) {
                  _onSubmitDataRangeForm();
                }
              )),
            ])
        )
      ]);

}