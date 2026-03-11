import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibely/authentication/supabase_auth.dart';
import 'package:vibely/controller/authentication_controller.dart';
import 'package:vibely/models/user.dart';
import 'package:vibely/models/video.dart';

class ProfileController extends GetxController {
  final String userId;

  ProfileController(this.userId);

  final user = Rxn<User>();
  final isLoading = true.obs;

  final followers = 0.obs;
  final likes = 0.obs;
  final videos = <Video>[].obs;

  final _authenticationController = Get.put(AuthenticationController());

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
  }

  /// LOAD EVERYTHING
  Future<void> fetchProfileData() async {
    isLoading.value = true;

    await Future.wait([fetchUser(), fetchVideos()]);

    calculateLikes();
    calculateFollowers();

    isLoading.value = false;
  }

  /// USER INFO
  Future<void> fetchUser() async {
    try {
      final data = await SupabaseAuth.supabase
          .from("users")
          .select()
          .eq("uid", userId)
          .single();

      user.value = User.fromMap(data);
    } catch (e) {
      debugPrint("fetchUser error: $e");
      user.value = null;
    }
  }

  /// VIDEOS
  Future<void> fetchVideos() async {
    try {
      final data = await SupabaseAuth.supabase
          .from("videos")
          .select()
          .eq("user_id", userId)
          .order("created_at", ascending: false);

      videos.value = (data as List).map((v) => Video.fromJson(v)).toList();
    } catch (e) {
      debugPrint("fetchVideos error: $e");
      videos.clear();
    }
  }

  /// CALCULATE TOTAL LIKES
  void calculateLikes() {
    int total = 0;
    for (var v in videos) {
      total += v.likesCount ?? 0;
    }
    likes.value = total;
  }

  /// CALCULATE FOLLOWERS
  void calculateFollowers() {
    followers.value = user.value?.followers_count ?? 0;
  }

  /// UPDATE PROFILE
  Future<void> updateProfile({
    required String name,
    required String image,
    required String facebook,
    required String instagram,
    required String twitter,
    required String youtube,
  }) async {
    try {
      await SupabaseAuth.supabase.from("users").update({
        "name": name,
        "image": image,
        "facebook": facebook,
        "instagram": instagram,
        "twitter": twitter,
        "youtube": youtube,
      }).eq("uid", userId);

      await fetchUser();
      calculateFollowers();
      Get.snackbar("Success", "Profile Updated");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// LOGOUT
  Future<void> signOut() async {
    await _authenticationController.logout();
  }
}