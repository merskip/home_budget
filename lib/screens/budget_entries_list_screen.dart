import 'package:flutter/material.dart';
import 'package:googleapis/sheets/v4.dart' show SheetsApi, Sheet;
import "package:collection/collection.dart";
import 'package:home_budget/data/budget_sheet_config.dart';
import 'package:home_budget/data/entries_reader.dart';
import 'package:home_budget/data/entry.dart';
import 'package:home_budget/widgets/budget_flexible_space_bar.dart';
import 'package:intl/intl.dart';

import '../main.dart';

class BudgetEntriesListScreen extends StatefulWidget {

  final BudgetSheetConfig budgetSheetConfig;

  BudgetEntriesListScreen({Key key, this.budgetSheetConfig}) : super(key: key);

  @override
  BudgetEntriesListState createState() => BudgetEntriesListState(budgetSheetConfig);
}

class BudgetEntriesListState extends State<BudgetEntriesListScreen> {

  BudgetSheetConfig budgetConfig;

  Sheet sheet;
  List<Entry> entries;
  List<ListItem> listItems;
  String headerValue;

  BudgetEntriesListState(this.budgetConfig);

  @override
  void initState() {
    super.initState();
    _fetchBudget();
  }

  refreshBudget() {
    entries = null;
    listItems = null;
    _fetchBudget();
  }

  _fetchBudget() async {
    final entriesGroupedByDate = await _fetchEntries();
    final listItems = <ListItem>[];
    entriesGroupedByDate.forEach((dateTime, entries) {
      listItems.add(DateHeaderItem(dateTime));
      listItems.addAll(entries.map((entry) => EntryItem(entry)));
    });

    final headerValue = await _fetchHeaderValue();

    setState(() {
      this.sheet = sheet;
      this.entries = entries;
      this.listItems = listItems;
      this.headerValue = headerValue;
    });
  }

  Future<Map<DateTime, List<Entry>>> _fetchEntries() async {
    final dataRangeFirstPage = budgetConfig.dataRange + "100";
    final spreadsheet = await SheetsApi(httpClient).spreadsheets.get(budgetConfig.spreadsheetId, ranges: [dataRangeFirstPage], includeGridData: true);
    final sheet = spreadsheet.sheets.first;
    final gridData = sheet.data.first; // Just get first interesting grid data, no should be more data

    final entriesReader = EntriesReader(budgetConfig);
    final entries = entriesReader
      .readFromGridData(gridData)
      .reversed
      .toList();
    final entriesGroupedByDate = groupBy(entries, (Entry entry) => entry.date ?? DateTime.now());
    return entriesGroupedByDate;
  }

  Future<String> _fetchHeaderValue() async {
    if (budgetConfig.headerDataRange?.isEmpty ?? true) return null;
    final result = await SheetsApi(httpClient).spreadsheets.values.get(budgetConfig.spreadsheetId, budgetConfig.headerDataRange);
    return result.values.first.first;
  }

  @override
  Widget build(BuildContext context) =>
    listItems == null
      ? Center(child: CircularProgressIndicator())
      : _entriesListView(context);

  Widget _entriesListView(BuildContext context) =>
    CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: <Widget>[
        headerValue != null ? SliverAppBar(
          expandedHeight: 96,
          flexibleSpace: BudgetFlexibleSpaceBar(
            subtitle: Text("Forecast budget"),
            title: Text(headerValue),
          ))
          : SliverAppBar(
          title: Text((budgetConfig.spreadsheetTitle ?? "") + " - " + (budgetConfig.dataSheetTitle ?? "")),
        ),
        SliverPadding(
          padding: EdgeInsets.only(bottom: 36),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                final listItem = listItems[index];
                if (listItem is DateHeaderItem)
                  return _dateHeaderItem(listItem);
                else if (listItem is EntryItem)
                  return _entryItem(listItem);
              },
              childCount: listItems.length),
          )
        )
      ]
    );

  Widget _dateHeaderItem(DateHeaderItem item) =>
    Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        DateFormat("EEEE, d MMMM yyyy").format(item.date)
      )
    );

  Widget _entryItem(EntryItem item) {
    final categoryMarkRune = item.entry.category?.runes?.first;
    final categoryText = categoryMarkRune != null ? String.fromCharCode(categoryMarkRune) : "?";
    return Card(
      child: ListTile(
        leading: Container(
          alignment: AlignmentDirectional.centerEnd,
          width: 32,
          child: Text(
            categoryText,
            style: TextStyle(fontSize: 21)
          ),
        ),
        title: Text(item.entry.title ?? ""),
        subtitle: Text(item.entry.amount ?? ""),
      )
    );
  }
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

