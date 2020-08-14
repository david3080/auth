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

   ```
   firebase: ^7.3.0
   firebase_auth: ^0.16.1
   cloud_firestore: ^0.13.7
   provider: ^4.3.2
   openid_client: ^0.3.0
   ```

3. index.htmlにJSとFlutterアプリconfigを設定

   下記の順番でないとエラーが発生します

   - Firebas関連のJSを読み込む
   - configをセットし、initializeAppする
   - main.dart.jsを読み込む

   ```
   <script src="https://www.gstatic.com/firebasejs/7.17.2/firebase-app.js"></script>
   <script src="https://www.gstatic.com/firebasejs/7.17.2/firebase-auth.js"></script>
   <script src="https://www.gstatic.com/firebasejs/7.17.2/firebase-firestore.js"></script>
   <script>
     var firebaseConfig = {
       apiKey: "...",
       authDomain: "...",
       databaseURL: "...",
       projectId: "...",
       storageBucket: "...",
       messagingSenderId: "...",
       appId: "...",
       measurementId: "...",
     };
     firebase.initializeApp(firebaseConfig);
    </script>
    <script src="main.dart.js" type="application/javascript"></script>
  ```
