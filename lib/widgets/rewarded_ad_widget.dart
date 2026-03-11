import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vibely/config/admov_env.dart';

class RewardedAdWidget {
  static RewardedAd? _rewardedAd;

  static void loadAd() {
    RewardedAd.load(
      adUnitId: AdMovEnv.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          Get.snackbar("Successful", "✅ Rewarded loaded");
        },
        onAdFailedToLoad: (error) {
          Get.snackbar("Error!", "❌ Rewarded failed: $error");
        },
      ),
    );
  }

  static void showAd(Function onReward) {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          Get.snackbar("Reward", "🎁 User earned reward!");
          onReward();
        },
      );

      _rewardedAd = null;
      loadAd();
    } else {
      Get.snackbar("Ad", "Rewarded not ready");
    }
  }
}