// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntryMetadata _$EntryMetadataFromJson(Map<String, dynamic> json) {
  return EntryMetadata((json['cellsMetadata'] as Map<String, dynamic>)?.map(
    (k, e) => MapEntry(
        k, e == null ? null : CellMetadata.fromJson(e as Map<String, dynamic>)),
  ));
}

Map<String, dynamic> _$EntryMetadataToJson(EntryMetadata instance) =>
    <String, dynamic>{'cellsMetadata': instance.cellsMetadata};

CellMetadata _$CellMetadataFromJson(Map<String, dynamic> json) {
  return CellMetadata(
      json['title'] as String,
      _$enumDecodeNullable(_$DisplayTypeEnumMap, json['displayType']),
      _$enumDecodeNullable(_$ValueValidationEnumMap, json['valueValidation']),
      json['dateFormat'] as String,
      (json['validationValues'] as List)?.map((e) => e as String)?.toList());
}

Map<String, dynamic> _$CellMetadataToJson(CellMetadata instance) =>
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
