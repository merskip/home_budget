import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'sign_in_page.dart';
import 'sheets_list.dart';

GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

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
      },
    );
  }
}
