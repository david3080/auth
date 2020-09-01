import 'package:cloud_firestore/cloud_firestore.dart';

final restoColRef = FirebaseFirestore.instance.collection("restos");
final reviewColGrpRef =
    FirebaseFirestore.instance.collectionGroup("reviews"); // コレクショングループ

class Review {
  Review({
    this.id,
    this.star,
    this.starList,
    this.comment,
    this.uid,
    this.username,
    this.userphotourl,
    this.restoid,
    this.restoname,
    this.restologo,
  });
  final String id;
  final int star;
  final List<int> starList;
  final String comment;
  final String uid;
  final String username;
  final String userphotourl;
  final String restoid;
  final String restoname;
  final String restologo;

  @override
  String toString() {
    return "id:$id,star:$star,comment:$comment,username:$username,restoname:$restoname";
  }

  factory Review.fromMap(String documentId, Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final int star = data['star'];

    // 配列はdynamicで受けて型変換する
    final List<dynamic> _starList = data['starList'];
    List<int> starList = _starList.map((star) => star is int ? star : 0).toList();
    
    final String comment = data['comment'];
    final String uid = data['uid'];
    final String username = data['username'];
    final String userphotourl = data['userphotourl'];
    final String restoid = data['restoid'];
    final String restoname = data['restoname'];
    final String restologo = data['restologo'];
    return Review(
      id: documentId,
      star: star,
      starList: starList,
      comment: comment,
      uid: uid,
      username: username,
      userphotourl: userphotourl,
      restoid: restoid,
      restoname: restoname,
      restologo: restologo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "star": star,
      "starList": starList,
      "comment": comment,
      "uid": uid,
      "username": username,
      "userphotourl": userphotourl,
      "restoid": restoid,
      "restoname": restoname,
      "restologo": restologo
    };
  }

  Review copy({
    String id,
    int star,
    List<int> starList,
    String comment,
    String uid,
    String username,
    String userphotourl,
    String restoid,
    String restoname,
    String restologo,
  }) {
    return Review(
      id: id != null ? id : this.id,
      star: star != null ? star : this.star,
      starList: starList != null ? starList : this.starList,
      comment: comment != null ? comment : this.comment,
      uid: uid != null ? uid : this.uid,
      username: username != null ? username : this.username,
      userphotourl: userphotourl != null ? userphotourl : this.userphotourl,
      restoid: restoid != null ? restoid : this.restoid,
      restoname: restoname != null ? restoname : this.restoname,
      restologo: restologo != null ? restologo : this.restologo,
    );
  }

  // レストランを特定してそのレビューをリストします
  static Stream<List<Review>> getRestoReviwsStream(String restoId) {
    return restoColRef
        .doc(restoId)
        .collection("reviews")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((snapshot) {
        return Review.fromMap(snapshot.id, snapshot.data());
      }).toList();
    });
  }

  // レビューはコレクショングループが有効になっているので全レビューをリストします
  static Stream<List<Review>> getReviwsStream() {
    return reviewColGrpRef.snapshots().map((snapshot) {
      return snapshot.docs.map((snapshot) {
        return Review.fromMap(snapshot.id, snapshot.data());
      }).toList();
    });
  }

  // ユーザIDを指定してその人の全レビューをリストします
  static Stream<List<Review>> getUserReviwsStream(String uid) {
    return reviewColGrpRef
        .where("uid", isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((snapshot) {
        return Review.fromMap(snapshot.id, snapshot.data());
      }).toList();
    });
  }

  // レビュー情報を追加・更新する(oldStarはレビュー追加の場合0,更新の場合更新前のstarの値をセットする)
  static Future<void> setReview(Review review, int oldStar) async {
    // レストランのドキュメントリファレンスを取得
    DocumentReference _restoDocRef = restoColRef.doc(review.restoid);

    // 星数の配列を初期化
    List<int> _starList = [];
    _starList.add(review.star);

    if (review.id == null) {
      // 追加の場合
      Review _newReview = review.copy(
        id: _restoDocRef.collection("reviews").doc().id, // 新規レビューなのでIDを取得
        starList: _starList,
      );
      await _restoDocRef.collection("reviews").doc().set(_newReview.toMap()); // 新規レビューの書き込み

      // レストランの星数を更新
      await _restoDocRef.get().then((snapshot) async {
        // 星数の平均を計算しなおしてセット
        var restoMap = snapshot.data();
        // レビュー者数を1つ増やす
        int reviewCount = restoMap["reviewCount"] ?? 0;
        restoMap["reviewCount"] = reviewCount + 1;
        // トータルの星数を追加レビュー分増やす
        int totalStarCount = restoMap["totalStarCount"] ?? 0;
        restoMap["totalStarCount"] = totalStarCount + review.star;
        // 平均の星数を計算する
        restoMap["star"] = restoMap["totalStarCount"] / restoMap["reviewCount"];
        await _restoDocRef.update(restoMap);
      });
    } else {
      // 更新の場合
      Review _newReview = review.copy(
        starList: _starList,
      );
      await _restoDocRef.collection("reviews").doc(review.id).set(_newReview.toMap(),SetOptions(merge:true)); // レビュー更新

      // レストランの星数を更新
      await _restoDocRef.get().then((snapshot) async {
        // 星数の平均を計算しなおしてセット
        var restoMap = snapshot.data();
        // トータルの星数を追加レビュー分増やす
        int totalStarCount = restoMap["totalStarCount"];
        restoMap["totalStarCount"] = totalStarCount + review.star - oldStar;
        // 平均の星数を計算する
        restoMap["star"] = restoMap["totalStarCount"] / restoMap["reviewCount"];
        await _restoDocRef.update(restoMap);
      });
    }
  }

  // レビュー情報を削除する
  static Future<void> deleteReview(Review review) async {
    // レストランドキュメントを指定して、その配下の指定したレビューの削除
    DocumentReference _restoDocRef = restoColRef.doc(review.restoid);
    await _restoDocRef.collection("reviews").doc(review.id).delete();

    // レストランの星数を更新
    await _restoDocRef.get().then((snapshot) async {  
      // 星数の平均を計算しなおしてセット
      var restoMap = snapshot.data();
      // レビュー者数を1つ減らす
      int reviewCount = restoMap["reviewCount"];
      restoMap["reviewCount"] = reviewCount - 1;
      // トータルの星数を削除レビュー分減らす
      int totalStarCount = restoMap["totalStarCount"];
      restoMap["totalStarCount"] = totalStarCount - review.star;
      // 平均の星数を計算する
      restoMap["star"] = restoMap["totalStarCount"] / restoMap["reviewCount"];
      await _restoDocRef.update(restoMap);
    });
  }
}
