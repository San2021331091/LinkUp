import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:vibely/controller/upload_controller.dart';
import 'package:vibely/widgets/instertitial_widget.dart';
import 'package:vibely/widgets/rewarded_ad_widget.dart';
import 'package:video_player/video_player.dart';

class UploadForm extends StatefulWidget {
  final File videoFile;
  final String videoPath;

  const UploadForm({
    super.key,
    required this.videoFile,
    required this.videoPath,
  });

  @override
  State<UploadForm> createState() => _UploadFormState();
}

class _UploadFormState extends State<UploadForm> {
  VideoPlayerController? playerController;
  bool isVideoInitialized = false;
  bool isMuted = false;

  final TextEditingController artistSongTextEditingControler =
      TextEditingController();
  final TextEditingController descriptionTextEditingControler =
      TextEditingController();

  final UploadController uploadController = Get.put(UploadController());

  late ValueNotifier<double> progressNotifier;

  // Brand accent gradient reused across the screen.
  static const List<Color> _accentGradient = [
    Color(0xFF9C27B0), // purple
    Color(0xFF3D5AFE), // blue
    Color(0xFF00E5FF), // cyan
  ];

  @override
  void initState() {
    super.initState();
    InterstitialAdWidget.loadAd();
    RewardedAdWidget.loadAd();
    initializeVideo();

    progressNotifier = ValueNotifier(0);

    /// Listen to upload progress
    ever(uploadController.uploadProgress, (value) {
      progressNotifier.value = value * 100;
    });
  }

  Future<void> initializeVideo() async {
    playerController = VideoPlayerController.file(widget.videoFile);

    await playerController!.initialize();

    playerController!.setLooping(true);
    playerController!.setVolume(1);
    playerController!.play();

    setState(() {
      isVideoInitialized = true;
    });
  }

  void togglePlay() {
    if (!isVideoInitialized) return;
    setState(() {
      playerController!.value.isPlaying
          ? playerController!.pause()
          : playerController!.play();
    });
  }

  void toggleMute() {
    if (!isVideoInitialized) return;
    setState(() {
      isMuted = !isMuted;
      playerController!.setVolume(isMuted ? 0 : 1);
    });
  }

  @override
  void dispose() {
    playerController?.dispose();
    progressNotifier.dispose();
    artistSongTextEditingControler.dispose();
    descriptionTextEditingControler.dispose();
    super.dispose();
  }

  Future<void> _handleUpload() async {
    if (artistSongTextEditingControler.text.isNotEmpty &&
        descriptionTextEditingControler.text.isNotEmpty) {
      await uploadController.saveVideoInformationToSupabaseDatabase(
        artistSongName: artistSongTextEditingControler.text,
        descriptionTags: descriptionTextEditingControler.text,
        videoFilePath: widget.videoPath,
        context: context,
      );

      InterstitialAdWidget.showAd();
      RewardedAdWidget.showAd(() {
        Get.snackbar(
          "Reward Granted",
          "You watched an ad and got a reward!",
        );
      });
    } else {
      Get.snackbar(
        "Missing Fields",
        "Please enter artist/song and description",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white.withOpacity(0.08),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // UI PIECES
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          "New Video",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildVideoPreview(Size size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: SizedBox(
        height: size.height * 0.52,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Cover-cropped video
            if (isVideoInitialized)
              GestureDetector(
                onTap: togglePlay,
                child: FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: playerController!.value.size.width,
                    height: playerController!.value.size.height,
                    child: VideoPlayer(playerController!),
                  ),
                ),
              )
            else
              Container(
                color: const Color(0xFF16131F),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              ),

            // Bottom scrim for depth
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.35),
                    ],
                    stops: const [0.7, 1.0],
                  ),
                ),
              ),
            ),

            // Play / pause tap indicator
            if (isVideoInitialized && !playerController!.value.isPlaying)
              Center(
                child: Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),

            // Mute toggle
            Positioned(
              top: 14,
              right: 14,
              child: GestureDetector(
                onTap: toggleMute,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.40),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isMuted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            // "Preview" chip
            Positioned(
              bottom: 14,
              left: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 7,
                      width: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E5FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      "Preview",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        cursorColor: const Color(0xFF00E5FF),
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.55),
            fontSize: 14,
          ),
          floatingLabelStyle: GoogleFonts.poppins(
            color: const Color(0xFF00E5FF),
            fontSize: 14,
          ),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.25),
            fontSize: 13,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 6, right: 4),
            child: Icon(icon, color: const Color(0xFF9C27B0), size: 22),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: _accentGradient),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3D5AFE).withOpacity(0.45),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _handleUpload,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_upload_rounded,
                    color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  "Upload Now",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadForm(Size size) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Details",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          _buildModernField(
            controller: artistSongTextEditingControler,
            label: "Artist - Song",
            hint: "e.g. Drake - One Dance",
            icon: Icons.music_note_rounded,
          ),
          const SizedBox(height: 14),
          _buildModernField(
            controller: descriptionTextEditingControler,
            label: "Description & Tags",
            hint: "Write something... #viral #dance",
            icon: Icons.tag_rounded,
            maxLines: 3,
          ),
          const SizedBox(height: 22),
          _buildUploadButton(),
        ],
      ),
    );
  }

  Widget _buildUploadOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          color: Colors.black.withOpacity(0.55),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 34),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SimpleCircularProgressBar(
                    progressColors: _accentGradient,
                    size: 150,
                    backColor: Colors.white.withOpacity(0.08),
                    progressStrokeWidth: 12,
                    backStrokeWidth: 12,
                    valueNotifier: progressNotifier,
                  ),
                  const SizedBox(height: 26),
                  Obx(() {
                    if (uploadController.uploadProgress.value == 0) {
                      return Text(
                        "Compressing video...",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }
                    return Text(
                      "Uploading ${(uploadController.uploadProgress.value * 100).toStringAsFixed(0)}%",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }),
                  const SizedBox(height: 6),
                  Text(
                    "Please keep the app open",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF071233),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E40AF), // vivid blue
              Color(0xFF0B2A6B), // deep blue
              Color(0xFF071233), // near-navy
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 18),
                    _buildVideoPreview(size),
                    const SizedBox(height: 22),
                    _buildUploadForm(size),
                  ],
                ),
              ),

              /// Full-screen blurred progress overlay while uploading
              Obx(() {
                if (uploadController.isUploading.value) {
                  return _buildUploadOverlay();
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }
}