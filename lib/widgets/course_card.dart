import 'package:flutter/material.dart';
import '../utils/string_extensions.dart';
import 'paper_button.dart';

class CourseCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const CourseCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final courseName = data['course_name']
        .toString()
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.capitalize())
        .join(' ');

    final courseCode = data['course_code'].toString().toUpperCase();
    final List<Map<String, String>> papers =
        (data['papers'] as List<dynamic>?)
            ?.cast<Map<String, String>>() ??
        [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate responsive sizes based on card width
          final cardWidth = constraints.maxWidth;
          
          // Responsive padding (3-5% of card width)
          final padding = (cardWidth * 0.04).clamp(12.0, 20.0);
          
          // Available width after padding
          final availableWidth = cardWidth - (padding * 2);
          
          // Responsive font sizes
          final titleFontSize = (cardWidth * 0.045).clamp(14.0, 20.0);
          final codeFontSize = (cardWidth * 0.03).clamp(11.0, 14.0);
          final buttonFontSize = (cardWidth * 0.032).clamp(11.0, 13.0);
          
          // Responsive spacing
          final titleCodeSpacing = (cardWidth * 0.01).clamp(2.0, 5.0);
          final codeButtonSpacing = (cardWidth * 0.02).clamp(6.0, 12.0);
          
          // Responsive button height
          final buttonHeight = (cardWidth * 0.08).clamp(30.0, 40.0);
          
          // Button width calculation
          final buttonWidth = papers.isNotEmpty
              ? (availableWidth / papers.length.clamp(1, 3)) - 8
              : availableWidth;
          
          return Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    courseName,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: titleCodeSpacing),
                Text(
                  courseCode,
                  style: TextStyle(
                    fontSize: codeFontSize,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: codeButtonSpacing),
                // Use SingleChildScrollView with horizontal scroll to prevent overflow
                if (papers.isNotEmpty)
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: papers.map((paper) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: SizedBox(
                              width: buttonWidth,
                              height: buttonHeight,
                              child: PaperButton(
                                label: paper['label'] ?? 'Paper',
                                url: paper['url'] ?? '',
                                fontSize: buttonFontSize,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: padding * 0.25),
                    child: Text(
                      'No papers available',
                      style: TextStyle(
                        fontSize: codeFontSize * 0.9,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
