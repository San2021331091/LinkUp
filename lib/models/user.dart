class User {
  final String? name, uid, image, email, youtube, facebook, twitter, instagram;
  // ignore: non_constant_identifier_names
  final int? followers_count;
  final List<String>? following;

  User({
    this.name,
    this.uid,
    this.image,
    this.email,
    this.youtube,
    this.facebook,
    this.twitter,
    this.instagram,
    // ignore: non_constant_identifier_names
    this.followers_count,
    this.following,
  });

  // Create User from row data / JSON
  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      name: data["name"] as String?,
      uid: data["uid"] as String?,
      image: data["image"] as String?,
      email: data["email"] as String?,
      youtube: data["youtube"] as String?,
      facebook: data["facebook"] as String?,
      twitter: data["twitter"] as String?,
      instagram: data["instagram"] as String?,
      followers_count: data["followers_count"] as int?,
      following: (data["following"] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  // Convert User object to JSON
  Map<String, dynamic> toJson() => {
        "name": name,
        "uid": uid,
        "image": image,
        "email": email,
        "youtube": youtube,
        "facebook": facebook,
        "twitter": twitter,
        "instagram": instagram,
        "followers_count": followers_count,
        "following": following,
      };
}