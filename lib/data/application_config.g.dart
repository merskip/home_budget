// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplicationConfig _$ApplicationConfigFromJson(Map<String, dynamic> json) {
  return ApplicationConfig(
      (json['budgetSheetsConfigs'] as List)
          ?.map((e) => e == null
              ? null
              : BudgetSheetConfig.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      json['defaultConfigIndex'] as int);
}

Map<String, dynamic> _$ApplicationConfigToJson(ApplicationConfig instance) =>
    <String, dynamic>{
      'budgetSheetsConfigs': instance.budgetSheetsConfigs,
      'defaultConfigIndex': instance.defaultConfigIndex
    };
