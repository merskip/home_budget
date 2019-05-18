import 'package:flutter/material.dart';
import 'package:googleapis/sheets/v4.dart' show SheetsApi, Sheet;
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

  Sheet sheet;
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
    final sheet = spreadsheet.sheets.first;
    final gridData = sheet.data.first; // Just get first interesting grid data, no should be more data

    final entriesReader = EntriesReader(budgetConfiguration);
    final entries = entriesReader.readFromGridData(gridData).reversed.toList();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: sheet == null ? Text("Loading budget...") : Text(sheet.properties.title)
      ),
      body: listItems == null
        ? Center(child: CircularProgressIndicator())
        : _entriesListView(context),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _BottomAppBarButton(
              icon: Icons.home, title: "Home",
              isSelected: true,
              onPressed: () {},
            ),
            _BottomAppBarButton(
              icon: Icons.folder, title: "Budgets",
              isSelected: false,
              onPressed: () {},
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {},
      )
    );
  }

  Widget _entriesListView(BuildContext context) =>
    Scrollbar(
      child: ListView.builder(
        itemCount: listItems.length,
        padding: EdgeInsets.all(8),
        physics: BouncingScrollPhysics(),
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

class _BottomAppBarButton extends StatelessWidget {

  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onPressed;

  _BottomAppBarButton({Key key, this.icon, this.title, this.isSelected, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final color = isSelected ? theme.accentColor : theme.hintColor;

    return InkWell(
      onTap: onPressed,
      customBorder: CircleBorder(),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 48),
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, color: color),
              Text(title, style: TextStyle(color: color, fontSize: 12))
            ],
          )
        )
      )
    );
  }
}
