# auth

Flutter WebでFirebase AuthとFirestoreを利用してemailログインするサンプルプロジェクト
(FirestorageはFlutter Webにまだ対応してないため、アバターの画像は実装していません)
さらにレストランにレビューを行う

Flutter Webのサンプルサイトは[こちら](https://firestore-5643d.web.app)。

## 使い方

1. Firebaseの初期設定

   - プロジェクト作成
   - コンソールでAuthenticationのメール/パスワード認証を有効化。
   - Webアプリを有効化。</>をクリックしてアプリ名をセットしてアプリを登録。
   - Firebase SDKの追加に表示される内容を3のindex.htmlの設定に利用。

2. Flutterでpubspec.yamlでパッケージ追加

  ```
  # Flutter Webで利用可能
  provider: ^4.3.2+1
  responsive_grid: ^1.2.0
  smooth_star_rating: ^1.1.1
  openid_client: ^0.3.0

  # Firebase関連（Webでも利用可能）
  firebase_core: ^0.5.0
  firebase_auth: ^0.18.0+1
  cloud_firestore: ^0.14.0+1
  firebase_storage: ^4.0.0
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

4. Firebaseにプロジェクトを作成しアプリを登録すると共に、Firebaseの指示に従って設定ファイルをダウンロードしてセットする.

5. Firestoreを有効にする.

6. Firebase Authでeメール/パスワード認証を有効にし、上に以下の3ユーザを作成する. パスワードは自由です。

- ichiro@test.com
- jiro@test.com
- saburo@test.com

7. Flutter Webでテスト実行する.

```
# flutter run -d chrome
```

