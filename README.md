# auth

Flutter WebでFirebase AuthとFirestoreを利用してemailログインするサンプルプロジェクト
(FirestorageはFlutter Webにまだ対応してないため、アバターの画像は実装していません)

Flutter Webのサンプルサイトは[こちら](https://david3080.github.io/auth/build/web)。

## 使い方

1. Firebaseの初期設定
 - プロジェクト作成
 - コンソールでAuthenticationのメール/パスワード認証を有効化。
 - Webアプリを有効化。</>をクリックしてアプリ名をセットしてアプリを登録。
 - Firebase SDKの追加に表示される内容を3のindex.htmlの設定に利用。

2. Flutterでpubspec.yamlでパッケージ追加
  firebase: ^7.3.0
  firebase_auth: ^0.16.1
  cloud_firestore: ^0.13.7
  provider: ^4.3.2
  openid_client: ^0.3.0

3. index.htmlにJSとFlutterアプリconfigを設定
※ firebase関連のjsを読み込んでconfigセット・initializeAppしてmain.dart.jsを読み込む順番でないとエラーが発生

```
  <script src="https://www.gstatic.com/firebasejs/7.17.2/firebase-app.js"></script>
  <script src="https://www.gstatic.com/firebasejs/7.17.2/firebase-auth.js"></script>
  <script src="https://www.gstatic.com/firebasejs/7.17.2/firebase-firestore.js"></script>
  <script>
    var firebaseConfig = {
      apiKey: "AIzaSyC690bkpcy8xkMrR0MIa37tOpJUqPFuA0k",
     authDomain: "firestore-5643d.firebaseapp.com",
      databaseURL: "https://firestore-5643d.firebaseio.com",
      projectId: "firestore-5643d",
      storageBucket: "firestore-5643d.appspot.com",
      messagingSenderId: "241654013175",
      appId: "1:241654013175:web:a8331ea10e1f96ae3e07f2",
      measurementId: "G-WHYCJHVGCV"
    };
    firebase.initializeApp(firebaseConfig);
  </script>
  <script src="main.dart.js" type="application/javascript"></script>
```
