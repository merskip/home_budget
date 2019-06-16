import 'dart:core';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:home_budget/data/a1_range.dart';

part 'budget_sheet_config.g.dart';

@JsonSerializable()
class BudgetSheetConfig {

  String spreadsheetTitle;
  String dataSheetTitle;

  String spreadsheetId;
  String dataSheetId;
  String dataRange;
  List<ColumnDescription> columns;

  String headerTitle;
  String headerDataRange;

  BudgetSheetConfig(this.spreadsheetTitle, this.dataSheetTitle,
                    this.spreadsheetId, this.dataSheetId,
                    this.dataRange, this.columns);

  factory BudgetSheetConfig.fromJson(Map<String, dynamic> json) => _$BudgetSheetConfigFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetSheetConfigToJson(this);
}

@JsonSerializable()
class ColumnDescription {

  String title;
  DisplayType displayType;
  A1Range range;
  ValueValidation valueValidation;
  String dateFormat;
  List<String> validationValues;
  String exampleValue;

  ColumnDescription(this.title, this.displayType, this.range, this.valueValidation, this.dateFormat, this.validationValues, {this.exampleValue});

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

class DisplayTypeHelper {

  static String getTitle(DisplayType displayType) {
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
        return "unknown";
    }
  }

  static IconData getIcon(DisplayType displayType) {
    switch (displayType) {
      case DisplayType.title:
        return Icons.title;
      case DisplayType.amount:
        return Icons.attach_money;
      case DisplayType.date:
        return Icons.date_range;
      case DisplayType.category:
        return Icons.category;
      case DisplayType.text:
      default:
        return Icons.short_text;
    }
  }
}

enum ValueValidation {
  none,
  oneOfList
}
