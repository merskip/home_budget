import 'package:googleapis/sheets/v4.dart';

typedef Future<List<String>> GetValuesAtRange(String range);


class BudgetProperties {

  final List<String> categories;
  final List<String> owners;
  final List<String> types;

  BudgetProperties(this.categories, this.owners, this.types);

  static Future<BudgetProperties> fromSheet(Sheet sheet, GetValuesAtRange getValueAtRange) async {
    final firstProductRow = sheet.data.first.rowData[2];
    final categoryCell = firstProductRow.values[4];
    final ownerCell = firstProductRow.values[5];
    final typeCell = firstProductRow.values[6];

    // TODO: Make parallel
    final categories = await _getDataValidationValues(getValueAtRange, categoryCell);
    final owners = await _getDataValidationValues(getValueAtRange, ownerCell);
    final types = await _getDataValidationValues(getValueAtRange, typeCell);

    return BudgetProperties(categories, owners, types);
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
}