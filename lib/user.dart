import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

import 'alert.dart';
import 'myexception.dart';

// ユーザクラス
class User {
  User({@required this.uid,@required this.email,this.name,this.url});
  final String uid;
  final String email;
  final String name;
  final String url;

  // デバッグ用にユーザ情報を文字列表示する
  @override
  String toString() {
    return "uid:$uid,email:$email,name:$name,url:$url";
  }

  // マップからユーザオブジェクトを作成する
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

  // ユーザオブジェクトからマップに変換する
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'url': url,
    };
  }

  // final指定されたユーザオブジェクトに値を上書きコピーして新たなユーザオブジェクトを作成する
  User copy({String name, String email, String url}) {
    return User(
      uid: uid,
      name: name != null ? name : this.name,
      email: email != null ? email : this.email,
      url: url != null ? url : this.url,
    );
  }

  // ユーザのコレクション参照
  static var userColRef = FirebaseFirestore.instance.collection("users");

  // データベースにユーザを追加・更新する
  Future<void> setUser({bool merge = false}) {
    return userColRef.doc(uid).set(this.toMap(),SetOptions(merge:merge));
  }

  // ログインユーザIDをもとにデータベースからユーザを取得する
  static Future<User> getUserFromAuth(auth.User _authUser) async {
    DocumentSnapshot snapshot = await userColRef.doc(_authUser.uid).get();
    return User.fromMap(snapshot.id,snapshot.data());
  }

  // ログインユーザを登録する
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

  // ログインする
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

  // ログアウトする
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

  // データベースからユーザ ストリームを取得する
  static Stream<User> getUserStream(String uid) {
    return userColRef.doc(uid).snapshots().map((snapshot)=>User.fromMap(uid,snapshot.data()));
  }

  // JSON文字列から作成されるユーザマップの配列
  static List users = jsonDecode(initUserString);

  // データベースにユーザコレクションがなければ初期データをセットする
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
