import 'package:flutter/material.dart';
import 'package:home_budget/model/budget_configuration.dart';

import 'add_entry_page.dart';
import 'budget_entries_list_page.dart';

class MainPage extends StatefulWidget {

  final BudgetConfiguration budgetConfiguration;

  MainPage({Key key, this.budgetConfiguration}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainState();
}

class _MainState extends State<MainPage> {

  int _selectedTabIndex = 0;

  _updateSelectedTab(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  _onSelectedAddEntry(BuildContext context) async {
    Navigator.push(context,
      MaterialPageRoute(builder: (context) => AddEntryPage(widget.budgetConfiguration))
    );
  }

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      body: _selectedTabBody(),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _BottomAppBarButton(
              icon: Icons.home, title: "Home",
              isSelected: _selectedTabIndex == 0,
              onPressed: () => _updateSelectedTab(0),
            ),
            _BottomAppBarButton(
              icon: Icons.multiline_chart, title: "Raport",
              isSelected: _selectedTabIndex == 1,
              onPressed: () => _updateSelectedTab(1),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _onSelectedAddEntry(context),
      )
    );

  Widget _selectedTabBody() {
    if (_selectedTabIndex == 0)
      return BudgetEntriesListPage(budgetConfiguration: widget.budgetConfiguration);
    else if (_selectedTabIndex == 1)
      return null; // TODO Add budgets list
    else
      return null;
  }
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
