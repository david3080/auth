import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final restoColRef = FirebaseFirestore.instance.collection("restos");
final userColRef = FirebaseFirestore.instance.collection("users");

class Resto {
  Resto({
    @required this.id,
    @required this.name,
    this.type,
    this.address,
    this.logo,
    this.star = 0.0,
    this.reviewCount = 0,
    this.totalStarCount = 0,
  });
  final String id;
  final String name;
  final String type;
  final String address;
  final String logo;
  final double star;
  final int reviewCount;
  final int totalStarCount;

  @override
  String toString() {
    return "id:$id,name:$name,type:$type,address:$address,logo:$logo,star:$star,reviewCount:$reviewCount,totalStarCount:$totalStarCount";
  }

  factory Resto.fromMap(String documentId, Map<String, dynamic> data) {
    if (documentId==null||documentId==""||data==null) {
      return null;
    }
    final String name = data['name']??""; // @requiredなのでnull値でなく空白""をセット
    final String type = data['type'];
    final String address = data['address'];
    final String logo = data['logo'];
    double star;
    if(data['star'] is int) { // マップ上の値がintならdoubleに変換してセット
      int star0 = data['star'];
      star = star0.toDouble();
    } else {
      star = data['star']??0.0;
    }
    final int reviewCount = data['reviewCount']??0;
    final int totalStarCount = data['totalStarCount']??0;
    return Resto(
      id: documentId,
      name: name,
      type: type,
      address: address,
      logo: logo,
      star: star,
      reviewCount: reviewCount,
      totalStarCount: totalStarCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "type": type,
      "address": address,
      "logo": logo,
      "star": star,
      "reviewCount": reviewCount,
      "totalStarCount": totalStarCount,
    };
  }

  Resto copy(
      {String id,String name,String type,String address,String logo,double star,int reviewCount,int totalStarCount,}) {
    return Resto(
      id: id != null ? id : this.id,
      name: name != null ? name: this.name,
      type: type != null ? type: this.type,
      address: address != null ? address: this.address,
      logo: logo != null ? logo: this.logo,
      star: star != null ? star : this.star,
      reviewCount: reviewCount != null ? reviewCount: this.reviewCount,
      totalStarCount: totalStarCount != null ? totalStarCount: this.totalStarCount,
    );
  }

  static Stream<List<Resto>> getRestosStream() {
    return restoColRef.snapshots().map((snapshot) {
      return snapshot.docs.map((snapshot) {
        return Resto.fromMap(snapshot.id,snapshot.data());
      }).toList();
    });
  }

  static List restos = jsonDecode(initRestoString);
  // レストランコレクションがなければ初期データをセット
  static void initRestos() {
    restoColRef.get().then((snapshot) {
      if(snapshot.size == 0) {
        restos.forEach((_resto) {
          var _restoDocRef = restoColRef.doc(); // レストランドキュメント参照の初期化
          Resto resto = Resto.fromMap(_restoDocRef.id, _resto); // レストランにdocumentIdをセット
          _restoDocRef.set(resto.toMap()).then((_) { // レストラン情報を保存
            if(_resto["reviews"]!=null) { // レストランにレビューがある場合
              // JSONからレビュー情報を取得
              List _reviews = _resto["reviews"];
              // レストラン配下にレビューリストを追加
              _reviews.forEach((_review) {
                userColRef.where("name",isEqualTo:_review["username"]).get().then((snapshot) async { // 登録ユーザ情報取得
                  Map<String,dynamic> _user = snapshot.docs[0].data();
                  _review["uid"] = _user["uid"];
                  _review["username"] = _user["name"];
                  _review["userphotourl"] = _user["url"];
                  _review["restoid"] = resto.id;
                  _review["restoname"] = resto.name;
                  _review["restologo"] = resto.logo;
                  DocumentReference _reviewDocRef = _restoDocRef.collection("reviews").doc();
                  _review["id"] = _reviewDocRef.id;
                  _reviewDocRef.set(_review);
                });
              });
              // レストランの平均星数を計算
              int reviewCount = 0;
              int totalStarCount = 0;
              _reviews.forEach((_review) {
                  reviewCount = reviewCount + 1;
                  if(_review["star"] is int) {
                    int _star = _review["star"];
                    totalStarCount = totalStarCount + _star;
                  } else if(_review["star"] is double) {
                    double _star = _review["star"];
                    totalStarCount = totalStarCount + _star.toInt();
                  }
              });
              // レストランの平均星数を更新
              double star = totalStarCount/reviewCount;
              Resto newResto = resto.copy(reviewCount:reviewCount,totalStarCount:totalStarCount,star:star);
              _restoDocRef.set(newResto.toMap(),SetOptions(merge:true));
            }
          });
        });
      }
    });
  }
}

const String initRestoString = '''
  [
    {
      "_id": 0,
      "name": "ガスト東岡崎店",
      "type": "洋食",
      "address": "愛知県岡崎市大西１丁目１−１０",
      "logo": "https://raw.githubusercontent.com/david3080/auth/master/images/gusto.png",
      "reviews": [
        {
          "_id": 0,
          "star": 2,
          "comment": "値段の割に合わない気がする。チーズハンバーグを頼んだが、レトルトな感じでした。さらに、スープセットにしたが、スープは一種類。これなら、ステーキ宮のスープセット(4種類のスープが選びたい放題)の方がより楽しめると思う。ガストより少しお値段上がりますが。",
          "uid": 0,
          "username": "鈴木一郎",
          "userphotourl": "https://meikyu-kai.org/wp-content/uploads/2020/01/51_Ichiro.jpg",
          "restoname": "ガスト東岡崎店",
          "restologo": "https://raw.githubusercontent.com/david3080/auth/master/images/gusto.png"
        },
        {
          "_id": 1,
          "star": 3,
          "comment": "タブレットによる注文に変わったが、慣れが必要。メニューを広げて、料理を比べたい。この方式で価格が下がればよいが、、、",
          "uid": 1,
          "username": "佐藤二郎",
          "userphotourl": "http://www.from1-pro.jp/images/t_10/img_l.jpg",
          "restoname": "ガスト東岡崎店",
          "restologo": "https://raw.githubusercontent.com/david3080/auth/master/images/gusto.png"
        },
        {
          "_id": 2,
          "star": 5,
          "comment": "ドリンクバーが99円(単品で注文してもOK).パソコンの持ち込みOK.コンセントで充電できる.持ち帰り容器は無料.食べきれない料理の持ち帰りOK.トイレは新しくてキレイ",
          "uid": 2,
          "username": "北島三郎",
          "userphotourl": "https://cdn.asagei.com/asagei/uploads/2016/08/20160810kitajima.jpg",
          "restoname": "ガスト東岡崎店",
          "restologo": "https://raw.githubusercontent.com/david3080/auth/master/images/gusto.png"
        }
      ]
    },
    {
      "_id": 1,
      "name": "デニーズ東岡崎店",
      "type": "洋食",
      "address": "愛知県岡崎市美合町 字五反田２５－１",
      "logo": "https://sozainavi.com/wp-content/uploads/2019/10/dennys.jpg",
      "star": 0.0
    },
    {
      "_id": 2,
      "name": "大戸屋ごはん処岡崎店",
      "type": "和食",
      "address": "愛知県岡崎市井田西町１−１１",
      "logo": "https://sozainavi.com/wp-content/uploads/2019/10/ootoya.jpg",
      "star": 0.0
    },
    {
      "_id": 3,
      "name": "和食さと岡崎店",
      "type": "和食",
      "address": "愛知県岡崎市上里２丁目１−１",
      "logo": "https://sato-res.com/assets/tile/sato.png",
      "star": 0.0
    },
    {
      "_id": 4,
      "name": "カレーハウスCoCo壱番屋岡崎上地店",
      "type": "カレー",
      "address": "愛知県岡崎市上地３丁目５１−６",
      "logo": "https://www.ichibanya.co.jp/assets/images/common/ogp.png",
      "star": 0.0
    },
    {
      "_id": 5,
      "name": "スシロー岡崎上和田店",
      "type": "寿司",
      "address": "愛知県岡崎市天白町東池１５−１",
      "logo": "https://www.akindo-sushiro.co.jp/shared/images/ogp.png",
      "star": 0.0
    },
    {
      "_id": 6,
      "name": "くら寿司北岡崎店",
      "type": "寿司",
      "address": "愛知県岡崎市錦町２−１２",
      "logo": "https://www.watch.impress.co.jp/img/ipw/docs/1230/499/kura1_s.jpg",
      "star": 0.0
    },
    {
      "_id": 7,
      "name": "モスバーガー岡崎大西店",
      "type": "ハンバーガー",
      "address": "愛知県岡崎市大西１丁目１６−７",
      "logo": "http://www.wing-net.ne.jp/image/kamiooka/store/storage/w250/mos.png",
      "star": 0.0
    },
    {
      "_id": 8,
      "name": "マクドナルド岡崎インター店",
      "type": "ハンバーガー",
      "address": "愛知県岡崎市大平町石丸６０−１",
      "logo": "https://sozainavi.com/wp-content/uploads/2019/10/mcdonalds.png",
      "star": 0.0
    },
    {
      "_id": 9,
      "name": "かつや愛知岡崎インター店",
      "type": "とんかつ",
      "address": "愛知県岡崎市大平町新寺25",
      "logo": "https://raw.githubusercontent.com/david3080/auth/master/images/katsuya.png",
      "star": 0.0
    }
  ]
''';