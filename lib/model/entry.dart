import 'entry_metadata.dart';

class Entry {

  List<EntryValue> values;

  Entry(this.values);

  String get title => _findEntryValueOrNull(DisplayType.title).value;

  String get date => _findEntryValueOrNull(DisplayType.date).value;

  String get amount => _findEntryValueOrNull(DisplayType.amount).value;

  String get category => _findEntryValueOrNull(DisplayType.category).value;

  EntryValue _findEntryValueOrNull(DisplayType displayType) =>
    values.firstWhere((value) => value.metadata.displayType == displayType);

  @override
  String toString() => "Entry{title: $title, amount: $amount, date: $date, category: $category}";

}

class EntryValue {

  final String value;
  final CellMetadata metadata;

  EntryValue(this.value, this.metadata);
}