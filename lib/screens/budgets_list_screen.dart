import 'package:flutter/material.dart';

import '../data/application_config.dart';

class BudgetListScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _BudgetListState();
}

class _BudgetListState extends State<BudgetListScreen> {

  ApplicationConfig applicationConfig;

  @override
  void initState() {
    super.initState();

    ApplicationConfig.readFromPreferences().then((applicationConfig) {
      setState(() {
        this.applicationConfig = applicationConfig;
      });
    });
  }



  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: AppBar(title: Text("Budgets")),
      body: applicationConfig != null ? _budgetsList() : Container()
    );

  _budgetsList() =>
    ListView.builder(
      itemCount: applicationConfig.budgetSheetsConfigs.length,
      itemBuilder: (context, index) {
        final budgetSheetConfig = applicationConfig.budgetSheetsConfigs[index];
        final isDefault = applicationConfig.defaultConfigIndex == index;

        return Card(
          child: ListTile(
            leading: Icon(isDefault ? Icons.home : null),
            title: Text("${budgetSheetConfig.spreadsheetTitle} - ${budgetSheetConfig.dataSheetTitle}"),
          ),
        );
      }
    );
}
