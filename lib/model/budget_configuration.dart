import 'dart:core';
import 'package:json_annotation/json_annotation.dart';

import 'entry_metadata.dart';

part 'budget_configuration.g.dart';

@JsonSerializable()
class BudgetConfiguration {

  final String spreadsheetId;
  final String dataSheetId;
  final String dataRange;
  final EntryMetadata entryMetadata;

  BudgetConfiguration(this.spreadsheetId, this.dataSheetId, this.dataRange, this.entryMetadata);

  factory BudgetConfiguration.fromJson(Map<String, dynamic> json) => _$BudgetConfigurationFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetConfigurationToJson(this);
}