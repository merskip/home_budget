import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/application_config.dart';
import 'data/budget_sheet_config.dart';
import 'screens/budget_sheet_config_screen.dart';
import 'screens/budget_show_screen.dart';
import 'screens/first_configuration_screen.dart';
import 'screens/sign_in_screen.dart';
import 'util/google_http_client.dart';

const prefsApplicationConfig = "appliaction_config";

GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
  'email',
  DriveApi.DriveReadonlyScope,
  SheetsApi.SpreadsheetsScope
]);
Map<String, String> httpHeaders;
GoogleHttpClient httpClient;

void main() => runApp(AppWidget());

class AppWidget extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<AppWidget> {

  var showSignIn = true;

  GoogleSignInAccount account;

  var loading = false;
  ApplicationConfig applicationConfig;

  @override
  void initState() {
    super.initState();
    _startupApplication();
  }

  _startupApplication() async {
    final applicationConfig = await _readApplicationConfigFromPreferencesOrNull();

    setState(() {
      this.applicationConfig = applicationConfig;
      this.loading = false;
    });
  }

  Future<ApplicationConfig> _readApplicationConfigFromPreferencesOrNull() async {
    final preferences = await SharedPreferences.getInstance();
    try {
      final json = preferences.getString(prefsApplicationConfig);
      if (json != null)
        return ApplicationConfig.fromJson(jsonDecode(json));
    }
    catch (e) {
      print(e);
      preferences.remove(prefsApplicationConfig);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Budget',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.indigo,
          textTheme: ButtonTextTheme.primary
        )
      ),
      home: Builder(builder: (context) {
        if (loading)
          _loadingScreen();
        else if (applicationConfig == null)
          return FirstConfigurationScreen(() {
            _startupApplication();
          });
        else
          return _budgetShowScreen(applicationConfig);

      })
    );
  }

  Widget _loadingScreen() =>
    Scaffold(
      body: Center(child: CircularProgressIndicator())
    );

  Widget _budgetShowScreen(ApplicationConfig applicationConfig) =>
    BudgetShowScreen(budgetSheetConfig: applicationConfig.defaultBudgetSheetConfig);
}
