import 'package:flutter/material.dart';

class PaperButton extends StatelessWidget {
  final String label;
  final String url;
  final double? fontSize;

  const PaperButton({
    super.key,
    required this.label,
    required this.url,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveFontSize = fontSize ?? 13.0;
    final iconSize = effectiveFontSize * 1.2;
    final borderRadius = effectiveFontSize * 1.5;
    final horizontalPadding = effectiveFontSize * 1.0;
    final verticalPadding = effectiveFontSize * 0.5;

    return ElevatedButton.icon(
      onPressed: () {
        // Use named route navigation with arguments to hide the URL from the address bar
        Navigator.pushNamed(context, '/pdf_viewer', arguments: url);
      },
      icon: Icon(Icons.picture_as_pdf, size: iconSize),
      label: Text(
        label,
        style: TextStyle(fontSize: effectiveFontSize),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
      ),
    );
  }
}
