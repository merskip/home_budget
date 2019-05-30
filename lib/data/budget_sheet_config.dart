import 'dart:core';
import 'package:json_annotation/json_annotation.dart';

part 'package:home_budget/data/budget_sheet_config.g.dart';

@JsonSerializable()
class BudgetSheetConfig {

  final String spreadsheetId;
  final String dataSheetId;
  final String dataRange;
  final List<ColumnDescription> columns;

  BudgetSheetConfig(this.spreadsheetId, this.dataSheetId, this.dataRange, this.columns);

  factory BudgetSheetConfig.fromJson(Map<String, dynamic> json) => _$BudgetSheetConfigFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetSheetConfigToJson(this);
}

@JsonSerializable()
class ColumnDescription {

  final String title;
  final DisplayType displayType;
  final ValueValidation valueValidation;
  final String dateFormat;
  final List<String> validationValues;

  ColumnDescription(this.title, this.displayType, this.valueValidation, this.dateFormat, this.validationValues);

  factory ColumnDescription.fromJson(Map<String, dynamic> json) => _$ColumnDescriptionFromJson(json);

  Map<String, dynamic> toJson() => _$ColumnDescriptionToJson(this);
}

enum DisplayType {
  text,
  title,
  amount,
  date,
  category
}

enum ValueValidation {
  none,
  oneOfList
}
