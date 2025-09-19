import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewer extends StatelessWidget {
  const PdfViewer({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the URL from route arguments
    final String url =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Document Viewer'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.download)),
          ],
        ),
        body:
            url.isNotEmpty
                ? SfPdfViewer.network(url)
                : const Center(child: Text('No document URL provided')),
      ),
    );
  }
}
