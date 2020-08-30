import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'dart:math' as math;
import 'resto.dart';
import 'review.dart';
import 'reviewpage.dart';

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
                  desiredItemWidth: math.min(_cardWidth,MediaQuery.of(context).size.width - (2 * _minSpacingPx)),
                  minSpacing: _minSpacingPx,
                  children: restos.map((resto) => RestoCard(resto: resto)).toList(),
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
  RestoCard({this.resto});
  final Resto resto;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => RestoDetail(resto: resto),
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

class StarRating extends StatelessWidget {
  StarRating({
    this.allowHalfRating = true,
    this.rating,
    this.color = Colors.amber,
    this.size = 24,
    this.isReadOnly = true,
  });
  final bool allowHalfRating;
  final double rating;
  final double size;
  final Color color;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    return SmoothStarRating(
      starCount: 5,
      allowHalfRating: allowHalfRating,
      rating: rating,
      color: color,
      borderColor: color,
      size: size,
      isReadOnly: isReadOnly,
    );
  }
}

class RestoDetail extends StatelessWidget {
  RestoDetail({@required this.resto});
  final Resto resto;

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container( // 全体の背景
            height: screenHeight,
            width: screenWidth,
            color: Colors.transparent
          ),
          Container( // 上半分はお店のロゴ
            height: screenHeight / 2,
            width: screenWidth,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(resto.logo),
                fit: BoxFit.cover
              )
            )
          ),
          Align( // 画面左上は戻るボタン
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
                    child: Icon(Icons.arrow_back, size: 20.0, color: Colors.white)
                  )
                ),
              )
            )
          ),
          Positioned( // レビュー書き込みボタン
            top: screenHeight/2,
            right: 20,
            child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  height: 80.0,
                  width: 80.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Icon(Icons.chat,size:40.0,color:Colors.black)
                  )
                ),
              )
            ),
          Positioned( // 下半分はお店情報とレビューリスト
            top: screenHeight / 2,
            child: Container(
              padding: EdgeInsets.only(left: 20.0),
              width: screenWidth,
              height: screenHeight / 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5.0),
                  Text( // レストラン名
                    resto.name,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    )
                  ),
                  SizedBox(height: 3.0),
                  Row(
                    children: <Widget>[ // レストランの平均星数とレビュー人数
                      StarRating(
                        rating: resto.star,
                        size: 15.0,
                      ),
                      SizedBox(width: 3.0),
                      Text(
                        resto.star.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        )
                      ),
                      SizedBox(width: 3.0),
                      Text(
                        '(${resto.reviewCount} Reviews)',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        )
                      )
                    ],
                  ),
                  SizedBox(height: 5.0),
                  Flexible( // レビューリスト
                    child: StreamBuilder<List<Review>>(
                      stream: Review.getReviwsStream(resto.id),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final List<Review> reviews = snapshot.data;
                          if (reviews.isNotEmpty) {
                            return ListView.builder(
                              itemCount: reviews.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Dismissible(
                                  key: UniqueKey(),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (DismissDirection direction) async {
                                    Review.deleteReview(resto.id, reviews[index].id);
                                  },
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => ReviewDetail(review:reviews[index],restoLogo:resto.logo),
                                      ));
                                    },
                                    child: ListTile(
                                      leading: Hero(
                                        tag: reviews[index].userphotourl,
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(reviews[index].userphotourl),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.circular(5.0)
                                          ),
                                        ),
                                      ),
                                      title: StarRating(
                                         rating: reviews[index].star,
                                      ),
                                      subtitle: Text(
                                        reviews[index].comment,
                                        style: TextStyle(fontSize:10),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      trailing: Icon(Icons.keyboard_arrow_right),
                                    ),
                                  ),
                                );
                              }
                            );
                          } else {
                            return Container(child: Center(child: Text("Empty...")));
                          }
                        } else {
                          return Container(child: Center(child: CircularProgressIndicator()));
                        }
                      }
                    ),
                  )
                ]
              ),
            ),
          ),
        ]
      ),
    );
  }
}