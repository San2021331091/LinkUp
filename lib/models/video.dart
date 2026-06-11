class Video {
  final String? id;
  final String? artistSongName;
  final String? descriptionTags;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? userId;
  final int? likesCount;
  final int? commentsCount;
  final int? viewsCount;
  final DateTime? createdAt;

  Video({
    this.id,
    this.artistSongName,
    this.descriptionTags,
    this.videoUrl,
    this.thumbnailUrl,
    this.userId,
    this.likesCount,
    this.commentsCount,
    this.viewsCount,
    this.createdAt,
  });

  /// Convert Supabase JSON → Dart Object
  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id']?.toString(),
      artistSongName: json['artist_song_name'] ?? '',
      descriptionTags: json['description_tags'] ?? '',
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      userId: json['user_id'] ?? '',
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      viewsCount: json['views_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "artist_song_name": artistSongName,
      "description_tags": descriptionTags,
      "video_url": videoUrl,
      "thumbnail_url": thumbnailUrl,
      "user_id": userId,
      "likes_count": likesCount,
      "comments_count": commentsCount,
      "views_count": viewsCount,
      "created_at": createdAt?.toIso8601String(),
    };
  }

  Video copyWith({
    String? id,
    String? artistSongName,
    String? descriptionTags,
    String? videoUrl,
    String? thumbnailUrl,
    String? userId,
    int? likesCount,
    int? commentsCount,
    int? viewsCount,
    DateTime? createdAt,
  }) {
    return Video(
      id: id ?? this.id,
      artistSongName: artistSongName ?? this.artistSongName,
      descriptionTags: descriptionTags ?? this.descriptionTags,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      userId: userId ?? this.userId,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      viewsCount: viewsCount ?? this.viewsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}