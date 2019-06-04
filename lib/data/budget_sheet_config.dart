import 'dart:core';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../util/a1_range.dart';

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
  final A1Range range;
  final ValueValidation valueValidation;
  final String dateFormat;
  final List<String> validationValues;
  final String exampleValue;

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
