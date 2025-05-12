import 'package:flutter/material.dart';

class PaperButton extends StatelessWidget {
  final String label;
  final String url;

  const PaperButton({super.key, required this.label, required this.url});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // Use named route navigation with arguments to hide the URL from the address bar
        Navigator.pushNamed(context, '/pdf_viewer', arguments: url);
      },
      icon: const Icon(Icons.picture_as_pdf, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
