
import 'package:googleapis/sheets/v4.dart';

import '../main.dart';
import 'package:home_budget/data/a1_range.dart';
import '../data/budget_sheet_config.dart';

class SheetConfigurationReader {

  String spreadsheetId;
  Sheet sheet;

  SheetConfigurationReader(this.spreadsheetId, this.sheet);

  Future<List<ColumnDescription>> read({A1Range dataRange}) async {
    final rowData = await _fetchFirstRowData(dataRange);
    final columnDescriptionsList = rowData.values.asMap().map((index, cellData) {
      return MapEntry(index, _createInitialCellMetadata(index, cellData, dataRange.startColumnIndex + index));
    }).values.toList();
    return await Future.wait(columnDescriptionsList);
  }

  Future<RowData> _fetchFirstRowData(A1Range dataRange) async {
    final dataRangeWithFirstRow = dataRange.withDefaultSheet(sheet).withSingleRow();
    final spreadsheetResult = await SheetsApi(httpClient).spreadsheets.get(
      spreadsheetId,
      ranges: [dataRangeWithFirstRow.toString()],
      includeGridData: true,
      $fields: "sheets(data(rowData))"
    );
    return spreadsheetResult.sheets.first.data.first.rowData.first;
  }

  Future<ColumnDescription> _createInitialCellMetadata(int index, CellData cellData, int columnIndex) async {
    final displayType = _getDisplayType(index, cellData);
    final title = _getDefaultColumnTitle(displayType, index);
    final validationValues = await _getValidationValues(cellData);
    final valueValidation = validationValues != null ? ValueValidation.oneOfList : ValueValidation.none;
    final dateFormat = _getDateFormat(cellData);

    return ColumnDescription(
      title, displayType, A1Range.only(startColumnIndex: columnIndex),
      valueValidation, dateFormat, validationValues,
      exampleValue: cellData.formattedValue
    );
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

  String _getDefaultColumnTitle(DisplayType displayType, int index) {
    switch (displayType) {
      case DisplayType.title:
      case DisplayType.amount:
      case DisplayType.date:
      case DisplayType.category:
        return DisplayTypeHelper.getTitle(displayType);
      case DisplayType.text:
      default:
        return "Column ${index + 1}";
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
      final values = await SheetsApi(httpClient).spreadsheets.values.get(spreadsheetId, range, majorDimension: "COLUMNS");
      return values.values.first.map((object) => object.toString()).toList();
    }
    else {
      return null;
    }
  }
}