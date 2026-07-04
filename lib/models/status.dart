class StatusModel {
  final String id;
  final String userId;
  final String? content;
  final String? imageUrl;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final StatusUser? user;

  StatusModel({
    required this.id,
    required this.userId,
    this.content,
    this.imageUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory StatusModel.fromMap(Map<String, dynamic> map) {
    return StatusModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      content: map['content'] as String?,
      imageUrl: map['image_url'] as String?,
      likesCount: (map['likes_count'] as int?) ?? 0,
      commentsCount: (map['comments_count'] as int?) ?? 0,
      sharesCount: (map['shares_count'] as int?) ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      user: map['users'] != null
          ? StatusUser.fromMap(map['users'] as Map<String, dynamic>)
          : null,
    );
  }

  StatusModel copyWith({int? likesCount}) => StatusModel(
        id: id,
        userId: userId,
        content: content,
        imageUrl: imageUrl,
        likesCount: likesCount ?? this.likesCount,
        commentsCount: commentsCount,
        sharesCount: sharesCount,
        createdAt: createdAt,
        updatedAt: updatedAt,
        user: user,
      );
}

/// Lightweight user embedded from the `users` relation.
class StatusUser {
  final String uid;
  final String? name;
  final String? image;

  StatusUser({required this.uid, this.name, this.image});

  factory StatusUser.fromMap(Map<String, dynamic> map) => StatusUser(
        uid: map['uid'] as String,
        name: map['name'] as String?,
        image: map['image'] as String?,
      );
}