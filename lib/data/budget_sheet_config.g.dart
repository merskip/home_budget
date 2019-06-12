// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_sheet_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BudgetSheetConfig _$BudgetSheetConfigFromJson(Map<String, dynamic> json) {
  return BudgetSheetConfig(
      json['spreadsheetTitle'] as String,
      json['dataSheetTitle'] as String,
      json['spreadsheetId'] as String,
      json['dataSheetId'] as String,
      json['dataRange'] as String,
      (json['columns'] as List)
          ?.map((e) => e == null
              ? null
              : ColumnDescription.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$BudgetSheetConfigToJson(BudgetSheetConfig instance) =>
    <String, dynamic>{
      'spreadsheetTitle': instance.spreadsheetTitle,
      'dataSheetTitle': instance.dataSheetTitle,
      'spreadsheetId': instance.spreadsheetId,
      'dataSheetId': instance.dataSheetId,
      'dataRange': instance.dataRange,
      'columns': instance.columns
    };

ColumnDescription _$ColumnDescriptionFromJson(Map<String, dynamic> json) {
  return ColumnDescription(
      json['title'] as String,
      _$enumDecodeNullable(_$DisplayTypeEnumMap, json['displayType']),
      null,
      _$enumDecodeNullable(_$ValueValidationEnumMap, json['valueValidation']),
      json['dateFormat'] as String,
      (json['validationValues'] as List)?.map((e) => e as String)?.toList());
}

Map<String, dynamic> _$ColumnDescriptionToJson(ColumnDescription instance) =>
    <String, dynamic>{
      'title': instance.title,
      'displayType': _$DisplayTypeEnumMap[instance.displayType],
      'valueValidation': _$ValueValidationEnumMap[instance.valueValidation],
      'dateFormat': instance.dateFormat,
      'validationValues': instance.validationValues
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$DisplayTypeEnumMap = <DisplayType, dynamic>{
  DisplayType.text: 'text',
  DisplayType.title: 'title',
  DisplayType.amount: 'amount',
  DisplayType.date: 'date',
  DisplayType.category: 'category'
};

const _$ValueValidationEnumMap = <ValueValidation, dynamic>{
  ValueValidation.none: 'none',
  ValueValidation.oneOfList: 'oneOfList'
};
