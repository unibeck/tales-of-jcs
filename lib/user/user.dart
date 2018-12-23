class User {

  String name;
  String email;
  String photoUrl;

  User(this.name, this.email, this.photoUrl);

  User.fromJson(Map<String, dynamic> json):
        name = json['name'],
        email = json['email'],
        photoUrl = json['photoUrl'];

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
      };
}