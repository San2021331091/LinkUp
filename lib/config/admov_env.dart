import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdMovEnv {
  static String get bannerId => dotenv.env['ADMOB_BANNER_ID'] ?? '';
  static String get interstitialId => dotenv.env['ADMOB_INTERSTITIAL_ID'] ?? '';
  static String get rewardedId => dotenv.env['ADMOB_REWARDED_ID'] ?? '';
  static String get appId => dotenv.env['ADMOB_APP_ID'] ?? '';

}