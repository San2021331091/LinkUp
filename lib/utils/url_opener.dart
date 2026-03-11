import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> openLink(String? url) async {
  if (url == null || url.trim().isEmpty) {
    Get.snackbar("Invalid URL", "No link available");
    return;
  }

  url = url.trim();

  // Make sure the URL has a scheme
  if (!url.startsWith("http://") && !url.startsWith("https://")) {
    url = "https://$url";
  }

  try {

    await launchUrlString(
      url,
      mode: LaunchMode.externalApplication,
    );
  } catch (e) {
    Get.snackbar("Error", "Cannot open URL: $e");
  }
}
