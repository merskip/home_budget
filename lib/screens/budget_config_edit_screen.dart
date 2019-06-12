import 'package:flutter/material.dart';

import '../widgets/column_description_list_tile.dart';
import '../data/budget_sheet_config.dart';
import '../data/application_config.dart';
import 'column_configuration_screen.dart';

class BudgetConfigEditScreen extends StatefulWidget {

  final ApplicationConfig applicationConfig;
  final BudgetSheetConfig budgetSheetConfig;

  const BudgetConfigEditScreen({Key key, this.applicationConfig, this.budgetSheetConfig}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BudgetConfigEditState(budgetSheetConfig);
}

class _BudgetConfigEditState extends State<BudgetConfigEditScreen> {

  final BudgetSheetConfig budgetSheetConfig;

  _BudgetConfigEditState(this.budgetSheetConfig);

  _onSelectedColumn(ColumnDescription column) async {
    final editBudgetConfigRoute = MaterialPageRoute(builder:
      (context) => ColumnConfigurationScreen(column)
    );
    final updatedColumn = await Navigator.of(context).push(editBudgetConfigRoute);
    if (updatedColumn != null) {
      _updateColumn(updatedColumn);
    }
  }

  _updateColumn(ColumnDescription column) async {
    final index = widget.budgetSheetConfig.columns.indexWhere((c) => c.range == column.range);
    if (index != -1) {

      setState(() {
        budgetSheetConfig.columns[index] = column;
        widget.applicationConfig.saveToPreferences();
      });
    }
  }

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: AppBar(title: Text("${widget.budgetSheetConfig.spreadsheetTitle} - ${widget.budgetSheetConfig.dataSheetTitle}")),
      body: ListView.builder(
        itemCount: widget.budgetSheetConfig.columns.length,
        itemBuilder: (context, index) {
          final column = widget.budgetSheetConfig.columns[index];
          return InkWell(
            child: Card(
              child: ColumnDescriptionListTile(
                columnDescription: column,
                trailing: Icon(Icons.edit),
              )
            ),
            onTap: () => _onSelectedColumn(column),
          );
        }
      )
    );
}
