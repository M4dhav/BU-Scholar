import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubService {
  final String owner = 'm4dhav';
  final String repo = 'bu-scholar';
  final String pyqsPath = 'pyqs';
  final String baseUrl = 'https://api.github.com';

  Future<List<Map<String, dynamic>>> fetchCourses() async {
    try {
      // Get the contents of the pyqs folder
      final response = await http.get(
        Uri.parse('$baseUrl/repos/$owner/$repo/contents/$pyqsPath'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode == 404) {
        // If pyqs folder doesn't exist, return mock data for now
        return _getMockCourses();
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch pyqs folder: ${response.statusCode}');
      }

      final List<dynamic> contents = json.decode(response.body);
      List<Map<String, dynamic>> courses = [];

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

          courses.add({
            'course_name': courseName,
            'course_code': courseCode,
            'mid_paper': papers['mid_paper'],
            'end_paper': papers['end_paper'],
            'description':
                '$courseName ($courseCode)', // For search functionality
          });
        }
      }

      return courses;
    } catch (e) {
      // Fallback to mock data if there's any error
      print('Error fetching courses from GitHub: $e');
      return _getMockCourses();
    }
  }

  List<Map<String, dynamic>> _getMockCourses() {
    // Return some mock data for testing until the pyqs folder structure is created
    return [
      {
        'course_name': 'Computer Science Fundamentals',
        'course_code': 'CSF111',
        'mid_paper': true,
        'end_paper': true,
        'description': 'Computer Science Fundamentals (CSF111)',
      },
      {
        'course_name': 'Data Structures and Algorithms',
        'course_code': 'CSF211',
        'mid_paper': true,
        'end_paper': false,
        'description': 'Data Structures and Algorithms (CSF211)',
      },
      {
        'course_name': 'Operating Systems',
        'course_code': 'CSF372',
        'mid_paper': false,
        'end_paper': true,
        'description': 'Operating Systems (CSF372)',
      },
      {
        'course_name': 'Database Management Systems',
        'course_code': 'CSF212',
        'mid_paper': true,
        'end_paper': true,
        'description': 'Database Management Systems (CSF212)',
      },
      {
        'course_name': 'Software Engineering',
        'course_code': 'CSF314',
        'mid_paper': true,
        'end_paper': false,
        'description': 'Software Engineering (CSF314)',
      },
    ];
  }

  Future<Map<String, bool>> _fetchPapersInCourse(
    String courseFolderName,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/repos/$owner/$repo/contents/$pyqsPath/$courseFolderName',
        ),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode != 200) {
        return {'mid_paper': false, 'end_paper': false};
      }

      final List<dynamic> contents = json.decode(response.body);

      bool hasMidPaper = false;
      bool hasEndPaper = false;

      for (final item in contents) {
        final fileName = (item['name'] as String).toLowerCase();
        if (fileName.contains('mid_semester') ||
            fileName.contains('mid-semester')) {
          hasMidPaper = true;
        } else if (fileName.contains('end_semester') ||
            fileName.contains('end-semester')) {
          hasEndPaper = true;
        }
      }

      return {'mid_paper': hasMidPaper, 'end_paper': hasEndPaper};
    } catch (e) {
      return {'mid_paper': false, 'end_paper': false};
    }
  }

  String getPaperUrl(String courseCode, String paperType) {
    // paperType should be 'mid' or 'end'
    final fileName = paperType == 'mid' ? 'mid_semester' : 'end_semester';

    // Find the course folder name that contains this course code
    // For now, we'll construct a generic URL - this will need to be enhanced
    // to find the exact filename with extension
    return 'https://raw.githubusercontent.com/$owner/$repo/main/$pyqsPath/${courseCode.toLowerCase()}_${courseCode.toUpperCase()}/${fileName}.pdf';
  }

  Future<String> findExactPaperUrl(String courseCode, String paperType) async {
    try {
      // First, find the course folder
      final coursesResponse = await http.get(
        Uri.parse('$baseUrl/repos/$owner/$repo/contents/$pyqsPath'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
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

      // Get files in the course folder
      final filesResponse = await http.get(
        Uri.parse(
          '$baseUrl/repos/$owner/$repo/contents/$pyqsPath/$targetFolder',
        ),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (filesResponse.statusCode != 200) {
        throw Exception('Failed to fetch course files');
      }

      final List<dynamic> files = json.decode(filesResponse.body);

      // Find the paper file
      final searchTerm = paperType == 'mid' ? 'mid_semester' : 'end_semester';
      for (final file in files) {
        final fileName = (file['name'] as String).toLowerCase();
        if (fileName.contains(searchTerm)) {
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
