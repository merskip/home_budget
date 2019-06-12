import 'dart:math';

import 'package:googleapis/sheets/v4.dart';
import 'package:json_annotation/json_annotation.dart';

part 'a1_range.g.dart';

@JsonSerializable()
class A1Range {

  static final _a1Regex = RegExp(
    r"^" // beginning of string
    r"(?:'?(.+?)'?!)?" // (1) Optional sheet name
    r"([A-Z]+)?" // (2) start column |
    r"([0-9]+)?" // (3) start row    |- start cell
    r"(?::" // optional range separator
    r"([A-Z]+)?" // (4) end column |
    r"([0-9]+)?" // (5) end row    |- end cell
    r")?" // end range
    r"$" // ending of string
  );

  static final _chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

  final String sheet;
  final int startColumnIndex;
  final int startRowIndex;
  final int endColumnIndex;
  final int endRowIndex;

  A1Range(this.sheet, this.startColumnIndex, this.startRowIndex, this.endColumnIndex, this.endRowIndex);
  A1Range.only({this.sheet, this.startColumnIndex, this.startRowIndex, this.endColumnIndex, this.endRowIndex});

  factory A1Range.fromText(String a1notation) {
    if (a1notation == null) return null;
    final match = _a1Regex.firstMatch(a1notation);

    return A1Range.only(
      sheet: match[1],
      startColumnIndex: parseChars(match[2]),
      startRowIndex: _parseIndexOrNull(match[3]),
      endColumnIndex: parseChars(match[4]),
      endRowIndex: _parseIndexOrNull(match[5]),
    );
  }

  factory A1Range.fromJson(Map<String, dynamic> json) => _$A1RangeFromJson(json);

  Map<String, dynamic> toJson() => _$A1RangeToJson(this);

  static bool isValid(String a1notation) => _a1Regex.hasMatch(a1notation);

  static int _parseIndexOrNull(String value) {
    return value != null ? int.parse(value) - 1 : null;
  }

  static int parseChars(String text) {
    if (text == null) return null;
    var result = 0;
    text
      .split('')
      .reversed
      .toList()
      .asMap()
      .forEach(
        (index, char) => result += (_chars.indexOf(char) + 1) * pow(_chars.length, index)
    );
    return result - 1;
  }

  static String toChars(int value) {
    if (value == null) return null;
    List<String> result = [];
    while (value >= 0) {
      result.add(_chars[value % _chars.length]);
      value = value ~/ _chars.length - 1;
    }
    return result.reversed.join('');
  }

  A1Range withDefaultSheet(Sheet sheet) =>
    withDefaultSheetTitle(sheet.properties.title);

  /// Set sheet if not exists
  A1Range withDefaultSheetTitle(String sheet) =>
    A1Range(this.sheet ?? sheet, startColumnIndex, startRowIndex, endColumnIndex, endRowIndex);

  A1Range withSingleRow() =>
    A1Range(sheet, startColumnIndex, startRowIndex, endColumnIndex, startRowIndex);

  @override
  String toString() {
    var result = "";

    if (sheet != null) {
      if (sheet.contains(' '))
        result += "'$sheet'!";
      else
        result += "$sheet!";
    }

    if (startColumnIndex != null)
      result += toChars(startColumnIndex);
    if (startRowIndex != null)
      result += "${startRowIndex + 1}";

    if (endColumnIndex != null || endRowIndex != null) {
      result += ":";
      if (endColumnIndex != null)
        result += "${toChars(endColumnIndex)}";
      if (endRowIndex != null)
        result += "${endRowIndex + 1}";
    }

    return result;
  }
}