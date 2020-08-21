import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home.dart';
import 'login.dart';
import 'resto.dart';

  final FirebaseOptions firebaseOptions = const FirebaseOptions(
    apiKey: "AIzaSyC690bkpcy8xkMrR0MIa37tOpJUqPFuA0k",
    authDomain: "firestore-5643d.firebaseapp.com",
    databaseURL: "https://firestore-5643d.firebaseio.com",
    projectId: "firestore-5643d",
    storageBucket: "firestore-5643d.appspot.com",
    messagingSenderId: "241654013175",
    appId: "1:241654013175:web:a8331ea10e1f96ae3e07f2",
    measurementId: "G-WHYCJHVGCV"
  );

  Future<void> initializeDefault() async {
    FirebaseApp app = await Firebase.initializeApp();
    assert(app != null);
  }

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
    Firebase.initializeApp();
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