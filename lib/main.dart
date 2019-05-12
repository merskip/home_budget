import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_product_form.dart';
import 'constants.dart';
import 'google_http_client.dart';
import 'sign_in_page.dart';
import 'choose_sheet_page.dart';
import 'budget_preview.dart';

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
  String sheetId;

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
        this.sheetId = preferences.getString(prefsSheetId);
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
        else if (sheetId == null)
          return _chooseSheetPage(context);
        else
          return _budgetPreview(sheetId, context);
      }),
      routes: <String, WidgetBuilder>{
        '/chooseSheet': (BuildContext context) => _chooseSheetPage(context),
        '/budgetPreview': (BuildContext context) {
          final arguments = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
          final file = arguments["file"] as File;
          return _budgetPreview(file.id, context);
        },
        '/add_product': (BuildContext context) {
          final arguments = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
          return new AddProductForm(arguments["budget_properties"]);
        },
      },
    );
  }

  Widget _loadingScreen(BuildContext context) =>
    Scaffold(body: Center(child: CircularProgressIndicator()));

  Widget _singInPage(BuildContext context) =>
    SignInPage(onSignIn: () async {
      await _configureAuthentication();
      Navigator.pushReplacementNamed(context, '/chooseSheet');
    });

  Widget _chooseSheetPage(BuildContext context) =>
    ChooseSheetPage((sheetFile) async {
      final preferences = await SharedPreferences.getInstance();
      preferences.setString(prefsSheetId, sheetFile.id);

      Navigator.pushReplacementNamed(context, '/budgetPreview', arguments: {"file": sheetFile});
    });

  Widget _budgetPreview(String sheetId, BuildContext context) =>
    BudgetPreviewPage(sheetId: sheetId);
}
