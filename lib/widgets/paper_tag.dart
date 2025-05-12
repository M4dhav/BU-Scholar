import 'package:flutter/material.dart';

class PaperTag extends StatelessWidget {
  final String label;

  const PaperTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      shape: StadiumBorder(),
      elevation: 1,
    );
  }
}
