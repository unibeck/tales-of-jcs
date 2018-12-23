import 'package:tales_of_jcs/tale/tale_rating.dart';
import 'package:tales_of_jcs/user/user.dart';

class Tale {

  String title;
  String story;
  User publisher;
  TaleRating rating;
  List<User> readBy = [];
  bool jcsVerified = false;
  List<String> tags = [];
  DateTime dateCreated;
  DateTime dateLastModified;

  Tale(this.title, this.story, this.publisher, this.rating, this.readBy,
      this.jcsVerified, this.tags, this.dateCreated, this.dateLastModified);

  Tale.fromJson(Map<String, dynamic> json):
        title = json['title'],
        story = json['story'],
        publisher = json['publisher'],
        rating = json['rating'],
        readBy = json['readBy'],
        jcsVerified = json['jcsVerified'],
        tags = json['tags'],
        dateCreated = json['dateCreated'],
        dateLastModified = json['dateLastModified'];

  Map<String, dynamic> toJson() =>
      {
        'title': title,
        'story': story,
        'publisher': publisher,
        'rating': rating,
        'readBy': readBy,
        'jcsVerified': jcsVerified,
        'tags': tags,
        'dateCreated': dateCreated,
        'dateLastModified': dateLastModified,
      };
}