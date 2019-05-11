import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart';

import 'add_product_form.dart';
import 'google_http_client.dart';
import 'sign_in_page.dart';
import 'sheets_list.dart';
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

  @override
  void initState() {
    super.initState();

    googleSignIn.signInSilently().then((account) {
      setState(() {
        this.account = account;
        this.loading = false;
      });
    });
  }

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
        builder: (context) {
          if (loading)
            return _loadingScreen(context);
          else if (account == null)
            return _singInScreen(context);
          else
            return SheetsListPage();
        }
      ),
      routes: <String, WidgetBuilder>{
        '/sheets_list': (BuildContext context) => new SheetsListPage(),
        '/budget_preview': (BuildContext context) {
          final arguments = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
          return new BudgetPreviewPage(budgetFile: arguments["file"] as File);
        },
        '/add_product': (BuildContext context) {
          final arguments = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
          return new AddProductForm(arguments["budget_properties"]);
        },
      },
    );
  }

  Widget _loadingScreen(BuildContext context) =>
    Scaffold(
      body: Center(
        child: new CircularProgressIndicator()
      )
    );

  Widget _singInScreen(BuildContext context) =>
    SignInPage(
      onSignIn: () async {
        httpHeaders = await googleSignIn.currentUser.authHeaders;
        httpClient = GoogleHttpClient(httpHeaders);

        return Navigator.pushReplacementNamed(context, '/sheets_list');
      }
    );
}
