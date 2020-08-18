import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'alert.dart';
import 'user.dart';

final auth = FirebaseAuth.instance;
final userRef = Firestore.instance.collection("users");

enum LoginType { login, register }

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email;
  void setEmail(value) => _email = value;
  String _password;
  void setPassword(value) => _password = value;
  LoginType _loginType = LoginType.login;
  String get primaryButtonText {
    return _loginType == LoginType.login ? "ログイン" : "ユーザ登録";
  }
  String get secondaryButtonText {
    return _loginType == LoginType.login ? "ユーザ登録" : "ログイン";
  }

  final _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(50),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  onChanged: setEmail,
                  focusNode: _emailFocusNode,
                  onEditingComplete: () =>
                      FocusScope.of(context).requestFocus(_passwordFocusNode),
                  validator: (value) {
                    if (value == null || value.length == 0)
                      return "メールアドレスを入力してください";
                    else
                      return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    icon: Icon(Icons.email),
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  onChanged: setPassword,
                  focusNode: _passwordFocusNode,
                  onEditingComplete: () => _submit(context),
                  validator: (value) {
                    if (value == null || value.length == 0)
                      return "パスワードを入力してください";
                    else
                      return null;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    icon: Icon(Icons.lock),
                    labelText: "Password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                RaisedButton(
                  child: Text(
                    primaryButtonText,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  onPressed: () {
                    if (_loginType == LoginType.login) {
                      _submit(context);
                    } else {
                      _register(context);
                    }
                  },
                  padding: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                ),
                FlatButton(
                  child: Text(
                    secondaryButtonText,
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  onPressed: () => _changeLoginType(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    try {
      final form = _formKey.currentState;
      if (form.validate()) {
        auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        ).then((result) {
          if(result != null) {
            userRef.document(result.user.uid).get().then((snapshot) {
              // データベースにユーザ情報がなければ初期化
              if(snapshot.data == null) {
                User user = User(uid:result.user.uid,email:result.user.email);
                User newUser = User.initUser(user); // initUserStringに定義されたユーザなら情報コピー
                userRef.document(newUser.uid).setData(newUser.toMap());
              }
            });
          }
        });
      }
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: "ログインが失敗しました",
        exception: e,
      ).show(context);
    }
  }

  Future<void> _register(BuildContext context) async {
    try {
      final form = _formKey.currentState;
      if (form.validate()) {
        AuthResult result = await auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        User user = User(uid: result.user.uid, email: result.user.email);
        userRef.document(result.user.uid).setData(user.toMap());
      }
    } on PlatformException catch (e) {
      PlatformExceptionAlertDialog(
        title: "ユーザ登録が失敗しました",
        exception: e,
      ).show(context);
    }
  }

  void _changeLoginType() {
    setState(() {
      if (_loginType == LoginType.login) {
        _loginType = LoginType.register;
      } else {
        _loginType = LoginType.login;
      }
    });
  }
}