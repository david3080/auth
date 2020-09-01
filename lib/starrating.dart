
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class StarRating extends StatelessWidget {
  StarRating({
    this.allowHalfRating = true,
    this.rating,
    this.color = Colors.amber,
    this.size = 24,
    this.isReadOnly = true,
    this.onRated,
  });
  final bool allowHalfRating;
  final double rating;
  final double size;
  final Color color;
  final bool isReadOnly;
  final void Function(double) onRated;

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
      onRated: onRated,
    );
  }
}
