import 'dart:convert';
import 'package:http/http.dart' as http;
import 'services/github_auth_service.dart';

class GitHubService {
  final String owner = 'M4dhav';
  final String repo = 'BU-Scholar';
  final String pyqsPath = 'pyqs';
  final String baseUrl = 'https://api.github.com';
  final GitHubAuthService _authService = GitHubAuthService();

  /// Fetch courses progressively, yielding results as they're loaded
  Stream<Map<String, dynamic>> fetchCoursesStream() async* {
    try {
      // Get the contents of the pyqs folder using authenticated request
      final response = await _authService.authenticatedRequest(
        '$baseUrl/repos/$owner/$repo/contents/$pyqsPath',
      );

      if (response.statusCode == 404) {
        // If pyqs folder doesn't exist, return empty stream
        return;
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch pyqs folder: ${response.statusCode}');
      }

      final List<dynamic> contents = json.decode(response.body);

      // Filter for directories (course folders)
      final courseFolders =
          contents
              .where((item) => item['type'] == 'dir')
              .cast<Map<String, dynamic>>();

      for (final folder in courseFolders) {
        final folderName = folder['name'] as String;

        // Parse course name and code from folder name (format: course-name_coursecode)
        final parts = folderName.split('_');
        if (parts.length >= 2) {
          final courseName = parts[0].replaceAll('-', ' ');
          final courseCode = parts.sublist(1).join('_');

          // Get papers in this course folder
          final papers = await _fetchPapersInCourse(folderName);

          // Yield each course as soon as it's loaded
          yield {
            'course_name': courseName,
            'course_code': courseCode,
            'folder_name': folderName,
            'papers': papers, // Map of paper info
            'description':
                '$courseName ($courseCode)', // For search functionality
          };
        }
      }
    } catch (e) {
      throw Exception('Error fetching courses from GitHub: $e');
    }
  }

  /// Legacy method for backwards compatibility
  Future<List<Map<String, dynamic>>> fetchCourses() async {
    final courses = <Map<String, dynamic>>[];
    await for (final course in fetchCoursesStream()) {
      courses.add(course);
    }
    return courses;
  }

  /// Check if the last request was rate limited
  bool isLastRequestRateLimited(http.Response response) {
    return GitHubAuthService.isRateLimited(response);
  }

  /// Get rate limit information
  Map<String, String> getRateLimitInfo(http.Response response) {
    return GitHubAuthService.getRateLimitInfo(response);
  }

  Future<List<Map<String, String>>> _fetchPapersInCourse(
    String courseFolderName,
  ) async {
    try {
      final response = await _authService.authenticatedRequest(
        '$baseUrl/repos/$owner/$repo/contents/$pyqsPath/$courseFolderName',
      );

      if (response.statusCode != 200) {
        return [];
      }

      final List<dynamic> contents = json.decode(response.body);
      List<Map<String, String>> papers = [];

      for (final item in contents) {
        final fileName = (item['name'] as String).toLowerCase();
        final downloadUrl = item['download_url'] as String;

        // Extract paper type and year from filename (format: mid_2024.pdf or end_2025.pdf)
        final RegExp paperPattern = RegExp(r'^(mid|end)_(\d{4})\.pdf$');
        final match = paperPattern.firstMatch(fileName);

        if (match != null) {
          final paperType = match.group(1)!; // 'mid' or 'end'
          final year = match.group(2)!; // '2024', '2025', etc.

          papers.add({
            'type': paperType,
            'year': year,
            'url': downloadUrl,
            'label': '${paperType == 'mid' ? 'Mid' : 'End'} Sem $year',
          });
        }
      }

      // Sort papers by year (newest first) and then by type (mid before end)
      papers.sort((a, b) {
        final yearCompare = b['year']!.compareTo(a['year']!);
        if (yearCompare != 0) return yearCompare;
        return a['type']!.compareTo(b['type']!);
      });

      return papers;
    } catch (e) {
      return [];
    }
  }

  String getPaperUrl(String courseCode, String paperType) {
    // paperType should be 'mid' or 'end'
    final fileName = paperType == 'mid' ? 'mid_semester' : 'end_semester';

    // Find the course folder name that contains this course code
    // For now, we'll construct a generic URL - this will need to be enhanced
    // to find the exact filename with extension
    return 'https://raw.githubusercontent.com/$owner/$repo/main/$pyqsPath/${courseCode.toLowerCase()}_${courseCode.toUpperCase()}/$fileName.pdf';
  }

  Future<String> findExactPaperUrl(String courseCode, String paperType) async {
    try {
      // First, find the course folder using authenticated request
      final coursesResponse = await _authService.authenticatedRequest(
        '$baseUrl/repos/$owner/$repo/contents/$pyqsPath',
      );

      if (coursesResponse.statusCode != 200) {
        throw Exception('Failed to fetch course folders');
      }

      final List<dynamic> courseFolders = json.decode(coursesResponse.body);
      String? targetFolder;

      // Find the folder that ends with the course code
      for (final folder in courseFolders) {
        final folderName = folder['name'] as String;
        if (folderName.toLowerCase().endsWith('_${courseCode.toLowerCase()}')) {
          targetFolder = folderName;
          break;
        }
      }

      if (targetFolder == null) {
        throw Exception('Course folder not found for $courseCode');
      }

      // Get files in the course folder using authenticated request
      final filesResponse = await _authService.authenticatedRequest(
        '$baseUrl/repos/$owner/$repo/contents/$pyqsPath/$targetFolder',
      );

      if (filesResponse.statusCode != 200) {
        throw Exception('Failed to fetch course files');
      }

      final List<dynamic> files = json.decode(filesResponse.body);

      // Find the paper file
      final searchTerm = paperType == 'mid' ? 'mid' : 'end';
      for (final file in files) {
        final fileName = (file['name'] as String).toLowerCase();
        if (fileName.contains(searchTerm) &&
            (paperType == 'mid' ? !fileName.contains('end') : true)) {
          return file['download_url'] as String;
        }
      }

      throw Exception('Paper not found');
    } catch (e) {
      // Fallback to a sample PDF for demo purposes
      return 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
    }
  }
}
