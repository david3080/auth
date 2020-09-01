import 'package:auth/starrating.dart';
import 'package:flutter/material.dart';
import 'review.dart';
import 'reviewdetail.dart';

class ReviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Review>>(
      stream: Review.getReviwsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<Review> reviews = snapshot.data;
          if (reviews.isNotEmpty) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  "レビュー",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              body: ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (BuildContext context, int index) {
                  var inkWell = InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => UserReviewDetail(review:reviews[index]),
                      ));
                    },
                    child: RestoUserReviewListTile(review:reviews[index]),
                  );
                  return inkWell;
                }
              ),
            );
          } else {
            return Container(child: Center(child: Text("Empty...")));
          }
        } else {
          return Container(child: Center(child: CircularProgressIndicator()));
        }
      }
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
            borderRadius: BorderRadius.circular(5.0)
          ),
        ),
      ),
      title: StarRating(
        rating: review.star.toDouble(),
      ),
      subtitle: Text(
        review.comment,
        style: TextStyle(fontSize:10),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      trailing: Icon(Icons.keyboard_arrow_right),
    );
  }
}

// レストラン画像を表示するタイル
class RestoReviewListTile extends StatelessWidget {
  RestoReviewListTile({@required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(review.restologo),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(5.0)
        ),
      ),
      title: StarRating(
        rating: review.star.toDouble(),
      ),
      subtitle: Text(
        review.comment,
        style: TextStyle(fontSize:10),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      trailing: Icon(Icons.keyboard_arrow_right),
    );
  }
}

// レストランとユーザ画像を表示するタイル
class RestoUserReviewListTile extends StatelessWidget {
  RestoUserReviewListTile({@required this.review});
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
            borderRadius: BorderRadius.circular(5.0)
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.only(top:5),
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(review.restologo),
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.circular(5.0)
            ),
          ),
          SizedBox(width:10),
          StarRating(
            rating: review.star.toDouble(),
          ),
        ],
      ),
      subtitle: Text(
        review.comment,
        style: TextStyle(fontSize:10),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      trailing: Icon(Icons.keyboard_arrow_right),
    );
  }
}
