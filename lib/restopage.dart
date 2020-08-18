import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'dart:math' as math;
import 'resto.dart';

const double _minSpacingPx = 16;
const double _cardWidth = 360;

final restoRef = Firestore.instance.collection("restos");

class RestoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Resto>>(
        stream: restoRef.snapshots().map((snapshot) {
          return snapshot.documents.map((snapshot) {
                    return Resto.fromMap(snapshot.documentID,snapshot.data);
                  }).toList();
        }),
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
      onTap: () => null,
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
    ));
  }
}

class StarRating extends StatelessWidget {
  StarRating({
    this.rating,
    this.color = Colors.amber,
    this.size = 24,
  });
  final double rating;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SmoothStarRating(
      starCount: 5,
      allowHalfRating: true,
      rating: rating,
      color: color,
      borderColor: color,
      size: size,
    );
  }
}
