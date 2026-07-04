import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibely/authentication/supabase_auth.dart' show SupabaseAuth;
import 'package:vibely/models/status.dart';

class StatusController extends GetxController {
  SupabaseClient get _supabase => SupabaseAuth.supabase;
  final dio.Dio _dio = dio.Dio();

  final RxList<StatusModel> statuses = <StatusModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs; // image upload state

  /// Current logged-in user id, or null.
  String? get currentUserId => _supabase.auth.currentUser?.id;

  @override
  void onInit() {
    super.onInit();
    fetchStatuses();
  }

  Future<void> fetchStatuses() async {
    try {
      isLoading.value = true;
      // `users(...)` embeds the related row via the user_id FK.
      final data = await _supabase
          .from('statuses')
          .select('*, users(uid, name, image)')
          .order('created_at', ascending: false);

      statuses.value =
          (data as List).map((e) => StatusModel.fromMap(e)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load statuses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Uploads a local image file to imgbb and returns the hosted URL,
  /// or null if the upload failed.
  Future<String?> uploadToImgbb(File imageFile) async {
    final apiKey = dotenv.env['IMG_BB_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      Get.snackbar('Error', 'IMG_BB_API_KEY missing in .env');
      return null;
    }

    try {
      isUploading.value = true;

      final fileName = imageFile.path.split('/').last;
      final formData = dio.FormData.fromMap({
        'image': await dio.MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        'https://api.imgbb.com/1/upload',
        queryParameters: {'key': apiKey},
        data: formData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // hosted image url
        return response.data['data']['url'] as String;
      } else {
        Get.snackbar('Error', 'Image upload failed');
        return null;
      }
    } on dio.DioException catch (e) {
      Get.snackbar('Error', 'Upload error: ${e.message}');
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Upload error: $e');
      return null;
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> createStatus({String? content, String? imageUrl}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'You must be logged in');
      return;
    }
    final hasText = content != null && content.trim().isNotEmpty;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    if (!hasText && !hasImage) {
      Get.snackbar('Error', 'Status cannot be empty');
      return;
    }
    try {
      await _supabase.from('statuses').insert({
        'user_id': user.id,
        'content': content,
        'image_url': imageUrl,
      });
      await fetchStatuses();
    } catch (e) {
      Get.snackbar('Error', 'Failed to post status: $e');
    }
  }

  Future<void> updateStatus({
    required String statusId,
    String? content,
    String? imageUrl,
  }) async {
    final hasText = content != null && content.trim().isNotEmpty;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    if (!hasText && !hasImage) {
      Get.snackbar('Error', 'Status cannot be empty');
      return;
    }
    try {
      await _supabase.from('statuses').update({
        'content': content,
        'image_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', statusId);
      await fetchStatuses();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: $e');
    }
  }

  Future<void> likeStatus(String statusId) async {
    final index = statuses.indexWhere((s) => s.id == statusId);
    if (index == -1) return;

    // optimistic UI update
    statuses[index] = statuses[index].copyWith(
      likesCount: statuses[index].likesCount + 1,
    );
    statuses.refresh();

    try {
      await _supabase.rpc(
        'increment_status_likes',
        params: {'status_id': statusId},
      );
    } catch (e) {
      // rollback on failure
      statuses[index] = statuses[index].copyWith(
        likesCount: statuses[index].likesCount - 1,
      );
      statuses.refresh();
      Get.snackbar('Error', 'Failed to like: $e');
    }
  }

  Future<void> deleteStatus(String statusId) async {
    try {
      await _supabase.from('statuses').delete().eq('id', statusId);
      statuses.removeWhere((s) => s.id == statusId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete: $e');
    }
  }
}