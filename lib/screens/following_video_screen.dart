import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibely/controller/comment_controller.dart';
import 'package:vibely/controller/video_feed_controller.dart';
import 'package:vibely/widgets/follow_button.dart';
import 'package:vibely/widgets/profile_icon.dart';
import 'package:vibely/widgets/video_player_item.dart';
import 'package:vibely/widgets/comment_sheet.dart';
import 'package:vibely/authentication/supabase_auth.dart';

class FollowingVideoScreen extends StatelessWidget {
  FollowingVideoScreen({super.key});

  final VideoFeedController controller = Get.put(VideoFeedController());
  final String currentUserId = SupabaseAuth.supabase.auth.currentUser?.id ?? "";

  @override
  Widget build(BuildContext context) {
    Get.put(CommentController(), permanent: true);

    /// fetch once after widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchFollowingVideos();
    });

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.videos.isEmpty) {
          return const Center(
            child: Text(
              "No videos from followed users",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: controller.videos.length,
          itemBuilder: (context, index) {
            final video = controller.videos[index];

            return Stack(
              children: [
                /// Video
                VideoPlayerItem(
                  videoUrl: video.videoUrl ?? "",
                  videoId: video.id ?? "",
                ),

                /// Top title
                const Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "Following",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                /// Right actions
                Positioned(
                  right: 10,
                  bottom: 120,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (video.userId != null && video.userId!.isNotEmpty) ...[
                        ProfileIcon(userId: video.userId!, size: 50),
                        const SizedBox(height: 20),

                        if (video.userId != currentUserId)
                          FollowButton(
                            targetUserId: video.userId!,
                            currentUserId: currentUserId,
                          ),

                        const SizedBox(height: 20),
                      ],

                      /// Like
                      IconButton(
                        onPressed: video.id == null
                            ? null
                            : () => controller.toggleLike(video.id!, index),
                        icon: Obx(() {
                          final isLiked =
                              video.id != null && controller.isLiked(video.id!);

                          return Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.white,
                            size: 35,
                          );
                        }),
                      ),

                      /// Like count
                      Obx(
                        () => Text(
                          "${controller.videos[index].likesCount ?? 0}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// Comment
                      IconButton(
                        onPressed: video.id == null
                            ? null
                            : () {
                                Get.bottomSheet(
                                  CommentSheet(
                                    videoId: video.id!,
                                    userId: currentUserId,
                                  ),
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                );
                              },
                        icon: const Icon(
                          Icons.comment,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),

                      /// Comment count
                      Obx(
                        () => Text(
                          "${controller.videos[index].commentsCount ?? 0}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Column(
                        children: [
                          const Icon(
                            Icons.remove_red_eye,
                            color: Colors.white,
                            size: 35,
                          ),
                          Obx(() {
                            final updatedVideo = controller.videos[index];

                            return Text(
                              "${updatedVideo.viewsCount ?? 0}",
                              style: const TextStyle(color: Colors.white),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 20),

                      /// Share
                      IconButton(
                        onPressed: () {
                          if (video.videoUrl != null &&
                              video.videoUrl!.isNotEmpty) {
                            SharePlus.instance.share(
                              ShareParams(
                                text:
                          '''
                          🌟 Enjoy this video!
                          🎬 Watch Now
                          ${video.videoUrl}
                          ──────────────────
                          Thanks for using Linkup ❤️ 
                          ──────────────────
                          ''',
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ],
                  ),
                ),

                /// Caption
                Positioned(
                  bottom: 40,
                  left: 12,
                  right: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.artistSongName ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        video.descriptionTags ?? "",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }
}
