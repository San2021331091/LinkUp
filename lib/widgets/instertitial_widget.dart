import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vibely/config/admov_env.dart';

class InterstitialAdWidget {
  static InterstitialAd? _interstitialAd;

  static void loadAd() {
    InterstitialAd.load(
      adUnitId: AdMovEnv.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          Get.snackbar("Successful", "✅ Interstitial loaded");
        },
        onAdFailedToLoad: (error) {
          Get.snackbar("Error!", "❌ Interstitial failed: $error");
        },
      ),
    );
  }

  static void showAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      Get.snackbar("Ad", "🎬 Interstitial shown");

      _interstitialAd = null;
      loadAd(); // preload next ad
    } else {
      Get.snackbar("Ad", "Interstitial not ready");
    }
  }
}