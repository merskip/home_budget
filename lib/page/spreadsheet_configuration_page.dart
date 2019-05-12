import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:home_budget/model/budget_configuration.dart';

class SpreadsheetConfigurationPage extends StatefulWidget {

  final File spreadsheet;

  final Function(BudgetConfiguration) callback;

  const SpreadsheetConfigurationPage(this.spreadsheet, this.callback, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SpreadsheetConfigurationState();
}

class SpreadsheetConfigurationState extends State<SpreadsheetConfigurationPage> {

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      appBar: AppBar(title: Text("Configuration ${widget.spreadsheet.name}")),
      body: Text("")
    );
}