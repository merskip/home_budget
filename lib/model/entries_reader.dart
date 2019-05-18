
import 'package:googleapis/sheets/v4.dart';
import 'package:quiver/iterables.dart';

import 'budget_configuration.dart';
import 'entry.dart';
import 'entry_metadata.dart';

class EntriesReader {

  final BudgetConfiguration budgetConfiguration;

  EntriesReader(this.budgetConfiguration);

  List<Entry> readFromGridData(GridData gridData) {
    final cellsMetadataList = budgetConfiguration.entryMetadata.cellsMetadata.values.toList();
    final entries = <Entry>[];

    for (var rowData in gridData.rowData) {
      final entryValues = <EntryValue>[];
      for (var pair in zip([rowData.values, cellsMetadataList])) {
        final cellData = pair[0] as CellData;
        final cellMetadata = pair[1] as CellMetadata;

        entryValues.add(_getEntryValue(cellData, cellMetadata));
      }

      final entry = Entry(entryValues);
      if (!entry.isEmpty())
        entries.add(entry);
    }

    return entries;
  }

  EntryValue _getEntryValue(CellData cellData, CellMetadata cellMetadata) =>
    EntryValue(cellData.formattedValue, cellMetadata);
}