import 'package:tales_of_jcs/models/user/user.dart';

class TaleRating {
  double rating;
  User reviewer;

  TaleRating(this.rating, this.reviewer);

  TaleRating.fromJson(Map<String, dynamic> json)
      : rating = json['rating'],
        reviewer = json['reviewer'];

  Map<String, dynamic> toJson() => {
        'rating': rating,
        'reviewer': reviewer,
      };
}
