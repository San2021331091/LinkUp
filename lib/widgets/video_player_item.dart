import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl; // optional thumbnail

  const VideoPlayerItem({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
  });

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  VideoPlayerController? controller;
  bool isPlaying = false;
  bool isInitialized = false;

  void _initializeAndPlay() async {
    controller = VideoPlayerController.network(widget.videoUrl);
    await controller!.initialize();
    controller!.setLooping(true);
    controller!.play();

    if (mounted) {
      setState(() {
        isPlaying = true;
        isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isPlaying) {
          _initializeAndPlay();
        } else {
          // toggle play/pause if video already playing
          if (controller!.value.isPlaying) {
            controller!.pause();
          } else {
            controller!.play();
          }
          setState(() {});
        }
      },
      child: SizedBox.expand(
        child: isPlaying && controller != null && controller!.value.isInitialized
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller!.value.size.width,
                  height: controller!.value.size.height,
                  child: VideoPlayer(controller!),
                ),
              )
            : widget.thumbnailUrl != null
                ? Image.network(
                    widget.thumbnailUrl!,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.black,
                    child: const Center(
                      child: Icon(Icons.play_arrow, color: Colors.white, size: 40),
                    ),
                  ),
      ),
    );
  }
}