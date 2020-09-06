import 'package:cloud_firestore/cloud_firestore.dart';

final restoColRef = FirebaseFirestore.instance.collection("restos");
final reviewColGrpRef =
    FirebaseFirestore.instance.collectionGroup("reviews"); // コレクショングループ

class Review {
  Review({
    this.id,
    this.star = 0, // 設定がない場合の初期値
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
    final int star = data['star'];    
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
    int star,
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

  // 星数リスト（0から5まで）
  static List<int> starSelectList = [0, 1, 2, 3, 4, 5];

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

  // 全レビューをリストします。
  // レビューは単一フィールドインデックスでid,star,uid(昇降順スコープ)を除外して
  // コレクショングループを有効にしており、ここではstarを指定して対象のレビューをリストします
  static Stream<List<Review>> getReviwsStream(List<int> stars) {
    if(stars.length == 0) stars.add(-1); // 検索対象星数の設定がない場合、値としてありえない-1をセット
    return reviewColGrpRef.where("star",whereIn:stars).snapshots().map((snapshot) {
      return snapshot.docs.map((snapshot) {
        return Review.fromMap(snapshot.id, snapshot.data());
      }).toList();
    });
  }

  // ユーザIDを指定してその人の全レビューをリストします。
  // レビューは単一フィールドインデックスでid,star,uid(昇降順スコープ)を除外して
  // コレクショングループを有効にしており、ここではuidを指定して全レビューをリストします
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
    if (review.id == null) { // 追加の場合
      // 新規レビューなのでIDを取得してから書き込み
      await _restoDocRef.collection("reviews").doc().set(review.copy(id:_restoDocRef.collection("reviews").doc().id).toMap());
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
    } else { // 更新の場合
      // レビュー更新
      await _restoDocRef.collection("reviews").doc(review.id).set(review.toMap(),SetOptions(merge:true));
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
