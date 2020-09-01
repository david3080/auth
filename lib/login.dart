import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'user.dart';

enum LoginType { login, register }

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  LoginType _loginType = LoginType.login;
  String get primaryButtonText {
    return _loginType == LoginType.login ? "ログイン" : "ユーザ登録";
  }
  String get secondaryButtonText {
    return _loginType == LoginType.login ? "ユーザ登録" : "ログイン";
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: screenHeight,
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _email,
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
                controller: _password,
                focusNode: _passwordFocusNode,
                onEditingComplete: () => _login(context),
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
                onPressed: () async {
                  if (_loginType == LoginType.login) {
                    _login(context);
                  } else {
                    _register(context);
                  }
                },
                padding: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
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
    );
  }

  void _login(BuildContext context) async {
    final form = _formKey.currentState;
    if (form.validate()) {
      await User.login(_email.value.text,_password.value.text,context);
    }
  }

  void _register(BuildContext context) async {
    final form = _formKey.currentState;
    if (form.validate()) {
      await User.register(_email.value.text,_password.value.text,context);
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