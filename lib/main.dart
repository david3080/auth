import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home.dart';
import 'login.dart';
import 'resto.dart';

Future<void> main() async {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ログイン',
      theme: ThemeData(
        primaryColor: Colors.indigo,
        canvasColor: Colors.white,
        buttonColor: Colors.indigo,
      ),
      home: Landing(),
    )
  );
}

class Landing extends StatefulWidget {
  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  @override
  void initState() {
    Resto.initRestos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<auth.User>(
        stream: auth.FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            auth.User user = snapshot.data;
            if (user == null) {
              return LoginPage();
            }
            return HomePage(uid:user.uid,email:user.email);
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}