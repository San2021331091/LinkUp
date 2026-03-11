import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibely/models/video.dart';
import 'package:vibely/models/user.dart';
import 'package:vibely/authentication/supabase_auth.dart';

class VideoFeedController extends GetxController {
  final supabase = SupabaseAuth.supabase;
  RxList<Video> videos = <Video>[].obs;
  RxBool isLoading = false.obs;
  RxSet<String> likedVideos = <String>{}.obs;

  /// Cache users
  RxMap<String, User> usersCache = <String, User>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVideos();
  }

  /// Fetch videos
  Future<void> fetchVideos() async {
    try {
      isLoading.value = true;

      final response = await supabase
          .from('videos')
          .select()
          .order('created_at', ascending: false);

      final videoList = (response as List)
          .map((e) => Video.fromJson(e))
          .toList();

      videos.assignAll(videoList);

      /// Prefetch users
      for (var video in videoList) {
        if (video.userId != null && !usersCache.containsKey(video.userId)) {
          getUser(video.userId!);
        }
      }
    } catch (e) {
      debugPrint("Video Fetch Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch user
  Future<User?> getUser(String uid) async {
    if (usersCache.containsKey(uid)) return usersCache[uid];

    try {
      final data = await supabase
          .from('users')
          .select()
          .eq('uid', uid)
          .maybeSingle();

      if (data == null) return null;

      final user = User.fromMap(data);
      usersCache[uid] = user;

      return user;
    } catch (e) {
      debugPrint("Error fetching user $uid: $e");
      return null;
    }
  }

  /// Like status
  bool isLiked(String videoId) => likedVideos.contains(videoId);

  /// Toggle like
  Future<void> toggleLike(String videoId, int index) async {
    final video = videos[index];
    int newLikes = video.likesCount ?? 0;

    if (likedVideos.contains(videoId)) {
      likedVideos.remove(videoId);
      newLikes = (newLikes - 1).clamp(0, 999999);
    } else {
      likedVideos.add(videoId);
      newLikes++;
    }

    videos[index] = video.copyWith(likesCount: newLikes);
    videos.refresh();

    try {
      await supabase
          .from('videos')
          .update({"likes_count": newLikes})
          .eq("id", videoId);
    } catch (e) {
      debugPrint("Error updating likes_count: $e");
    }
  }
  Future<void> fetchFollowingVideos() async {
  try {
    isLoading.value = true;

    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return;

    /// get current user
    final userData = await supabase
        .from('users')
        .select()
        .eq('uid', currentUser.id)
        .maybeSingle();

    if (userData == null) return;

    List following = userData['following'] ?? [];

    if (following.isEmpty) {
      videos.clear();
      return;
    }

    /// fetch videos only from followed users
    final response = await supabase
        .from('videos')
        .select()
        .inFilter('user_id', following)
        .order('created_at', ascending: false);

    final videoList =
        (response as List).map((e) => Video.fromJson(e)).toList();

    videos.assignAll(videoList);

    /// prefetch users
    for (var video in videoList) {
      if (video.userId != null && !usersCache.containsKey(video.userId)) {
        getUser(video.userId!);
      }
    }
  } catch (e) {
    debugPrint("Following Video Fetch Error: $e");
  } finally {
    isLoading.value = false;
  }
}

  /// Increment comments
  Future<void> incrementCommentsCount(String videoId) async {
    final index = videos.indexWhere((v) => v.id == videoId);
    if (index == -1) return;

    final video = videos[index];
    final newCount = (video.commentsCount ?? 0) + 1;

    videos[index] = video.copyWith(commentsCount: newCount);

    /// important
    videos.refresh();

    try {
      await supabase
          .from('videos')
          .update({"comments_count": newCount})
          .eq("id", videoId);
    } catch (e) {
      debugPrint("Error updating comments_count: $e");
    }
  }

  /// Decrement comments (when deleted)
  Future<void> decrementCommentsCount(String videoId) async {
    final index = videos.indexWhere((v) => v.id == videoId);
    if (index == -1) return;

    final video = videos[index];
    final newCount = (video.commentsCount ?? 0) - 1;

    videos[index] = video.copyWith(
      commentsCount: newCount.clamp(0, 999999),
    );

    videos.refresh();

    try {
      await supabase
          .from('videos')
          .update({"comments_count": newCount})
          .eq("id", videoId);
    } catch (e) {
      debugPrint("Error updating comments_count: $e");
    }
  }
}



extension VideoCopyWith on Video {
  Video copyWith({
    int? likesCount,
    int? commentsCount,
  }) {
    return Video(
      id: id,
      artistSongName: artistSongName,
      descriptionTags: descriptionTags,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      userId: userId,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt,
    );
  }
}