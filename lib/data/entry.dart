import 'package:intl/intl.dart';
import 'budget_sheet_config.dart';

class Entry {

  List<EntryValue> values;

  Entry(this.values);

  String get title => _findEntryValueOrNull(DisplayType.title)?.value;

  DateTime get date {
    final entryValue = _findEntryValueOrNull(DisplayType.date);
    if (entryValue == null) return null;
    return DateFormat(entryValue.columnDescription.dateFormat).parse(entryValue.value);
  }

  String get amount => _findEntryValueOrNull(DisplayType.amount)?.value;

  String get category => _findEntryValueOrNull(DisplayType.category)?.value;

  EntryValue _findEntryValueOrNull(DisplayType displayType) =>
    values.firstWhere((value) => value.columnDescription.displayType == displayType, orElse: () => null);

  bool isEmpty() =>
    values.first.value == null || values.first.value == "";

  @override
  String toString() => "Entry{title: $title, amount: $amount, date: $date, category: $category}";

}

class EntryValue {

  final String value;
  final ColumnDescription columnDescription;

  EntryValue(this.value, this.columnDescription);
}