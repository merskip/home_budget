import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';

import 'google_http_client.dart';
import 'main.dart';


class BudgetPreviewPage extends StatefulWidget {

  final File budgetFile;

  BudgetPreviewPage({Key key, this.budgetFile}) : super(key: key);

  @override
  _BudgetPreviewPageState createState() => _BudgetPreviewPageState();
}

class _BudgetPreviewPageState extends State<BudgetPreviewPage> {

  Map<String, String> authHeaders;

  @override
  void initState() {
    super.initState();


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Budget preview"),
      ),
      body: Text(widget.budgetFile.name)
    );
  }
}
