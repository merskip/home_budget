import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:home_budget/model/budget_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_product_form.dart';
import 'sign_in_page.dart';
import 'choose_sheet_page.dart';
import 'budget_preview.dart';
import '../model/google_http_client.dart';
import '../model/constants.dart';
import 'spreadsheet_configuration_page.dart';

GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
  'email',
  DriveApi.DriveReadonlyScope,
  SheetsApi.SpreadsheetsScope
]);
Map<String, String> httpHeaders;
GoogleHttpClient httpClient;

void main() => runApp(HomeBudgetAppWidget());

class HomeBudgetAppWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeBudgetAppState();
}

class HomeBudgetAppState extends State<HomeBudgetAppWidget> {

  var loading = true;
  GoogleSignInAccount account;
  BudgetConfiguration budgetConfiguration;

  @override
  void initState() {
    super.initState();

    googleSignIn.onCurrentUserChanged.listen((account) {
      return this.account = account;
    });

    googleSignIn.signInSilently().then((account) async {
      final preferences = await SharedPreferences.getInstance();
      if (account != null)
        await _configureAuthentication();

      setState(() {
        this.account = account;
        this.budgetConfiguration = BudgetConfiguration.fromJson(jsonDecode(preferences.getString(prefsBudgetConfiguration)));
        this.loading = false;
      });
    });
  }

  _configureAuthentication() async {
    httpHeaders = await googleSignIn.currentUser.authHeaders;
    httpClient = GoogleHttpClient(httpHeaders);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Budget',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        buttonTheme: ButtonThemeData(buttonColor: Colors.deepOrange, textTheme: ButtonTextTheme.primary)
      ),
      home: Builder(builder: (context) {
        if (loading)
          return _loadingScreen(context);
        else if (account == null)
          return _singInPage(context);
        else if (budgetConfiguration == null)
          return _chooseSpreadsheetPage(context);
        else
          return _budgetPreview(budgetConfiguration, context);
      }),
      routes: <String, WidgetBuilder>{
        '/chooseSpreadsheet': (BuildContext context) => _chooseSpreadsheetPage(context),
        '/spreadsheetConfiguration': (BuildContext context) {
          final arguments = _getMapArguments(context);
          final spreadsheetFile = arguments["spreadsheetFile"] as File;
          return _spreadsheetConfigurationPage(spreadsheetFile, context);
        },
        '/budgetPreview': (BuildContext context) {
          final arguments = _getMapArguments(context);
          final budgetConfiguration = arguments["budgetConfiguration"] as BudgetConfiguration;
          return _budgetPreview(budgetConfiguration, context);
        },
        '/add_product': (BuildContext context) {
          final arguments = _getMapArguments(context);
          return new AddProductForm(arguments["budget_properties"]);
        },
      },
    );
  }

  Map<String, dynamic> _getMapArguments(BuildContext context) =>
    ModalRoute
      .of(context)
      .settings
      .arguments as Map<String, dynamic>;

  Widget _loadingScreen(BuildContext context) =>
    Scaffold(body: Center(child: CircularProgressIndicator()));

  Widget _singInPage(BuildContext context) =>
    SignInPage(onSignIn: () async {
      await _configureAuthentication();
      Navigator.pushReplacementNamed(context, '/chooseSpreadsheet');
    });

  Widget _chooseSpreadsheetPage(BuildContext context) =>
    ChooseSpreadsheetPage((spreadsheet) async {
      final budgetConfiguration = await Navigator.pushNamed(
        context, '/spreadsheetConfiguration',
        arguments: {"spreadsheetFile": spreadsheet}
      );

      final preferences = await SharedPreferences.getInstance();
      preferences.setString(prefsBudgetConfiguration, jsonEncode(budgetConfiguration));

      Navigator.of(context).pushNamedAndRemoveUntil("budgetPreview", (route) => false, arguments: budgetConfiguration);
    });

  Widget _spreadsheetConfigurationPage(File spreadsheetFile, BuildContext context) =>
    SpreadsheetConfigurationPage(spreadsheetFile);

  _budgetPreview(BudgetConfiguration budgetConfiguration, BuildContext context) =>
    BudgetPreviewPage(budgetConfiguration: budgetConfiguration);
}
