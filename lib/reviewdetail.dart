import 'package:flutter/material.dart';

import 'review.dart';
import 'starrating.dart';

class ReviewDetail extends StatefulWidget {
  ReviewDetail({@required this.review});
  final Review review;
  @override
  _ReviewDetailState createState() => _ReviewDetailState();
}

class _ReviewDetailState extends State<ReviewDetail> {
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: screenHeight,
            width: screenWidth,
            color: Colors.transparent
          ),
          Container(
            height: screenHeight / 2,
            width: screenWidth,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.review.restologo),
                fit: BoxFit.cover
              )
            )
          ),
          Positioned(
            top: screenHeight/2,
            child: Container(
              padding: EdgeInsets.only(left:20.0,right:20.0),
              height: screenHeight / 2,
              width: screenWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        StarRating(
                          rating: widget.review.star.toDouble(),
                          size: 30.0,
                        ),
                        SizedBox(width: 10.0),
                        Text(widget.review.star.toString(),
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          )
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(
                      child: Text(
                        widget.review.comment,
                        maxLines: 10,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black
                        ),
                        strutStyle: StrutStyle(
                          fontSize: 14.0,
                          height: 1.2
                        ),
                      ),
                    ),
                  ),
                ]
              ),
            )
          ),
          Align( // レビューリストに戻る
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 15.0, top: 30.0),
              child: Container(
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                child: Center(
                  child: InkWell(
                    child: Icon(Icons.arrow_back,size:20.0,color:Colors.white),
                    onTap: () => Navigator.of(context).pop(),
                  )
                )
              )
            )
          ),
          Align(
            alignment: Alignment.topRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // レビューを削除する
                Padding(
                  padding: EdgeInsets.only(right: 15.0, top: 30.0),
                  child: Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                    child: Center(
                      child: InkWell(
                        child: Icon(Icons.delete,size:20.0,color:Colors.white),
                        onTap: () {
                          Review.deleteReview(widget.review);
                          Navigator.of(context).pop();
                        },
                      ),
                    )
                  )
                ),
                // レビューを編集に切り替える
                Padding(
                  padding: EdgeInsets.only(right: 15.0, top: 30.0),
                  child: Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                    child: Center(
                      child: InkWell(
                        child: Icon(Icons.edit,size:20.0,color:Colors.white),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ReviewEdit(review:widget.review))
                          ).then((_) => setState((){})); // 画面をリロードする
                        },
                      ),
                    )
                  )
                ),
              ],
            )
          ),
        ],
      )
    );
  }
}

class ReviewEdit extends StatelessWidget {
  ReviewEdit({@required this.review});
  final Review review;

  int star;
  TextEditingController cmtCtrl;

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    star = review.star;
    cmtCtrl =  TextEditingController(text: review.comment);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: screenHeight,
            width: screenWidth,
            color: Colors.transparent
          ),
          Container(
            height: screenHeight / 2,
            width: screenWidth,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(review.restologo),
                fit: BoxFit.cover
              )
            )
          ),
          Positioned(
            top: screenHeight/2,
            child: Container(
              padding: EdgeInsets.only(left:20.0,right:20.0),
              height: screenHeight / 2,
              width: screenWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        StarRating(
                          allowHalfRating: false,
                          rating: star.toDouble(),
                          size: 30.0,
                          isReadOnly: false,
                          onRated: (_star) {
                            star = _star.toInt();
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(
                      child: TextField(
                        controller: cmtCtrl,
                        maxLength: 500,
                        maxLengthEnforced: true,
                        maxLines: 10,
                        showCursor: true,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black
                        ),
                        strutStyle: StrutStyle(
                          fontSize: 14.0,
                          height: 1.1
                        ),
                      ),
                    ),
                  ),
                ]
              ),
            )
          ),
          Align( // レビュー詳細に戻る
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 15.0, top: 30.0),
              child: Container(
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                child: Center(
                  child: InkWell(
                    child: Icon(Icons.arrow_back,size:20.0,color:Colors.white),
                    onTap: () => Navigator.of(context).pop(),
                  )
                )
              )
            )
          ),
          Align( // 追加・編集した情報を追加
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(right: 15.0, bottom: 15.0),
              child: Container(
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                child: Center(
                  child: InkWell(
                    child: Icon(Icons.save_alt,size:20.0,color:Colors.white),
                    onTap: () {
                      Review.setReview(
                        review.copy(star:star.toDouble(),comment:cmtCtrl.text,),
                        review.star,
                      );
                      Navigator.of(context).pop(); // レビュー詳細に戻る
                    },
                  )
                )
              )
            )
          ),
        ],
      )
    );
  }
}

class UserReviewDetail extends StatelessWidget {
  UserReviewDetail({@required this.review});
  final Review review;
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: screenHeight,
            width: screenWidth,
            color: Colors.transparent
          ),
          Container(
            height: screenHeight / 2,
            width: screenWidth,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(review.restologo),
                fit: BoxFit.cover
              )
            )
          ),
          Positioned(
            top: screenHeight/2 + 50.0,
            child: Container(
              padding: EdgeInsets.only(left:20.0,right:20.0),
              height: screenHeight / 2 + 25.0,
              width: screenWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.0),
                  Expanded(
                    flex: 1,
                    child: Text(review.username,
                      style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.w500
                      )
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        StarRating(
                          rating: review.star.toDouble(),
                          size: 30.0,
                        ),
                        SizedBox(width: 10.0),
                        Text(review.star.toString(),
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          )
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Expanded(
                    flex: 5,
                    child: Container(
                      child: Text(
                        review.comment,
                        maxLines: 10,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black
                        ),
                        strutStyle: StrutStyle(
                          fontSize: 14.0,
                          height: 1.2
                        ),
                      ),
                    ),
                  ),
                ]
              ),
            )
          ),
          Align( // レビューリストに戻る
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 15.0, top: 30.0),
              child: Container(
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                child: Center(
                  child: InkWell(
                    child: Icon(Icons.arrow_back,size:20.0,color:Colors.white),
                    onTap: () => Navigator.of(context).pop(),
                  )
                )
              )
            )
          ),
          Positioned( // レビュー者の顔写真
            top: screenHeight / 2 - 50.0,
            right: 20.0,
            child: Hero(
              tag: review.id,
              child: Container(
                height: 150.0,
                width: 150.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(review.userphotourl),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(15.0)
                )
              )
            )
          )
        ],
      )
    );
  }
}
