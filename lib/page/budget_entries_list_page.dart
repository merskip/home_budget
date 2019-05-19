import 'package:flutter/material.dart';
import 'package:googleapis/sheets/v4.dart' show SheetsApi, Sheet;
import "package:collection/collection.dart";
import 'package:home_budget/model/budget_configuration.dart';
import 'package:home_budget/model/entries_reader.dart';
import 'package:home_budget/model/entry.dart';

import 'package:home_budget/page/main.dart';
import 'package:home_budget/widget/budget_flexible_space_bar.dart';
import 'package:intl/intl.dart';

class BudgetEntriesListPage extends StatefulWidget {

  final BudgetConfiguration budgetConfiguration;

  BudgetEntriesListPage({Key key, this.budgetConfiguration}) : super(key: key);

  @override
  BudgetEntriesListState createState() => BudgetEntriesListState(budgetConfiguration);
}

class BudgetEntriesListState extends State<BudgetEntriesListPage> {

  BudgetConfiguration budgetConfiguration;

  Sheet sheet;
  List<Entry> entries;
  List<ListItem> listItems;

  BudgetEntriesListState(this.budgetConfiguration);

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
    final dataRangeFirstPage = budgetConfiguration.dataRange + "100";
    final spreadsheet = await SheetsApi(httpClient).spreadsheets.get(budgetConfiguration.spreadsheetId, ranges: [dataRangeFirstPage], includeGridData: true);
    final sheet = spreadsheet.sheets.first;
    final gridData = sheet.data.first; // Just get first interesting grid data, no should be more data

    final entriesReader = EntriesReader(budgetConfiguration);
    final entries = entriesReader
      .readFromGridData(gridData)
      .reversed
      .toList();
    final entriesGroupedByDate = groupBy(entries, (Entry entry) => entry.date);

    final listItems = <ListItem>[];
    entriesGroupedByDate.forEach((dateTime, entries) {
      listItems.add(DateHeaderItem(dateTime));
      listItems.addAll(entries.map((entry) => EntryItem(entry)));
    });

    setState(() {
      this.sheet = sheet;
      this.entries = entries;
      this.listItems = listItems;
    });
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
        SliverAppBar(
          expandedHeight: 128,
          flexibleSpace: BudgetFlexibleSpaceBar(
            subtitle: Text("Forecast budget"),
            title: Text("-256,23 zł"),
          )
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
        title: Text(item.entry.title),
        subtitle: Text(item.entry.amount),
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

