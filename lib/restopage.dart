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

class RestoPage extends StatelessWidget {
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
                  children: restos
                      .map((resto) =>
                          RestoCard(resto: resto))
                      .toList(),
                ),
              );
            } else {
              return Container(child: Center(child: Text("Empty...")));
            }
          } else {
            return Container(child: Center(child: CircularProgressIndicator()));
          }
        });
  }
}

class RestoCard extends StatelessWidget {
  RestoCard({
    @required this.resto,
  });
  Resto resto;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => RestoDetail(
              resto: resto,
            ),
          ));
        },
        splashColor: Colors.blue.withAlpha(30),
        child: Container(
          height: 250,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(resto.logo),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: null),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            resto.name,
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(0, (kIsWeb ? 0 : 2), 0, 4),
                      alignment: Alignment.bottomLeft,
                      child: StarRating(
                        rating: resto.star,
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        '${resto.type} ● ${resto.address}',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final userColRef = FirebaseFirestore.instance.collection("users");

class RestoDetail extends StatefulWidget {
  RestoDetail({
    @required this.resto,
  });
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
        Container(
            // 全体の背景
            height: screenHeight,
            width: screenWidth,
            color: Colors.transparent),
        Container(
            // 上半分はお店のロゴ
            height: screenHeight / 2,
            width: screenWidth,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(widget.resto.logo), fit: BoxFit.cover))),
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
                  ).then((_) => setState((){})); // 画面をリロードする
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
          child: Container(
            padding: EdgeInsets.only(left: 20.0),
            width: screenWidth,
            height: screenHeight / 2,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: 5.0),
              // レストラン名
              Text(
                  widget.resto.name,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  )),
              SizedBox(height: 3.0),
              Row(
                children: <Widget>[
                  // レストランの平均星数とレビュー人数
                  StarRating(
                    rating: widget.resto.star,
                    size: 15.0,
                  ),
                  SizedBox(width: 3.0),
                  Text(widget.resto.star.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      )),
                  SizedBox(width: 3.0),
                  Text('(${widget.resto.reviewCount} Reviews)',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ))
                ],
              ),
              SizedBox(height: 5.0),
              Flexible(
                // レビューリスト
                child: StreamBuilder<List<Review>>(
                    stream: Review.getRestoReviwsStream(widget.resto.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final List<Review> reviews = snapshot.data;
                        if (reviews.isNotEmpty) {
                          return ListView.builder(
                              itemCount: reviews.length,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => UserReviewDetail(
                                          review: reviews[index]),
                                    ));
                                  },
                                  child: UserReviewListTile(review:reviews[index],),
                                );
                              });
                        } else {
                          return Container(
                              child: Center(child: Text("Empty...")));
                        }
                      } else {
                        return Container(
                            child: Center(child: CircularProgressIndicator()));
                      }
                    }),
              )
            ]),
          ),
        ),
      ]),
    );
  }
}
