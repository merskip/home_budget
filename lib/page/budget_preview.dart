import 'package:flutter/material.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:home_budget/model/budget_configuration.dart';


import 'package:home_budget/page/main.dart';
import 'package:home_budget/model/constants.dart';

import '../BudgetProperties.dart';
import '../Product.dart';

class BudgetPreviewPage extends StatefulWidget {

  final BudgetConfiguration budgetConfiguration;

  BudgetPreviewPage({Key key, this.budgetConfiguration}) : super(key: key);

  @override
  _BudgetPreviewState createState() => _BudgetPreviewState(budgetConfiguration);
}

class _BudgetPreviewState extends State<BudgetPreviewPage> {

  BudgetConfiguration budgetConfiguration;

  _BudgetPreviewState(this.budgetConfiguration);

  @override
  void initState() {
    super.initState();

    _fetchBudget();
  }

  _fetchBudget() async {

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Loading budget...")
      )
    );
  }
}
