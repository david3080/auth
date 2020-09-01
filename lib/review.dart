import 'package:cloud_firestore/cloud_firestore.dart';

final restoColRef = FirebaseFirestore.instance.collection("restos");
final reviewColGrpRef =
    FirebaseFirestore.instance.collectionGroup("reviews"); // コレクショングループ

class Review {
  Review({
    this.id,
    this.star = 0,
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
    int star;
    if (data['star'] is double) {
      // マップ上の値がdoubleならintに変換してセット
      double star0 = data['star'];
      star = star0.toInt();
    } else {
      star = data['star'];
    }
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
    double star,
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

  // レビュー情報を追加・更新する
  static Future<void> setReview(Review review, int oldStar) async {
    DocumentReference _restoDocRef = restoColRef.doc(review.restoid);
    if (review.id == null) {
      // 追加
      Review _newReview = Review.fromMap(_restoDocRef.collection("reviews").doc().id, review.toMap());
      await _restoDocRef.collection("reviews").doc().set(_newReview.toMap());
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
      // 更新
      await _restoDocRef.collection("reviews").doc(review.id).get().then((snapshot) async {
        // 星数の平均を計算しなおしてセット
        var restoMap = review.toMap();
        // トータルの星数を追加レビュー分増やす
        int totalStarCount = restoMap["totalStarCount"];
        restoMap["totalStarCount"] = totalStarCount + (review.star - oldStar);
        // 平均の星数を計算する
        restoMap["star"] = restoMap["totalStarCount"] / restoMap["reviewCount"];
        await _restoDocRef.update(restoMap);
      });
    }
  }

    // レビュー情報を削除新する
  static Future<void> deleteReview(Review review) async {
    // レビューの削除
    DocumentReference _restoDocRef = restoColRef.doc(review.restoid);
    await _restoDocRef.collection("reviews").doc(review.id).delete();

    // レストランの星数の平均を計算しなおしてセット
    await _restoDocRef.get().then((snapshot) async {
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
