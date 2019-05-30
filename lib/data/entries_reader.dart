
import 'package:googleapis/sheets/v4.dart';
import 'package:quiver/iterables.dart';

import 'package:home_budget/data/budget_sheet_config.dart';
import 'entry.dart';

class EntriesReader {

  final BudgetSheetConfig budgetSheetConfig;

  EntriesReader(this.budgetSheetConfig);

  List<Entry> readFromGridData(GridData gridData) {
    final entries = <Entry>[];

    for (var rowData in gridData.rowData) {
      final entryValues = <EntryValue>[];
      for (var pair in zip([rowData.values, budgetSheetConfig.columns])) {
        final cellData = pair[0] as CellData;
        final cellMetadata = pair[1] as ColumnDescription;

        entryValues.add(_getEntryValue(cellData, cellMetadata));
      }

      final entry = Entry(entryValues);
      if (!entry.isEmpty())
        entries.add(entry);
    }

    return entries;
  }

  EntryValue _getEntryValue(CellData cellData, ColumnDescription cellMetadata) =>
    EntryValue(cellData.formattedValue, cellMetadata);
}