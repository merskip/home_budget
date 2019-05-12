import 'package:json_annotation/json_annotation.dart';

part 'entry_metadata.g.dart';

@JsonSerializable()
class EntryMetadata {

  final Map<String, CellMetadata> cellsMetadata;

  EntryMetadata(this.cellsMetadata);

  CellMetadata getCellMetadataOrDefault({int columnIndex}) {
    if (cellsMetadata.containsKey(columnIndex.toString()))
      return cellsMetadata[columnIndex.toString()];
    else
      return CellMetadata(DisplayType.text, ValueValidation.none, null, null);
  }

  factory EntryMetadata.fromJson(Map<String, dynamic> json) => _$EntryMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$EntryMetadataToJson(this);
}

@JsonSerializable()
class CellMetadata {

  final DisplayType displayType;
  final ValueValidation valueValidation;
  final String dateFormat;
  final List<String> validationValues;

  CellMetadata(this.displayType, this.valueValidation, this.dateFormat, this.validationValues);

  factory CellMetadata.fromJson(Map<String, dynamic> json) => _$CellMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$CellMetadataToJson(this);
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

