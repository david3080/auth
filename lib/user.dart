import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final auth = FirebaseAuth.instance;
final userRef = FirebaseFirestore.instance.collection("users");

// ユーザ情報のモデルとBlocを一緒にしたクラス
class User {
  User({@required this.uid, @required this.email, this.name, this.url});
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

  static Future<void> register(String email, String password) async {
    UserCredential cred = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    User user = User(uid: cred.user.uid, email: cred.user.email);
    userRef.doc(cred.user.uid).set(user.toMap());
  }

  static Future<void> login(String email, String password) async {
    auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    ).then((result) {
      if(result != null) {
        userRef.doc(result.user.uid).get().then((snapshot) {
          // データベースにユーザ情報がなければ初期化
          if(snapshot.data == null) {
            User user = User(uid:result.user.uid,email:result.user.email);
            User newUser = User.initUser(user); // initUserStringに定義されたユーザなら情報コピー
            userRef.doc(newUser.uid).set(newUser.toMap());
          }
        });
      }
    });
  }

  static Future<void> logout() {
    return auth.signOut();
  }

  Future<void> setUser({bool merge = false}) {
    return userRef.doc(uid).set(this.toMap(),SetOptions(merge:merge));
  }

  static Stream<User> getUserStream(String uid) {
    return userRef.doc(uid).snapshots().map((snapshot)=>User.fromMap(uid,snapshot.data()));
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
      "url": "https://meikyu-kai.org/wp-content/uploads/2020/01/51_Ichiro.jpg"
    },
    {
      "_id": 1,
      "name": "佐藤二郎",
      "email": "jiro@test.com",
      "url": "http://www.from1-pro.jp/images/t_10/img_l.jpg?1597426029"
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
