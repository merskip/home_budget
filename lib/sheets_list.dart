import 'package:flutter/material.dart';

class SheetsListPage extends StatefulWidget {

  SheetsListPage({Key key}) : super(key: key);

  @override
  _SheetsListState createState() => _SheetsListState();
}

class _SheetsListState extends State<SheetsListPage> {

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text("Choose sheet"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Hello ;p")
          ],
        ),
      ));
}
