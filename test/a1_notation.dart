
import 'package:home_budget/data/a1_range.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("To chars", () {
    expect(A1Range.toChars(0), equals("A"));
    expect(A1Range.toChars(1), equals("B"));

    expect(A1Range.toChars(24), equals("Y"));
    expect(A1Range.toChars(25), equals("Z"));

    expect(A1Range.toChars(26), equals("AA"));
    expect(A1Range.toChars(27), equals("AB"));
    expect(A1Range.toChars(28), equals("AC"));

    expect(A1Range.toChars(50), equals("AY"));
    expect(A1Range.toChars(51), equals("AZ"));

    expect(A1Range.toChars(52), equals("BA"));
    expect(A1Range.toChars(53), equals("BB"));
  });

  test("Parse chars", () {
    expect(A1Range.parseChars("A"), equals(0));
    expect(A1Range.parseChars("B"), equals(1));

    expect(A1Range.parseChars("Y"), equals(24));
    expect(A1Range.parseChars("Z"), equals(25));

    expect(A1Range.parseChars("AA"), equals(26));
    expect(A1Range.parseChars("AB"), equals(27));
    expect(A1Range.parseChars("AC"), equals(28));

    expect(A1Range.parseChars("AY"), equals(50));
    expect(A1Range.parseChars("AZ"), equals(51));

    expect(A1Range.parseChars("BA"), equals(52));
    expect(A1Range.parseChars("BB"), equals(53));
  });

  test("Parse A1", () {
    final range = A1Range.fromText("A1");

    expect(range.startColumnIndex, equals(0));
    expect(range.startRowIndex, equals(0));
    expect(range.toString(), equals("A1"));
  });
  test("Parse AA1", () {
    final range = A1Range.fromText("AA1");

    expect(range.startColumnIndex, equals(26));
    expect(range.startRowIndex, equals(0));
    expect(range.toString(), equals("AA1"));
  });

  test("Parse AZ1", () {
    final range = A1Range.fromText("AZ1");

    expect(range.startColumnIndex, equals(51));
    expect(range.startRowIndex, equals(0));
    expect(range.toString(), equals("AZ1"));
  });

  test("Parse BB1", () {
    final range = A1Range.fromText("BB1");

    expect(range.startColumnIndex, equals(53));
    expect(range.startRowIndex, equals(0));
    expect(range.toString(), equals("BB1"));
  });

  test("Parse A1:B2", () {
    final range = A1Range.fromText("A1:B2");

    expect(range.startColumnIndex, equals(0));
    expect(range.startRowIndex, equals(0));
    expect(range.endColumnIndex, equals(1));
    expect(range.endRowIndex, equals(1));
    expect(range.toString(), equals("A1:B2"));
  });

  test("Parse A1:B", () {
    final range = A1Range.fromText("A1:B");

    expect(range.startColumnIndex, equals(0));
    expect(range.startRowIndex, equals(0));
    expect(range.endColumnIndex, equals(1));
    expect(range.endRowIndex, equals(null));
    expect(range.toString(), equals("A1:B"));
  });

  test("Parse Sheet!A1:B", () {
    final range = A1Range.fromText("Sheet!A1:B");

    expect(range.startColumnIndex, equals(0));
    expect(range.startRowIndex, equals(0));
    expect(range.endColumnIndex, equals(1));
    expect(range.endRowIndex, equals(null));
    expect(range.toString(), equals("Sheet!A1:B"));
  });

  test("Parse 'Sheet with space'!A1:B", () {
    final range = A1Range.fromText("'Sheet with space'!A1:B");

    expect(range.startColumnIndex, equals(0));
    expect(range.startRowIndex, equals(0));
    expect(range.endColumnIndex, equals(1));
    expect(range.endRowIndex, equals(null));
    expect(range.toString(), equals("'Sheet with space'!A1:B"));
  });
}