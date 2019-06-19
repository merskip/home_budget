import 'package:flutter/material.dart';
import 'package:home_budget/data/application_config.dart';
import 'package:home_budget/data/budget_sheet_config.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'ReceiptPreviewScreen.dart';
import 'budget_add_entry_screen.dart';
import 'budget_entries_list_screen.dart';
import 'budgets_list_screen.dart';
import '../main.dart';

class BudgetShowScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _MainState();
}

class _MainState extends State<BudgetShowScreen> {
  int _selectedTabIndex = 0;

  final _budgetEntriesKey = GlobalKey<BudgetEntriesListState>();

  _updateSelectedTab(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  _onSelectedAddEntry(BuildContext context) async {
    final preferences = await ApplicationConfig.readFromPreferences();
    final addEntryRoute = MaterialPageRoute(builder: (context) => BudgetAddEntryScreen(preferences.defaultBudgetSheetConfig));
    final appendedEntry = await Navigator.push(context, addEntryRoute) ?? false;
    if (appendedEntry) {
      _budgetEntriesKey.currentState.refreshBudget();
    }
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
              icon: Icons.home,
              title: "Home",
              isSelected: _selectedTabIndex == 0,
              onPressed: () => _updateSelectedTab(0),
            ),
            _BottomAppBarButton(
              icon: Icons.storage,
              title: "Budgets",
              isSelected: _selectedTabIndex == 1,
              onPressed: () => _updateSelectedTab(1),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final image = await ImagePicker.pickImage(source: ImageSource.gallery);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ReceiptPreviewScreen(imageFile: image))
          );
        },
      ),
    );

  Widget _selectedTabBody() {
    if (_selectedTabIndex == 0)
      return FutureBuilder(
        future: ApplicationConfig.readFromPreferences(),
        builder: (context, AsyncSnapshot<ApplicationConfig> snapshot) {
          final applicationConfig = snapshot.data;
          if (applicationConfig == null) return Container();
          return BudgetEntriesListScreen(key: _budgetEntriesKey, budgetSheetConfig: applicationConfig.defaultBudgetSheetConfig);
        }
      );
    else if (_selectedTabIndex == 1)
      return BudgetListScreen();
    else
      return null;
  }
}

class _BottomAppBarButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onPressed;

  _BottomAppBarButton({Key key, this.icon, this.title, this.isSelected, this.onPressed})
    : super(key: key);

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
          ),
        ),
      ),
    );
  }
}
