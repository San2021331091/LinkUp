import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

class LinkUpAIView extends StatefulWidget {
  const LinkUpAIView({super.key});

  @override
  State<LinkUpAIView> createState() => _LinkUpAIViewState();
}

class _LinkUpAIViewState extends State<LinkUpAIView> {
  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    await Permission.microphone.request();
    await Permission.camera.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Chat")),
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri("https://linkupai-qabp4f.ai.copilot.live"),
          ),
          onPermissionRequest: (controller, request) async {
            return PermissionResponse(
              resources: request.resources,
              action: PermissionResponseAction.GRANT,
            );
          },

          onWebViewCreated: (controller) {
            webViewController = controller;
          },

          onLoadStop: (controller, url) async {
            await controller.evaluateJavascript(source: '''
              document.body.style.overflow = 'auto';
              document.body.style.webkitOverflowScrolling = 'touch';
            ''');
          },
        ),
      ),
    );
  }
}