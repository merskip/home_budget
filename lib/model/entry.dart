import 'entry_metadata.dart';
import 'package:intl/intl.dart';

class Entry {

  List<EntryValue> values;

  Entry(this.values);

  String get title => _findEntryValueOrNull(DisplayType.title)?.value;

  DateTime get date {
    final entryValue = _findEntryValueOrNull(DisplayType.date);
    if (entryValue == null) return null;
    return DateFormat(entryValue.metadata.dateFormat).parse(entryValue.value);
  }

  String get amount => _findEntryValueOrNull(DisplayType.amount)?.value;

  String get category => _findEntryValueOrNull(DisplayType.category)?.value;

  EntryValue _findEntryValueOrNull(DisplayType displayType) =>
    values.firstWhere((value) => value.metadata.displayType == displayType, orElse: () => null);

  bool isEmpty() =>
    values.first.value == null || values.first.value == "";

  @override
  String toString() => "Entry{title: $title, amount: $amount, date: $date, category: $category}";

}

class EntryValue {

  final String value;
  final CellMetadata metadata;

  EntryValue(this.value, this.metadata);
}