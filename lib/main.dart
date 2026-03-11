import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vibely/controller/authentication_controller.dart';
import 'package:vibely/authentication/supabase_auth.dart';
import 'package:vibely/app.dart';
   
Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");

    // Initialize AdMob
    await MobileAds.instance.initialize();

    // Register controller
    Get.put(AuthenticationController());

    // Initialize Supabase
    await SupabaseAuth.initialize();

    runApp(const MyApp());

  } on FileSystemException catch (e) {
    debugPrint(e.toString());
  }
}