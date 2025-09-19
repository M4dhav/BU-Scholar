import '../github_service.dart';
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
    final gitHubService = GitHubService();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              courseName,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              courseCode,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              alignment: WrapAlignment.center,
              children: [
                if (data['mid_paper'] == true)
                  FutureBuilder<String>(
                    future: gitHubService.findExactPaperUrl(courseCode, 'mid'),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return PaperButton(
                          label: 'Mid Sem Paper',
                          url: snapshot.data!,
                        );
                      } else {
                        return PaperButton(
                          label: 'Mid Sem Paper',
                          url: gitHubService.getPaperUrl(courseCode, 'mid'),
                        );
                      }
                    },
                  ),
                if (data['end_paper'] == true)
                  FutureBuilder<String>(
                    future: gitHubService.findExactPaperUrl(courseCode, 'end'),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return PaperButton(
                          label: 'End Sem Paper',
                          url: snapshot.data!,
                        );
                      } else {
                        return PaperButton(
                          label: 'End Sem Paper',
                          url: gitHubService.getPaperUrl(courseCode, 'end'),
                        );
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
