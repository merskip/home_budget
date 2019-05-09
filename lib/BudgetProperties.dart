
import 'package:googleapis/sheets/v4.dart';

class BudgetProperties {

  final List<String> categories;
  final List<String> owners;
  final List<String> types;

  BudgetProperties(this.categories, this.owners, this.types);

  factory BudgetProperties.fromSheet(Sheet sheet) {



    return BudgetProperties([], [], []);
  }
}