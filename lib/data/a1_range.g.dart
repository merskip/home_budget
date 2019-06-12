// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'a1_range.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

A1Range _$A1RangeFromJson(Map<String, dynamic> json) {
  return A1Range(
      json['sheet'] as String,
      json['startColumnIndex'] as int,
      json['startRowIndex'] as int,
      json['endColumnIndex'] as int,
      json['endRowIndex'] as int);
}

Map<String, dynamic> _$A1RangeToJson(A1Range instance) => <String, dynamic>{
      'sheet': instance.sheet,
      'startColumnIndex': instance.startColumnIndex,
      'startRowIndex': instance.startRowIndex,
      'endColumnIndex': instance.endColumnIndex,
      'endRowIndex': instance.endRowIndex
    };
