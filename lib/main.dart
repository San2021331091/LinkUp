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
    await dotenv.load(fileName: ".env");

    await MobileAds.instance.initialize();

    Get.put(AuthenticationController());

    await SupabaseAuth.initialize();

  } catch (e, stack) {
    debugPrint("🔥 INIT ERROR: $e");
    debugPrint(stack.toString());
  }

  runApp(const MyApp());
}