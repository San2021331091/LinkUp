import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibely/models/comment.dart';
import 'package:vibely/models/user.dart';
import 'package:vibely/authentication/supabase_auth.dart';
import 'package:vibely/controller/video_feed_controller.dart';
import 'package:uuid/uuid.dart';

class CommentController extends GetxController {
  final supabase = SupabaseAuth.supabase;

  /// List of comments for current video
  var comments = <Comment>[].obs;

  /// Loading state
  var isLoading = false.obs;

  /// Map userId -> User to cache
  final RxMap<String, User> userCache = <String, User>{}.obs;

  /// Fetch comments for a video and cache users
  Future<void> fetchComments(String videoId) async {
    try {
      isLoading.value = true;

      final response = await supabase
          .from('comments')
          .select()
          .eq('video_id', videoId)
          .order('created_at', ascending: true);

      final fetchedComments = (response as List)
          .map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList();

      comments.value = fetchedComments;

      // Fetch users for each comment
      for (var c in fetchedComments) {
        if (!userCache.containsKey(c.userId)) {
          final userRes = await supabase
              .from('users')
              .select()
              .eq('uid', c.userId)
              .maybeSingle();
          if (userRes != null) {
            userCache[c.userId] = User.fromMap(userRes);
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching comments: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Add a new comment
  Future<void> addComment({
    required String videoId,
    required String userId,
    required String text,
  }) async {
    final newComment = Comment(
      id: const Uuid().v4(),
      videoId: videoId,
      userId: userId,
      commentText: text,
      createdAt: DateTime.now(),
    );

    try {
      // Insert comment into Supabase
      final inserted = await supabase
          .from('comments')
          .insert(newComment.toJson())
          .select()
          .maybeSingle();

      // Use server version if available
      final commentToAdd = inserted != null
          ? Comment.fromJson(inserted)
          : newComment;

      comments.add(commentToAdd);

      // Ensure the user is cached
      if (!userCache.containsKey(userId)) {
        final userRes = await supabase
            .from('users')
            .select()
            .eq('uid', userId)
            .maybeSingle();
        if (userRes != null) {
          userCache[userId] = User.fromMap(userRes);
        }
      }

      // Increment video comment count
      if (Get.isRegistered<VideoFeedController>()) {
        final videoController = Get.find<VideoFeedController>();
        await videoController.incrementCommentsCount(videoId);
      }

      
    } catch (e) {
      debugPrint("Error adding comment: $e");
    }
  }

  /// Edit comment (only owner)
  Future<void> editComment({
    required String commentId,
    required String newText,
  }) async {
    try {
      await supabase
          .from('comments')
          .update({'comment_text': newText})
          .eq('id', commentId);

      final index = comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        final updated = comments[index].copyWith(commentText: newText);
        comments[index] = updated;
        comments.refresh();
      }
    } catch (e) {
      debugPrint("Error editing comment: $e");
    }
  }

  /// Delete comment (only owner)
  Future<void> deleteComment({
    required String commentId,
  }) async {
    try {
      await supabase.from('comments').delete().eq('id', commentId);

      comments.removeWhere((c) => c.id == commentId);
      comments.refresh();
    } catch (e) {
      debugPrint("Error deleting comment: $e");
    }
  }

  /// Get cached user by id
  User? getUser(String userId) => userCache[userId];
}