import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'main.dart';

class SignInPage extends StatefulWidget {

  final VoidCallback onSignIn;

  SignInPage({Key key, this.onSignIn}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignInPage> {

  @override
  void initState() {
    super.initState();
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      if (account != null) {
        widget.onSignIn();
      }
    });
    googleSignIn.signInSilently();
  }

  _handleSignIn() {
    try {
      googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text("Home Budget"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(onPressed: _handleSignIn, child: Text("Sign in"))
          ],
        ),
      ));
}
