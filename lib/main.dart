import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        title: 'BU Scholar',
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
        home: const BUPYQWebViewPage(),
      ),
    );
  }
}

class BUPYQWebViewPage extends StatefulWidget {
  const BUPYQWebViewPage({super.key});

  @override
  State<BUPYQWebViewPage> createState() => _BUPYQWebViewPageState();
}

class _BUPYQWebViewPageState extends State<BUPYQWebViewPage> {
  WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse('https://bupyq.m4dhav.dev'));
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: WebViewWidget(controller: controller));
  }
}
