import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart' show SheetsApi, Spreadsheet, Sheet, CellData;
import 'package:home_budget/data/budget_sheet_config.dart';
import 'package:home_budget/main.dart';

import 'column_configuration_screen.dart';

class BudgetSheetConfigScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => BudgetSheetConfigState();
}

class BudgetSheetConfigState extends State<BudgetSheetConfigScreen> with SingleTickerProviderStateMixin {

  Spreadsheet spreadsheet;

  Sheet selectedSheet;

  final _dataRangeFormKey = GlobalKey<FormState>();
  String enteredDataRange;

  final _startColumnController = TextEditingController();
  final _startRowController = TextEditingController();
  final _startRowFocusNode = FocusNode();
  final _endColumnController = TextEditingController();
  final _endColumnFocusNode = FocusNode();

  List<ColumnDescription> columns;

  @override
  void initState() {
    super.initState();

    _fetchSpreadsheet();
  }

  _fetchSpreadsheet() async {
    final spreadsheet = await SheetsApi(httpClient).spreadsheets.get(this.spreadsheet.spreadsheetId, includeGridData: false);
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
      this.enteredDataRange = dataRange;
      _fetchFirstDataRow(firstRowDataRange);
    }
  }

  _fetchFirstDataRow(rowRange) async {
    final spreadsheetWithData = await SheetsApi(httpClient).spreadsheets.get(this.spreadsheet.spreadsheetId, ranges: [rowRange], includeGridData: true);
    final singleSheet = spreadsheetWithData.sheets.first;
    final gridData = singleSheet.data.first;
    final firstRowCells = gridData.rowData.first.values;

    final cellsMetadataFutureList = firstRowCells.asMap().map((index, cellData) {
      return MapEntry(index, _createInitialCellMetadata(index, cellData));
    }).values.toList();
    final cellsMetadataList = await Future.wait(cellsMetadataFutureList);

    setState(() {
      this.columns = cellsMetadataList;
    });
  }

  Future<ColumnDescription> _createInitialCellMetadata(int index, CellData cellData) async {
    final displayType = _getDisplayType(index, cellData);
    final validationValues = await _getValidationValues(cellData);
    final valueValidation = validationValues != null ? ValueValidation.oneOfList : ValueValidation.none;
    final dateFormat = _getDateFormat(cellData);

    return ColumnDescription("Column ${index + 1}", displayType, null, valueValidation, dateFormat, validationValues);
  }

  DisplayType _getDisplayType(int index, CellData cellData) {
    switch (cellData.effectiveFormat.numberFormat?.type) {
      case "TEXT":
        return index == 0 ? DisplayType.title : DisplayType.text;
      case "CURRENCY":
        return DisplayType.amount;
      case "DATE":
        return DisplayType.date;
      default:
        return DisplayType.text;
    }
  }

  String _getDateFormat(CellData cellData) {
    if (cellData.effectiveFormat.numberFormat?.type == "DATE") {
      final pattern = cellData.effectiveFormat.numberFormat?.pattern;
      return pattern.replaceAll("\"", "'"); // Fix difference escape character from Sheets API and for Dart
    }
    return null;
  }

  Future<List<String>> _getValidationValues(CellData cellData) async {
    final condition = cellData.dataValidation?.condition;
    if (condition?.type == "ONE_OF_LIST") {
      return condition.values.map((conditionValue) => conditionValue.userEnteredValue).toList();
    }
    else if (condition?.type == "ONE_OF_RANGE") {
      final range = condition.values.first.userEnteredValue.substring(1);
      final values = await SheetsApi(httpClient).spreadsheets.values.get(spreadsheet.spreadsheetId, range, majorDimension: "COLUMNS");
      return values.values.first.map((object) => object.toString()).toList();
    }
    else {
      return null;
    }
  }

  _onConfirmationConfiguration(BuildContext context) async {
    final budgetConfiguration = BudgetSheetConfig(
      spreadsheet.spreadsheetId,
      selectedSheet.properties.sheetId.toString(),
      enteredDataRange,
      columns
    );
    Navigator.of(context).pop(budgetConfiguration);
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
    SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _sheetsChips(context),
            if (selectedSheet != null) _sheetConfiguration(selectedSheet, context)
          ],
        )
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
      _dataRangeForm(context),
      if (columns != null) _entriesConfiguration(context),
      if (columns != null) RaisedButton(
        child: Text("Confirm"),
        onPressed: () => _onConfirmationConfiguration(context)
      )
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

  Widget _entriesConfiguration(BuildContext context) =>
    Column(
      children: List<Widget>.generate(columns.length, (i) {
        return _entryCellWidget(context, i, columns[i]);
      })
    );

  Widget _entryCellWidget(BuildContext context, int index, ColumnDescription cellMetadata) =>
    ListTile(
      title: Text(cellMetadata.title),
      subtitle: Text(_getDisplayTypeText(cellMetadata.displayType)),
      onTap: () async {
        final newCellMetadata = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => ColumnConfigurationScreen(cellMetadata))
        );
        if (newCellMetadata != null) {
          setState(() {
            columns[index] = newCellMetadata;
          });
        }
      },
    );

  String _getDisplayTypeText(DisplayType displayType) {
    switch (displayType) {
      case DisplayType.text:
        return "Text";
      case DisplayType.title:
        return "Title";
      case DisplayType.amount:
        return "Amount";
      case DisplayType.date:
        return "Date";
      case DisplayType.category:
        return "Category";
      default:
        return "Unknown";
    }
  }
}