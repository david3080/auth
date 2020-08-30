import 'package:flutter/material.dart';

import 'restopage.dart';
import 'review.dart';

class ReviewDetail extends StatelessWidget {
  ReviewDetail({@required this.review,this.restoLogo});
  final Review review;
  final String restoLogo;

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
                image: NetworkImage(restoLogo),
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
                          rating: review.star,
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
                    child: SingleChildScrollView(
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
                  ),
                ]
              ),
            )
          ),
          Align( // レビューリストに戻る
            alignment: Alignment.topLeft,
            child: InkWell(
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
              ),
            )
          ),
          Align( // レビューを編集に切り替える
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(right: 15.0, top: 30.0),
              child: Container(
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                child: Center(
                  child: Icon(Icons.edit,size:20.0,color:Colors.white)
                )
              )
            )
          ),
          Positioned( // レビュー者の顔写真
            top: screenHeight / 2 - 50.0,
            right: 20.0,
            child: Hero(
              tag: review.userphotourl,
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
