import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibely/controller/video_feed_controller.dart';
import 'package:vibely/widgets/instertitial_widget.dart';
import 'package:vibely/widgets/rewarded_ad_widget.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  final String videoId;
  final String? thumbnailUrl;

  const VideoPlayerItem({
    super.key,
    required this.videoUrl,
    required this.videoId,
    this.thumbnailUrl,
  });

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController controller;

  bool isInitialized = false;
  bool adShownForThisVideo = false;
  bool viewTracked = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    await controller.initialize();
    await controller.setLooping(false);

    controller.addListener(_videoListener);

    await controller.play();

    if (mounted) {
      setState(() {
        isInitialized = true;
      });
    }
  }

  void _videoListener() {
    if (!controller.value.isInitialized) return;

    final position = controller.value.position;
    final duration = controller.value.duration;

    /// Count view after 3 seconds watched
    if (!viewTracked && position.inSeconds >= 3) {
      viewTracked = true;

      Get.find<VideoFeedController>().incrementView(widget.videoId);

      debugPrint("VIEW COUNTED: ${widget.videoId}");
    }

    /// Show ads when video finishes
    if (!adShownForThisVideo &&
        duration.inMilliseconds > 0 &&
        position >= duration) {
      adShownForThisVideo = true;

      InterstitialAdWidget.loadAd();
      RewardedAdWidget.loadAd();
    }
  }

  @override
  void dispose() {
    controller.removeListener(_videoListener);
    controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isInitialized ? _togglePlayPause : null,
      child: SizedBox.expand(
        child: isInitialized
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              )
            : (widget.thumbnailUrl != null
                ? Image.network(
                    widget.thumbnailUrl!,
                    fit: BoxFit.cover,
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  )),
      ),
    );
  }
}