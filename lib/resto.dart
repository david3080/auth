import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final restoRef = Firestore.instance.collection("restos");

class Resto {
  Resto({@required this.name, this.type, this.address, this.logo, this.star});
  final String name;
  final String type;
  final String address;
  final String logo;
  final double star;

  @override
  String toString() {
    return "name:$name,type:$type,address:$address,logo:$logo,star:$star";
  }

  factory Resto.fromMap(String documentId, Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final String name = data['name'];
    final String type = data['type'];
    final String address = data['address'];
    final String logo = data['logo'];
    final double star = data['star'];
    return Resto(
      name: name,
      type: type,
      address: address,
      logo: logo,
      star: star,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "type": type,
      "address": address,
      "logo": logo,
      "star": star
    };
  }

  Resto copy(
      {String name, String type, String address, String logo, double star}) {
    return Resto(
      name: name != null ? name : this.name,
      type: type != null ? type : this.type,
      address: address != null ? address : this.address,
      logo: logo != null ? logo : this.logo,
      star: star != null ? star : this.star,
    );
  }

  static List restos = jsonDecode(initRestoString);
  // レストランコレクションがなければ初期データをセット
  static void initRestos() {
    restoRef.getDocuments().then((snapshot) {
      if(snapshot.documents.length == 0) {
        restos.forEach((_resto) {
          Resto resto = Resto(name:_resto["name"],type:_resto["type"],address:_resto["address"],logo:_resto["logo"],star:_resto["star"]);
          restoRef.add(resto.toMap());
        });
      }
    });
  }
  static String initRestoString = '''
  [
    {
      "_id": 0,
      "name": "ガスト東岡崎店",
      "type": "洋食",
      "address": "愛知県岡崎市大西１丁目１−１０",
      "logo": "https://www.skylark.co.jp/site_resource/gusto/images/logo.svg",
      "star": 0
    },
    {
      "_id": 1,
      "name": "デニーズ東岡崎店",
      "type": "洋食",
      "address": "愛知県岡崎市美合町 字五反田２５－１",
      "logo": "https://sozainavi.com/wp-content/uploads/2019/10/dennys.jpg",
      "star": 0
    },
    {
      "_id": 2,
      "name": "大戸屋ごはん処岡崎店",
      "type": "和食",
      "address": "愛知県岡崎市井田西町１−１１",
      "logo": "https://sozainavi.com/wp-content/uploads/2019/10/ootoya.jpg",
      "star": 0
    },
    {
      "_id": 3,
      "name": "和食さと岡崎店",
      "type": "和食",
      "address": "愛知県岡崎市上里２丁目１−１",
      "logo": "https://sato-res.com/assets/tile/sato.png",
      "star": 0
    },
    {
      "_id": 4,
      "name": "カレーハウスCoCo壱番屋岡崎上地店",
      "type": "カレー",
      "address": "愛知県岡崎市上地３丁目５１−６",
      "logo": "https://www.ichibanya.co.jp/assets/images/common/ogp.png",
      "star": 0
    },
    {
      "_id": 5,
      "name": "スシロー岡崎上和田店",
      "type": "寿司",
      "address": "愛知県岡崎市天白町東池１５−１",
      "logo": "https://www.akindo-sushiro.co.jp/shared/images/ogp.png",
      "star": 0
    },
    {
      "_id": 6,
      "name": "くら寿司北岡崎店",
      "type": "寿司",
      "address": "愛知県岡崎市錦町２−１２",
      "logo": "https://www.watch.impress.co.jp/img/ipw/docs/1230/499/kura1_s.jpg",
      "star": 0
    },
    {
      "_id": 7,
      "name": "モスバーガー岡崎大西店",
      "type": "ハンバーガー",
      "address": "愛知県岡崎市大西１丁目１６−７",
      "logo": "http://www.wing-net.ne.jp/image/kamiooka/store/storage/w250/mos.png",
      "star": 0
    },
    {
      "_id": 8,
      "name": "マクドナルド岡崎インター店",
      "type": "ハンバーガー",
      "address": "愛知県岡崎市大平町石丸６０−１",
      "logo": "https://sozainavi.com/wp-content/uploads/2019/10/mcdonalds.png",
      "star": 0
    },
    {
      "_id": 9,
      "name": "かつや愛知岡崎インター店",
      "type": "とんかつ",
      "address": "愛知県岡崎市大平町新寺25",
      "logo": "https://www.arclandservice.co.jp/katsuya/wp-content/themes/arclandservice-group/assets/img/katsuya/common/logo.svg",
      "star": 0
    }
  ]
  ''';
}
