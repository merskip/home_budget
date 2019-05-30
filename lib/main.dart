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
//    final account = await _fetchGoogleAccount(context);
//    final applicationConfig = await _fetchApplicationConfig(context);

    final applicationConfig = await _readApplicationConfigFromPreferencesOrNull();

    setState(() {
      this.applicationConfig = applicationConfig;
      this.loading = false;
    });
  }

  Future<GoogleSignInAccount> _fetchGoogleAccount(BuildContext context) async {
    final account = await googleSignIn.signInSilently() ?? await _showSignInScreen();
    httpHeaders = await googleSignIn.currentUser.authHeaders;
    httpClient = GoogleHttpClient(httpHeaders);
    return account;
  }

  Future<GoogleSignInAccount> _showSignInScreen() {
    setState(() => showSignIn = true);
    return googleSignIn.onCurrentUserChanged.firstWhere((account) => account != null);
  }

  Future<ApplicationConfig> _fetchApplicationConfig(BuildContext context) async {
    var applicationConfig = await _readApplicationConfigFromPreferencesOrNull();
    if (applicationConfig != null && applicationConfig.budgetSheetsConfigs.isEmpty)
      applicationConfig = null;

    if (applicationConfig == null) {
      final budgetScreenConfig = await Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => BudgetSheetConfigScreen())
      ) as BudgetSheetConfig;

      applicationConfig = ApplicationConfig([budgetScreenConfig], 0);
    }
    return applicationConfig;
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
          return FirstConfigurationScreen();
        else
          return _budgetShowScreen(applicationConfig);

      })
    );
  }

  Widget _loadingScreen() =>
    Scaffold(
      body: Center(child: CircularProgressIndicator())
    );

  Widget _signInScreen() =>
    SignInScreen();

  Widget _budgetShowScreen(ApplicationConfig applicationConfig) =>
    BudgetShowScreen(budgetSheetConfig: applicationConfig.defaultBudgetSheetConfig);
}
