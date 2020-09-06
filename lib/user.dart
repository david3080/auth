import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

import 'alert.dart';
import 'myexception.dart';

final userColRef = FirebaseFirestore.instance.collection("users");

// ユーザクラス
class User {
  User({@required this.uid,@required this.email,this.name,this.url});
  final String uid;
  final String email;
  final String name;
  final String url;

  @override
  String toString() {
    return "uid:$uid,email:$email,name:$name,url:$url";
  }

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

  Future<void> setUser({bool merge = false}) {
    return userColRef.doc(uid).set(this.toMap(),SetOptions(merge:merge));
  }

  // ログインユーザからユーザを作成
  static Future<User> getUserFromAuth(auth.User _authUser) async {
    DocumentSnapshot snapshot = await userColRef.doc(_authUser.uid).get();
    return User.fromMap(snapshot.id,snapshot.data());
  }

  static Future<void> register(String email, String password, BuildContext context) async {
    await auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ).then((cred) {
      // データベースにユーザ情報を登録
      User user = User(uid: cred.user.uid, email: cred.user.email);
      userColRef.doc(cred.user.uid).set(user.toMap());
    }).catchError((e){
      MyExceptionAlertDialog(
        title: "ユーザ登録に失敗しました",
        exception: MyException(exception: e),
      ).show(context);
    });
  }

  static Future<void> login(String email, String password, BuildContext context) async {
    await auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
    ).then((result) {
      if(result != null) {
        userColRef.doc(result.user.uid).get().then((snapshot) {
          if(snapshot.data == null) { // データベースにユーザ情報がなければ初期化
            User user = User(uid:result.user.uid,email:result.user.email);
            User newUser = initUser(user); // initUserStringに定義されたユーザなら情報コピー
            userColRef.doc(newUser.uid).set(newUser.toMap());
          }
        });
      }
    }).catchError((e) {
      MyExceptionAlertDialog(
        title: "ログインに失敗しました",
        exception: MyException(exception: e),
      ).show(context);
    });
  }

  static Future<void> logout(BuildContext context) async {
    bool logout = await MyAlertDialog(
      title:"ログアウト",
      content:"ログアウトしますか？",
      defaultActionText:"はい",
      cancelActionText:"いいえ",).show(context);
    if(logout) {
      return auth.FirebaseAuth.instance.signOut();
    }
  }

  static Stream<User> getUserStream(String uid) {
    return userColRef.doc(uid).snapshots().map((snapshot)=>User.fromMap(uid,snapshot.data()));
  }

  static List users = jsonDecode(initUserString);
  static User initUser(User user) {
    User newUser = user;
    users.forEach((_user) {
      if(user.email.compareTo(_user["email"])==0) {
        newUser = user.copy(name:_user["name"],url:_user["url"]);
      }
    });
    return newUser;
  }

  static String initUserString = '''
[
    {
      "_id": 0,
      "name": "鈴木一郎",
      "email": "ichiro@test.com",
      "url": "https://meikyukai.jp/wp-content/uploads/2020/06/51_ichiro.jpg"
    },
    {
      "_id": 1,
      "name": "佐藤二郎",
      "email": "jiro@test.com",
      "url": "http://www.from1-pro.jp/images/t_10/img_l.jpg"
    },
    {
      "_id": 2,
      "name": "北島三郎",
      "email": "saburo@test.com",
      "url": "https://cdn.asagei.com/asagei/uploads/2016/08/20160810kitajima.jpg"
    }
  ]
''';
}
