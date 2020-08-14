import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<AuthBase>(
      create: (_) => Auth(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ログイン',
        theme: ThemeData(
          primaryColor: Colors.indigo,
          canvasColor: Colors.white,
          buttonColor: Colors.indigo,
        ),
        home: LandingPage(),
      ),
    );
  }
}

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context);
    return StreamBuilder<User>(
        stream: auth.onAuthStateChanged,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User user = snapshot.data;
            if (user == null) {
              return LoginPage();
            }
            return HomePage(uid: user.uid);
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

enum LoginType { login, register }

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final auth = FirebaseAuth.instance;
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
        padding: EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height,
            ),
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
                      else return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      icon: Icon(Icons.email),
                      labelText: "Email",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0)),
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
                      else return null;
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
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    try {
      final form = _formKey.currentState;
      if (form.validate()) {
        await auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
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
        final firestore = Firestore.instance;
        firestore.collection("users").document(result.user.uid).setData(user.toMap());
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

class HomePage extends StatefulWidget {
  final String uid;
  HomePage({Key key, this.uid}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController _pageController;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          Container(),
          AccountPage(
            uid: widget.uid,
          ),
        ],
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        currentIndex: _index,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            title: Text("レストラン"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text("アカウント"),
          ),
        ],
        onTap: (index) {
          setState(() {
            _index = index;
          });
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 1000),
            curve: Curves.elasticOut,
          );
        },
      ),
    );
  }
}

class AccountPage extends StatefulWidget {
  const AccountPage({Key key, this.uid}) : super(key: key);
  final String uid;

  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  TextEditingController _nameController;

  @override
  void initState() {
    _nameController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "アカウント",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => auth.signOut(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(300),
          child: StreamBuilder<User>(
            stream: Firestore.instance
                .collection("users")
                .document(widget.uid)
                .snapshots()
                .map((snapshot) => User.fromMap(widget.uid, snapshot.data)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active &&
                  snapshot.hasData) {
                final user = snapshot.data;
                _nameController.text = user.name;
                return Column(
                  children: <Widget>[
                    Avatar(
                      url: user?.url,
                      radius: 70,
                      borderColor: Colors.black54,
                      borderWidth: 2.0,
                      onPressed: () => _chooseAvatar(context, user),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: TextField(
                          style: TextStyle(color: Colors.white),
                          controller: _nameController,
                          onEditingComplete: () async {
                            User _newUser = user.copy(
                              name: _nameController.text,
                            );
                            await Firestore.instance
                                .collection("users")
                                .document(widget.uid)
                                .setData(_newUser.toMap());
                          },
                          decoration: InputDecoration(
                            labelText: "ニックネーム",
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _chooseAvatar(BuildContext context, User user) async {
    // TODO Firebase StorageパッケージはWeb対応していないので未実装
    // https://gist.github.com/happyharis/d7a4a89bbac114af00f921f6c26ab728
  }
}

class Avatar extends StatelessWidget {
  const Avatar({
    @required this.url,
    @required this.radius,
    this.borderColor,
    this.borderWidth,
    this.onPressed,
  });
  final String url;
  final double radius;
  final Color borderColor;
  final double borderWidth;
  final ui.VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _borderDecoration(),
      child: InkWell(
        onTap: onPressed,
        child: CircleAvatar(
          radius: radius,
          backgroundColor: Colors.black12,
          backgroundImage: url != null ? NetworkImage(url) : null,
          child: url == null ? Icon(Icons.camera_alt, size: radius) : null,
        ),
      ),
    );
  }

  Decoration _borderDecoration() {
    if (borderColor != null && borderWidth != null) {
      return BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      );
    }
    return null;
  }
}

class User {
  User({@required this.uid, this.email, this.name, this.url});
  final String uid;
  final String email;
  final String name;
  final String url;

  factory User.fromMap(String documentId, Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final String name = data['name'];
    final String email = data['email'];
    final String url = data['url'];
    return User(
      uid: documentId,
      name: name,
      email: email,
      url: url,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'url': url,
    };
  }

  User copy({String name, String email, String url}) {
    return User(
      uid: uid,
      name: name != null ? name : this.name,
      email: email != null ? email : this.email,
      url: url != null ? url : this.url,
    );
  }
}

abstract class AuthBase {
  Stream<User> get onAuthStateChanged;
  Future<User> currentUser();
  Future<User> signInAnonymously();
  Future<void> signOut();
}

class Auth implements AuthBase {
  final _firebaseAuth = FirebaseAuth.instance;

  User _userFromFirebase(FirebaseUser user) {
    if (user == null) {
      return null;
    }
    return User(uid: user.uid);
  }

  @override
  Stream<User> get onAuthStateChanged {
    return _firebaseAuth.onAuthStateChanged.map(_userFromFirebase);
  }

  @override
  Future<User> currentUser() async {
    final user = await _firebaseAuth.currentUser();
    return _userFromFirebase(user);
  }

  @override
  Future<User> signInAnonymously() async {
    final authResult = await _firebaseAuth.signInAnonymously();
    return _userFromFirebase(authResult.user);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

abstract class Database {}

class FirestoreDatabase implements Database {
  FirestoreDatabase({@required this.uid}) : assert(uid != null);
  final String uid;
}

class Keys {
  static const String alertDefault = 'alertDefault';
  static const String alertCancel = 'alertCancel';
}

abstract class PlatformWidget extends StatelessWidget {
  Widget buildMaterialWidget(BuildContext context);
  @override
  Widget build(BuildContext context) {
    return buildMaterialWidget(context);
  }
}

class PlatformAlertDialog extends PlatformWidget {
  PlatformAlertDialog({
    @required this.title,
    @required this.content,
    this.cancelActionText,
    @required this.defaultActionText,
  })  : assert(title != null),
        assert(content != null),
        assert(defaultActionText != null);

  final String title;
  final String content;
  final String cancelActionText;
  final String defaultActionText;

  Future<bool> show(BuildContext context) async {
    return await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => this,
          );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final List<Widget> actions = <Widget>[];
    if (cancelActionText != null) {
      actions.add(
        PlatformAlertDialogAction(
          child: Text(
            cancelActionText,
            key: Key(Keys.alertCancel),
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      );
    }
    actions.add(
      PlatformAlertDialogAction(
        child: Text(
          defaultActionText,
          key: Key(Keys.alertDefault),
        ),
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );
    return actions;
  }
}

class PlatformAlertDialogAction extends PlatformWidget {
  PlatformAlertDialogAction({this.child, this.onPressed});
  final Widget child;
  final ui.VoidCallback onPressed;

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return FlatButton(
      child: child,
      onPressed: onPressed,
    );
  }
}

class PlatformExceptionAlertDialog extends PlatformAlertDialog {
  PlatformExceptionAlertDialog({@required String title, @required PlatformException exception})
      : super(
    title: title,
    content: message(exception),
    defaultActionText: 'OK',
  );

  static String message(PlatformException exception) {
    if (exception.message == 'FIRFirestoreErrorDomain') {
      if (exception.code == 'Code 7') {
        return 'This operation could not be completed due to a server error';
      }
      return exception.details;
    }
    return errors[exception.code] ?? exception.message;
  }

  static Map<String, String> errors = {
    'ERROR_WEAK_PASSWORD': 'パスワードは8文字以上である必要があります。再入力してください。',
    'ERROR_INVALID_CREDENTIAL': 'ログインする権限がありません。',
    'ERROR_EMAIL_ALREADY_IN_USE': 'このメールアドレスはすでに登録されています。',
    'ERROR_INVALID_EMAIL': 'メールアドレスのフォーマットに誤りがあります。再入力してください。',
    'ERROR_WRONG_PASSWORD': 'パスワードが異なります。',
    'ERROR_USER_NOT_FOUND': 'メールアドレスが登録されていません。',
    'ERROR_TOO_MANY_REQUESTS': 'このデバイスからのアクセスはブロックされています。時間をおいてから試してください。',
    'ERROR_OPERATION_NOT_ALLOWED': 'ログインする権限がありません。',
  };
}