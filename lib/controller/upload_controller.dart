import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:vibely/authentication/supabase_auth.dart';
import 'package:vibely/models/video.dart';
import 'package:vibely/screens/home_screen.dart';
import 'package:vibely/utils/img_upload.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UploadController extends GetxController {
  RxBool isUploading = false.obs;
  RxDouble uploadProgress = 0.0.obs;

  final int maxVideoSizeMB = 50;

  final dio.Dio _dio = dio.Dio();

  /// PROGRESS SIMULATION
  void simulateProgress() async {
    while (isUploading.value && uploadProgress.value < 0.9) {
      await Future.delayed(const Duration(milliseconds: 400));

      uploadProgress.value += 0.03;

      if (uploadProgress.value > 0.9) {
        uploadProgress.value = 0.9;
      }
    }
  }

  /// COMPRESS VIDEO
  Future<File?> compressVideoFile(String videoFilePath) async {
    try {
      final compressedVideo = await VideoCompress.compressVideo(
        videoFilePath,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
      );

      if (compressedVideo == null || compressedVideo.file == null) {
        throw Exception("Video compression failed");
      }

      final file = compressedVideo.file!;
      final fileSizeMB = await file.length() ~/ (1024 * 1024);

      if (fileSizeMB > maxVideoSizeMB) {
        throw Exception("Video too large (max $maxVideoSizeMB MB)");
      }

      return file;
    } catch (e) {
      throw Exception("Video compression error: $e");
    }
  }

  /// GENERATE THUMBNAIL
  Future<File?> getThumbNailImage(String videoFilePath) async {
    try {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoFilePath,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
      );

      if (thumbnailPath == null) {
        throw Exception("Thumbnail generation failed");
      }

      final file = File(thumbnailPath);

      if (!await file.exists()) {
        throw Exception("Thumbnail file not found");
      }

      return file;
    } catch (e) {
      throw Exception("Thumbnail error: $e");
    }
  }

  /// CLOUDINARY CREDENTIALS
  Map<String, String> _getCloudinaryCredentials() {
    final cloudinaryUrl = dotenv.env['CLOUDINARY_URL'];

    if (cloudinaryUrl == null || cloudinaryUrl.isEmpty) {
      throw Exception("CLOUDINARY_URL missing in .env");
    }

    final uri = Uri.parse(cloudinaryUrl);
    final userInfo = uri.userInfo.split(':');

    if (userInfo.length != 2 || uri.host.isEmpty) {
      throw Exception("Invalid CLOUDINARY_URL format");
    }

    return {
      "apiKey": userInfo[0],
      "apiSecret": userInfo[1],
      "cloudName": uri.host,
    };
  }

  /// UPLOAD TO CLOUDINARY
  Future<String> uploadVideoToCloudinary({
    required File file,
    required String videoId,
  }) async {
    try {
      final creds = _getCloudinaryCredentials();

      final apiKey = creds["apiKey"]!;
      final apiSecret = creds["apiSecret"]!;
      final cloudName = creds["cloudName"]!;

      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final publicId = videoId;

      final paramsToSign =
          "public_id=$publicId&timestamp=$timestamp";

      final signature = sha1
          .convert(utf8.encode(paramsToSign + apiSecret))
          .toString();

      final formData = dio.FormData.fromMap({
        "file": await dio.MultipartFile.fromFile(
          file.path,
          filename: "$videoId.mp4",
        ),
        "api_key": apiKey,
        "timestamp": timestamp.toString(),
        "public_id": publicId,
        "signature": signature,
      });

      final response = await _dio.post(
        "https://api.cloudinary.com/v1_1/$cloudName/video/upload",
        data: formData,
        options: dio.Options(contentType: "multipart/form-data"),
      );

      final secureUrl = response.data["secure_url"];

      if (secureUrl == null) {
        throw Exception("Cloudinary did not return secure_url");
      }

      return secureUrl as String;
    } on dio.DioException catch (e) {
      throw Exception(
        "Cloudinary upload error: ${e.response?.data ?? e.message}",
      );
    } catch (e) {
      throw Exception("Cloudinary upload error: $e");
    }
  }

  /// UPLOAD VIDEO + THUMBNAIL
  Future<Map<String, String>> uploadVideoWithThumbnail(
    String videoID,
    String videoFilePath,
  ) async {
    try {
      final compressedVideo =
          await compressVideoFile(videoFilePath);

      final thumbnailFile =
          await getThumbNailImage(compressedVideo!.path);

      final videoUrl = await uploadVideoToCloudinary(
        file: compressedVideo,
        videoId: videoID,
      );

      final thumbnailUrl =
          await uploadImageToImgBB(thumbnailFile!);

      return {
        "videoUrl": videoUrl,
        "thumbnailUrl": thumbnailUrl!,
      };
    } catch (e) {
      throw Exception("Upload Flow Error: $e");
    }
  }

  /// SAVE TO SUPABASE
  Future<void> saveVideoInformationToSupabaseDatabase({
    required String artistSongName,
    required String descriptionTags,
    required String videoFilePath,
    required BuildContext context,
  }) async {
    uploadProgress.value = 0;
    isUploading.value = true;

    simulateProgress();

    try {
      final supabase = SupabaseAuth.supabase;
      const uuid = Uuid();
      final videoId = uuid.v4();

      final result =
          await uploadVideoWithThumbnail(videoId, videoFilePath);

      final videoUrl = result["videoUrl"];
      final thumbnailUrl = result["thumbnailUrl"];

      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      final video = Video(
        id: videoId,
        artistSongName: artistSongName,
        descriptionTags: descriptionTags,
        videoUrl: videoUrl!,
        thumbnailUrl: thumbnailUrl!,
        userId: user.id,
        likesCount: 0,
        commentsCount: 0,
        createdAt: DateTime.now(),
      );

      await supabase.from('videos').insert(video.toJson());

      uploadProgress.value = 1;

      Get.snackbar(
        "Success",
        "Video Uploaded Successfully",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      Get.offAll(() => const HomeScreen());
    } catch (e) {
      Get.snackbar(
        "Upload Failed",
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
      );
    } finally {
      isUploading.value = false;
    }
  }
}