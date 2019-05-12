// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BudgetConfiguration _$BudgetConfigurationFromJson(Map<String, dynamic> json) {
  return BudgetConfiguration(
      json['spreadsheetId'] as String,
      json['dataSheetId'] as String,
      json['dataRange'] as String,
      json['entryMetadata'] == null
          ? null
          : EntryMetadata.fromJson(
              json['entryMetadata'] as Map<String, dynamic>));
}

Map<String, dynamic> _$BudgetConfigurationToJson(
        BudgetConfiguration instance) =>
    <String, dynamic>{
      'spreadsheetId': instance.spreadsheetId,
      'dataSheetId': instance.dataSheetId,
      'dataRange': instance.dataRange,
      'entryMetadata': instance.entryMetadata
    };
