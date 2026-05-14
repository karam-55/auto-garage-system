import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../core/constants/api_constants.dart';

class ApiDocsScreen extends StatefulWidget {
  const ApiDocsScreen({super.key});

  @override
  State<ApiDocsScreen> createState() => _ApiDocsScreenState();
}

class _ApiDocsScreenState extends State<ApiDocsScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        URLRequest(
          url: Uri.parse('${ApiConstants.baseUrl}/api-docs'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('توثيق API'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
