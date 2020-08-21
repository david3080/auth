
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final restoRef = FirebaseFirestore.instance.collection("restos");

class Review {
  Review({@required this.id,@required this.star,this.comment,@required this.uid,@required this.username,this.userphotourl,@required this.restoname});
  final String id;
  final double star;
  final String comment;
  final String uid;
  final String username;
  final String userphotourl;
  final String restoname;

  @override
  String toString() {
    return "id:$id,star:$star,comment:$comment,uid:$uid,username:$username,userphotourl:$userphotourl,restoname:$restoname";
  }

  factory Review.fromMap(String documentId, Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    double star;
    if(data['star'] is int) {
      int star0 = data['star'];
      star = star0.toDouble();
    } else {
      star = data['star'];
    }
    final String comment = data['comment'];
    final String uid = data['uid'];
    final String username = data['username'];
    final String userphotourl = data['userphotourl'];
    final String restoname = data['restoname'];
    return Review(
      id: documentId,
      star: star,
      comment: comment,
      uid: uid,
      username: username,
      userphotourl: userphotourl,
      restoname: restoname,
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
      "restoname": restoname
    };
  }

  Review copy(
      {String id, double star, String comment, String uid, String username, String userphotourl, String restoname}) {
    return Review(
      id: id != null ? id : this.id,
      star: star != null ? star : this.star,
      comment: comment != null ? comment : this.comment,
      uid: uid != null ? uid : this.uid,
      username: username != null ? username : this.username,
      userphotourl: userphotourl != null ? userphotourl: this.userphotourl,
      restoname: restoname != null ? restoname : this.restoname,
    );
  }

  static Future<void> deleteReview(String restoId, String reviewId) {
    return restoRef.doc(restoId).collection("reviews").doc(reviewId).delete();
  }

  static Stream<List<Review>> getReviwsStream(String restoId) {
    return restoRef.doc(restoId).collection("reviews").snapshots().map((snapshot) {
      return snapshot.docs.map((snapshot) {
        return Review.fromMap(snapshot.id,snapshot.data());
      }).toList();
    });
  }
}
