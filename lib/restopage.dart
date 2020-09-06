import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'dart:math' as math;
import 'resto.dart';
import 'review.dart';
import 'reviewdetail.dart';
import 'reviewpage.dart';
import 'starrating.dart';
import 'user.dart';

const double _minSpacingPx = 16;
const double _cardWidth = 360;

class RestoPage extends StatefulWidget {
  @override
  _RestoPageState createState() => _RestoPageState();
}

class _RestoPageState extends State<RestoPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Resto>>(
        stream: Resto.getRestosStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<Resto> restos = snapshot.data;
            if (restos.isNotEmpty) {
              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(
                    "レストラン",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                body: ResponsiveGridList(
                  desiredItemWidth: math.min(_cardWidth,
                      MediaQuery.of(context).size.width - (2 * _minSpacingPx)),
                  minSpacing: _minSpacingPx,
                  children: restos.map((resto) {
                    return Card(
                      child: InkWell(
                        onTap:()=>Navigator.of(context).push(
                          MaterialPageRoute(builder:(context)=>RestoDetail(resto:resto)),
                        ).then((_) => setState((){})), // レストラン詳細画面から戻ったら画面リロード
                        splashColor: Colors.blue.withAlpha(30),
                        child: Container(
                          height: 250,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(image: NetworkImage(resto.logo),fit: BoxFit.cover)
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(resto.name,style: Theme.of(context).textTheme.subtitle2),
                                    StarRating(rating: resto.star),
                                    Text('${resto.type} ${resto.address}',style:Theme.of(context).textTheme.caption),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            } else {
              return Container(child: Center(child: Text("該当するレストランはありません。")));
            }
          } else {
            return Container(child: Center(child: CircularProgressIndicator()));
          }
        });
  }
}

// ユーザコレクション参照
final userColRef = FirebaseFirestore.instance.collection("users");

// レストラン詳細画面
class RestoDetail extends StatefulWidget {
  RestoDetail({@required this.resto});
  final Resto resto;

  @override
  _RestoDetailState createState() => _RestoDetailState();
}

class _RestoDetailState extends State<RestoDetail> {
  @override
  Widget build(BuildContext context) {
    auth.User authUser = auth.FirebaseAuth.instance.currentUser;
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(children: <Widget>[
        // 全体の背景
        Container(height:screenHeight,width:screenWidth,color:Colors.transparent),
        // 上半分はお店のロゴ
        Container(
            height: screenHeight / 2,
            width: screenWidth,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.resto.logo), fit: BoxFit.cover),
              ),
            ),
        Align(
            // 画面左上は戻るボタン
            alignment: Alignment.topLeft,
            child: Padding(
                padding: EdgeInsets.only(left: 15.0, top: 20.0),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                      height: 40.0,
                      width: 40.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: Center(
                          child: Icon(Icons.arrow_back,
                              size: 20.0, color: Colors.white))),
                ))),
        Positioned(
            // レビュー書き込みボタン
            top: screenHeight / 2,
            right: 20,
            child: InkWell(
              onTap: () {
                userColRef.doc(authUser.uid).get().then((_snapshot) {
                  User user = User.fromMap(_snapshot.id,_snapshot.data());
                  Review review = Review(
                    restoid: widget.resto.id,
                    restoname: widget.resto.name,
                    restologo: widget.resto.logo,
                    uid: user.uid,
                    username: user.name,
                    userphotourl: user.url,
                  );
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ReviewEdit(review:review)),
                  ).then((reload) {
                    if(reload) setState((){}); // 画面リロード
                  });
                });
              },
              child: Container(
                  height: 80.0,
                  width: 80.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Center(
                      child:
                          Icon(Icons.chat, size: 40.0, color: Colors.black))),
            )),
        Positioned(
          // 下半分はお店情報とレビューリスト
          top: screenHeight / 2,
          child: FutureBuilder(
            future: Resto.restoColRef.doc(widget.resto.id).get(),
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                Resto resto = Resto.fromMap(snapshot.data.id, snapshot.data.data());
                return Container(
                  padding: EdgeInsets.only(left: 20.0),
                  width: screenWidth,
                  height: screenHeight / 2,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(height:5),
                    // レストラン名
                    Text(resto.name,style:TextStyle(fontSize:18,fontWeight:FontWeight.w900)),
                    SizedBox(height:3),
                    Row(
                      children: <Widget>[
                        // レストランの平均星数とレビュー人数
                        StarRating(rating:resto.star,size:15.0),
                        SizedBox(width: 3.0),
                        Text(resto.star.toStringAsFixed(2),style:TextStyle(fontSize:14,fontWeight:FontWeight.w400)),
                        SizedBox(width: 3.0),
                        Text('(${resto.reviewCount}個のレビュー)',style:TextStyle(fontSize:14,fontWeight:FontWeight.w400)),
                      ]
                    ),
                    SizedBox(height: 5.0),
                    Flexible(
                      // レビューリスト
                      child: StreamBuilder<List<Review>>(
                        stream: Review.getRestoReviwsStream(resto.id),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final List<Review> reviews = snapshot.data;
                            if (reviews.isNotEmpty) {
                              return ListView.builder(
                                itemCount: reviews.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => UserReviewDetail(
                                          review: reviews[index]),
                                      ));
                                    },
                                    child: UserReviewListTile(review:reviews[index],),
                                  );
                                },
                              );
                            } else {
                              return Container(child: Center(child: Text("該当のレビューはありません。")));
                            }
                          } else {
                            return Container(child: Center(child: CircularProgressIndicator()));
                          }
                        },
                      ),
                    )
                  ]),
                );
              } else {
                return Container(child: Center(child: CircularProgressIndicator()));
              }
            }
          ),
        ),
      ]),
    );
  }
}

// ユーザ画像を表示するタイル
class UserReviewListTile extends StatelessWidget {
  UserReviewListTile({@required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Hero(
        tag: review.id,
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(review.userphotourl),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(5.0)),
        ),
      ),
      title: StarRating(
        rating: review.star.toDouble(),
      ),
      subtitle: Text(
        review.comment,
        style: TextStyle(fontSize: 10),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      trailing: Icon(Icons.keyboard_arrow_right),
    );
  }
}
