import 'package:flutter/material.dart';
import 'package:googleapis/sheets/v4.dart' show SheetsApi;
import "package:collection/collection.dart";
import 'package:home_budget/model/budget_configuration.dart';
import 'package:home_budget/model/entries_reader.dart';
import 'package:home_budget/model/entry.dart';

import 'package:home_budget/page/main.dart';
import 'package:intl/intl.dart';

class BudgetEntriesListPage extends StatefulWidget {

  final BudgetConfiguration budgetConfiguration;

  BudgetEntriesListPage({Key key, this.budgetConfiguration}) : super(key: key);

  @override
  _BudgetEntriesListState createState() => _BudgetEntriesListState(budgetConfiguration);
}

class _BudgetEntriesListState extends State<BudgetEntriesListPage> {

  BudgetConfiguration budgetConfiguration;
  List<Entry> entries;
  List<ListItem> listItems;

  _BudgetEntriesListState(this.budgetConfiguration);

  @override
  void initState() {
    super.initState();

    _fetchBudget();
  }

  _fetchBudget() async {
    final dataRangeFirstPage = budgetConfiguration.dataRange + "100";
    final spreadsheet = await SheetsApi(httpClient).spreadsheets.get(budgetConfiguration.spreadsheetId, ranges: [dataRangeFirstPage], includeGridData: true);

    final gridData = spreadsheet.sheets.first.data.first; // Just get first interesting grid data, no should be more data

    final entriesReader = EntriesReader(budgetConfiguration);
    final entries = entriesReader.readFromGridData(gridData);
    final entriesGroupedByDate = groupBy(entries, (Entry entry) => entry.date);

    final listItems = <ListItem>[];
    entriesGroupedByDate.forEach((dateTime, entries) {
      listItems.add(DateHeaderItem(dateTime));
      listItems.addAll(entries.map((entry) => EntryItem(entry)));
    });

    setState(() {
      this.entries = entries;
      this.listItems = listItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: listItems == null ? Text("Loading budget...") : Text("Budget")
      ),
      body: listItems == null
        ? Center(child: CircularProgressIndicator())
        : _entriesListView(context)
    );
  }

  Widget _entriesListView(BuildContext context) =>
    Scrollbar(
      child: ListView.builder(
        itemCount: listItems.length,
        itemBuilder: (context, index) {
          final listItem = listItems[index];
          if (listItem is DateHeaderItem)
            return _dateHeaderItem(listItem);
          else if (listItem is EntryItem)
            return _entryItem(listItem);
        })
    );

  Widget _dateHeaderItem(DateHeaderItem item) =>
    Padding(
      padding: EdgeInsets.all(16),
      child: Text(DateFormat("EEEE, d MMMM yyyy").format(item.date))
    );

  Widget _entryItem(EntryItem item) =>
    Card(
      child: ListTile(
        title: Text(item.entry.title),
        subtitle: Text(item.entry.amount),
      )
    );
}

abstract class ListItem {}

class DateHeaderItem implements ListItem {
  final DateTime date;

  DateHeaderItem(this.date);
}

class EntryItem implements ListItem {
  final Entry entry;

  EntryItem(this.entry);
}
