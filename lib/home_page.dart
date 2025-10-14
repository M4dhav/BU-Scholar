import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/course_card.dart';
import 'github_service.dart';
import 'services/github_auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> filteredCourses = [];
  GitHubService gitHubService = GitHubService();
  GitHubAuthService authService = GitHubAuthService();
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool isLoading = true;
  bool isStreamComplete = false;
  double loadingProgress = 0.0;
  int totalCourses = 0;
  int loadedCourses = 0;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load courses
      await _loadCourses();
    });
  }

  Future<void> _loadCourses() async {
    setState(() {
      isLoading = true;
      isStreamComplete = false;
      loadingProgress = 0.0;
      loadedCourses = 0;
      courses.clear();
      filteredCourses.clear();
      errorMessage = null;
    });

    try {
      await for (final course in gitHubService.fetchCoursesStream()) {
        setState(() {
          courses.add(course);
          loadedCourses++;
          // Update filtered courses if no search query
          if (searchQuery.isEmpty) {
            filteredCourses = List.from(courses);
          } else {
            filterDocuments(searchQuery);
          }
          // Estimate progress (we don't know total count yet, so show indeterminate)
        });
      }

      setState(() {
        isStreamComplete = true;
        isLoading = false;
        loadingProgress = 1.0;
        totalCourses = courses.length;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load courses: ${e.toString()}';
        isLoading = false;
        isStreamComplete = true;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterDocuments(String query) {
    searchQuery = query;

    if (query.isEmpty) {
      setState(() {
        filteredCourses = List.from(courses);
      });
      return;
    }

    // Split the query into words for multi-word search
    final queryWords =
        query
            .toLowerCase()
            .split(' ')
            .where((word) => word.isNotEmpty)
            .toList();

    setState(() {
      filteredCourses =
          courses.where((course) {
            final courseName =
                (course['course_name'] ?? '').toString().toLowerCase();
            final courseCode =
                (course['course_code'] ?? '').toString().toLowerCase();
            final description =
                (course['description'] ?? '').toString().toLowerCase();

            // Check if ALL words in the query are found in at least one of the fields
            bool matchesAllWords = true;
            for (final word in queryWords) {
              // If none of the fields contain this word, this document doesn't match
              if (!courseName.contains(word) &&
                  !courseCode.contains(word) &&
                  !description.contains(word)) {
                matchesAllWords = false;
                break;
              }
            }

            // Also check for exact phrase match (the original full query)
            final exactPhraseMatch =
                courseName.contains(query.toLowerCase()) ||
                courseCode.contains(query.toLowerCase()) ||
                description.contains(query.toLowerCase());

            // Document should be included if it matches all words OR matches exact phrase
            return matchesAllWords || exactPhraseMatch;
          }).toList();
    });
  }

  Widget _buildCoursesView(BuildContext context) {
    if (filteredCourses.isEmpty && isStreamComplete) {
      return const Center(
        child: Text('No courses found. Try a different search term.'),
      );
    }

    // Determine if we should use grid or list based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final useGrid = screenWidth >= 900; // Desktop breakpoint

    if (useGrid) {
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,

          childAspectRatio: 2.0, // Increased for better fit
          // crossAxisSpacing: 16,
          // mainAxisSpacing: 16,
          mainAxisExtent: null, // Let cards size themselves
        ),
        itemCount: filteredCourses.length,
        itemBuilder: (context, index) {
          final course = filteredCourses[index];
          return CourseCard(data: course);
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: filteredCourses.length,
        itemBuilder: (context, index) {
          final course = filteredCourses[index];
          return CourseCard(data: course);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
        centerTitle: false,
        actions: [
          Text('Made with ❤️ by M4dhav'),
          IconButton(
            onPressed: () async {
              await launchUrl(Uri.parse("https://github.com/M4dhav"));
            },
            icon: SvgPicture.asset(
              'assets/github-mark.svg',
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search for courses...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                suffixIcon:
                    searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            filterDocuments('');
                          },
                        )
                        : null,
              ),
              onChanged: filterDocuments,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                // Progress indicator
                if (isLoading && !isStreamComplete)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: null, // Indeterminate
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Loading courses... ($loadedCourses loaded)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child:
                      errorMessage != null
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error Loading Courses',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                  ),
                                  child: Text(
                                    errorMessage!,
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    _loadCourses();
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                          : courses.isEmpty && isStreamComplete
                          ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No Courses Available',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No course materials have been uploaded yet.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                          : _buildCoursesView(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
