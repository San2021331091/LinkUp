class MemberEarnings {
  final String? videoId;
  final String? userId;
  final double? likesEarning;
  final double? commentsEarning;
  final double? totalEarning;
  final DateTime? updatedAt;

  MemberEarnings({
    this.videoId,
    this.userId,
    this.likesEarning,
    this.commentsEarning,
    this.totalEarning,
    this.updatedAt,
  });

  /// Convert Supabase JSON → Dart Object
  factory MemberEarnings.fromJson(Map<String, dynamic> json) {
    return MemberEarnings(
      videoId: json['video_id'],
      userId: json['user_id'],
      likesEarning: (json['likes_earning'] ?? 0).toDouble(),
      commentsEarning: (json['comments_earning'] ?? 0).toDouble(),
      totalEarning: (json['total_earning'] ?? 0).toDouble(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// Convert Dart Object → JSON for Supabase insert/update
  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'user_id': userId,
      'likes_earning': likesEarning,
      'comments_earning': commentsEarning,
      'total_earning': totalEarning,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}