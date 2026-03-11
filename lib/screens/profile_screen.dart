import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibely/authentication/supabase_auth.dart';
import 'package:vibely/controller/profile_controller.dart';
import 'package:vibely/utils/url_opener.dart';
import 'package:vibely/widgets/video_player_item.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileController controller;
  late final String currentUserId;

  @override
  void initState() {
    super.initState();

    // Store logged-in UID separately
    currentUserId = SupabaseAuth.supabase.auth.currentUser?.id ?? "";

    // Remove any old controller with same tag
    if (Get.isRegistered<ProfileController>(tag: widget.userId)) {
      Get.delete<ProfileController>(tag: widget.userId);
    }

    controller = Get.put(ProfileController(widget.userId), tag: widget.userId);
  }

  @override
  void dispose() {
    Get.delete<ProfileController>(tag: widget.userId);
    super.dispose();
  }

  void _openEditModal() {
    final user = controller.user.value;
    if (user == null) return;

    final nameController = TextEditingController(text: user.name ?? '');
    final imageController = TextEditingController(text: user.image ?? '');
    final fbController = TextEditingController(text: user.facebook ?? '');
    final instaController = TextEditingController(text: user.instagram ?? '');
    final twController = TextEditingController(text: user.twitter ?? '');
    final ytController = TextEditingController(text: user.youtube ?? '');

    Get.dialog(
      AlertDialog(
        title: Text(
          "Edit Profile",
          style: GoogleFonts.acme(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField("Name", nameController),
              _buildTextField("Image URL", imageController),
              _buildTextField("Facebook", fbController),
              _buildTextField("Instagram", instaController),
              _buildTextField("Twitter", twController),
              _buildTextField("YouTube", ytController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: GoogleFonts.acme(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              controller.updateProfile(
                name: nameController.text,
                image: imageController.text,
                facebook: fbController.text,
                instagram: instaController.text,
                twitter: twController.text,
                youtube: ytController.text,
              );
              Get.back();
            },
            child: Text(
              "Save",
              style: GoogleFonts.acme(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final videoItemSize = (screenWidth - 8) / 3;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Profile",
          style: GoogleFonts.acme(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(onPressed: _openEditModal, icon: const Icon(Icons.edit)),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = controller.user.value;
        if (user == null) return const Center(child: Text("User not found"));

        final isMe = currentUserId == widget.userId;

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 45,
                backgroundImage: user.image != null
                    ? NetworkImage(user.image!)
                    : null,
                child: user.image == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              const SizedBox(height: 10),
              Text(
                "${user.name ?? "Username"}${isMe ? " (You)" : ""}",
                style: GoogleFonts.aBeeZee(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              /// COUNTS ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _countWidget("Followers", controller.followers.value),
                  const SizedBox(width: 25),
                  _countWidget("Likes", controller.likes.value),
                ],
              ),
              const SizedBox(height: 20),

              /// SOCIAL LINKS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton(
                    FontAwesomeIcons.facebook,
                    Colors.blue,
                    () => openLink(user.facebook),
                  ),
                  const SizedBox(width: 12),
                  _socialButton(
                    FontAwesomeIcons.instagram,
                    Colors.pink,
                    () => openLink(user.instagram),
                  ),
                  const SizedBox(width: 12),
                  _socialButton(
                    FontAwesomeIcons.twitter,
                    Colors.lightBlue,
                    () => openLink(user.twitter),
                  ),
                  const SizedBox(width: 12),
                  _socialButton(
                    FontAwesomeIcons.youtube,
                    Colors.red,
                    () => openLink(user.youtube),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              /// LOGOUT BUTTON
              if (isMe)
                ElevatedButton.icon(
                  onPressed: () {
                    controller.signOut();
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(
                    "Logout",
                    style: GoogleFonts.acme(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              /// VIDEO GRID
              Obx(() {
                if (controller.videos.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "No videos yet",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.videos.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),
                    itemBuilder: (context, index) {
                      final video = controller.videos[index];
                      return SizedBox(
                        width: videoItemSize,
                        height: videoItemSize,
                        child: VideoPlayerItem(
                          videoUrl: video.videoUrl ?? "",
                          thumbnailUrl: video.thumbnailUrl,
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _countWidget(String title, int value) {
    return Column(
      children: [
        Text(
          "$value",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _socialButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
