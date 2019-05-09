import 'package:googleapis/sheets/v4.dart';

typedef Future<List<String>> GetValuesAtRange(String range);


class BudgetProperties {

  final Spreadsheet spreadsheet;
  final Sheet sheet;

  final List<String> categories;
  final List<String> owners;
  final List<String> types;

  final int nextFreeRowIndex;

  BudgetProperties(this.spreadsheet, this.sheet, this.categories, this.owners, this.types, this.nextFreeRowIndex);
}