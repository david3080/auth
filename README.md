# auth

Flutter WebでFirebase AuthとFirestoreを利用してemailログインするサンプルプロジェクト
(FirestorageはFlutter Webにまだ対応してないため、アバターの画像は実装していません)
さらにレストランにレビューを行う

Flutter Webのサンプルサイトは[こちら](https://firestore-5643d.web.app)からアクセスできます。

## 参考サイト

本アプリケーションの開発方法の詳細は[こちら](https://david3080.github.io/firestore/)で解説しています。

## 要改善点

- アカウント画面のアバターの写真表示に、顔写真が登録されていない場合メアド一文字目を表示するようにする。
- レビュー情報に登録者のメアドを追加して、顔写真が登録されていない場合メアド一文字目を表示するようにする。
- レビュー追加・編集時に星数セットしたものと登録される星数が一致しないことがある（星数変化と共にsetStateが必要？）。
- アカウント画面からレビュー編集確定後にレビュー詳細画面に戻るが、編集済み星数データが反映されない（星数変化と共にsetStateが必要？）。
- レストランリストや詳細画面に食事タイプが表示されない。
- レストランの平均星数データの不整合が発生しているっぽい。

## 使い方

1. Firebaseを初期設定する。

   - プロジェクト作成
   - コンソールでAuthenticationのメール/パスワード認証を有効化。
   - Webアプリを有効化。</>をクリックしてアプリ名をセットしてアプリを登録。
   - Firebase SDKの追加に表示される内容を3のindex.htmlの設定に利用。

2. Flutterのpubspec.yamlにパッケージを追加する。

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

3. index.htmlにJSとFlutterアプリconfigを設定する。

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

4. Firestoreを有効にする。

5. Authenticationのメール/パスワード認証に、以下の3ユーザを作成する。パスワードは自由です。

- ichiro@test.com
- jiro@test.com
- saburo@test.com

6. Flutter Webでテスト実行する。

  ```
  # flutter run -d chrome
  ```
