import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class MyException implements Exception {
  @override
  MyException({@required this.exception,});
  final Exception exception;

  String get message {
    if(exception!= null) {
      if(exception is FirebaseAuthException) {
        FirebaseAuthException e = exception;
        return errors[e.code] ?? e.message;
      } else {
        return exception.toString();
      }
    } else {
      return "Some Error!";
    }
  }

  // Error code of Firebase Auth
  // Ref: https://firebase.google.com/docs/reference/js/firebase.auth.Auth?hl=en
  static Map<String, String> errors = {
    "invalid-email": "正しいメールアドレスを入力してください", // ログイン時と登録時
    "user-not-found": "ユーザが見つかりません", // ログイン時
    "wrong-password": "パスワードが間違っています", // ログイン時
    "weak-password": "パスワードは6文字以上を設定してください", // 登録時
    "email-already-in-use": "既に登録されているメールアドレスです", // 登録時
  };
}