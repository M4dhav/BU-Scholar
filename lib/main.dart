import 'package:flutter/material.dart';
import 'home_page.dart';
import 'privacy_policy.dart';
import 'widgets/pdf_viewer.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  setUrlStrategy(PathUrlStrategy());
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BU Scholar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        cardTheme: const CardTheme(surfaceTintColor: Colors.white),
      ),
      initialRoute: '/',
      routes: {
        '/':
            (context) => const HomePage(title: 'Previous Year Question Papers'),
        '/pdf_viewer': (context) => const PdfViewer(),
        '/privacy-policy': (context) => const PrivacyPolicyPage(),
      },
    );
  }
}
