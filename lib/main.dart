import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart';

import 'sign_in_page.dart';
import 'sheets_list.dart';
import 'budget_preview.dart';

GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
  'email',
  DriveApi.DriveReadonlyScope,
  SheetsApi.SpreadsheetsScope
]);

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Budget',
      theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          buttonTheme: ButtonThemeData(
              buttonColor: Colors.deepOrange,
              textTheme: ButtonTextTheme.primary)
      ),
      home: Builder(
          builder: (context) => SignInPage(
              onSignIn: () =>
                  Navigator.pushReplacementNamed(context, '/sheets_list')
          )
      ),
      routes: <String, WidgetBuilder>{
        '/sheets_list': (BuildContext context) => new SheetsListPage(),
        '/budget_preview': (BuildContext context) {
          final arguments = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
          return new BudgetPreviewPage(budgetFile: arguments["file"] as File);
        },
      },
    );
  }
}
