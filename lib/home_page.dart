import 'package:flutter/material.dart';
import 'widgets/course_card.dart';
import 'github_service.dart';
import 'services/github_auth_service.dart';
import 'dart:html' as html;

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
  String? errorMessage;
  bool isAuthenticated = false;
  Map<String, dynamic>? userInfo;

  @override
  void initState() {
    super.initState();
    // Handle OAuth callback immediately, before Flutter routing processes URL
    _handleOAuthCallbackImmediate();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Check authentication status
      await _checkAuthStatus();
      
      // Then load courses
      await _loadCourses();
    });
  }

  void _handleOAuthCallbackImmediate() {
    // Capture the current URL immediately before Flutter processes it
    final currentUrl = html.window.location.href;
    print('Immediate URL capture: $currentUrl'); // Debug
    
    // Parse the URL to extract query parameters
    final uri = Uri.parse(currentUrl);
    print('Parsed URI: $uri'); // Debug
    print('Query parameters: ${uri.queryParameters}'); // Debug
    
    // Check if this is an OAuth callback
    if (uri.queryParameters.containsKey('code')) {
      print('OAuth code found, processing callback immediately...'); // Debug
      
      // Process the callback asynchronously
      Future.delayed(Duration.zero, () async {
        await _processOAuthCallback(uri);
      });
    }
  }

  Future<void> _processOAuthCallback(Uri uri) async {
    try {
      final code = uri.queryParameters['code'];
      final error = uri.queryParameters['error'];

      if (error != null) {
        throw Exception('OAuth error: $error');
      }

      if (code == null) {
        throw Exception('No authorization code received');
      }

      print('Processing OAuth code: $code'); // Debug
      
      // Use the auth service to exchange the code for a token
      final success = await authService.handleOAuthCallback();
      print('OAuth processing result: $success'); // Debug
      
      if (success) {
        // Clear the OAuth parameters from URL
        html.window.history.replaceState({}, '', '/');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully logged in to GitHub!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          
          // Refresh authentication status
          await _checkAuthStatus();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to complete GitHub login'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      print('OAuth processing error: $e'); // Debug
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OAuth error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _checkAuthStatus() async {
    print('Checking authentication status...'); // Debug
    isAuthenticated = await authService.isAuthenticated();
    print('Is authenticated: $isAuthenticated'); // Debug
    
    if (isAuthenticated) {
      userInfo = await authService.getUserInfo();
      print('User info: ${userInfo?.toString()}'); // Debug
    }
    setState(() {});
  }

  Future<void> _loadCourses() async {
    try {
      courses = await gitHubService.fetchCourses();
      filteredCourses = courses;
      errorMessage = null;
    } catch (e) {
      String error = e.toString();

      // Check if this might be a rate limit error
      if (error.contains('403') || error.contains('rate limit')) {
        if (isAuthenticated) {
          errorMessage =
              'GitHub API rate limit exceeded even with authentication. Please try again later.';
        } else {
          errorMessage =
              'GitHub API rate limit exceeded. Try logging in with your GitHub account for higher limits.';
        }
      } else {
        errorMessage = 'Failed to load courses: $error';
      }

      courses = [];
      filteredCourses = [];
    } finally {
      isLoading = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _handleGitHubLogin() async {
    try {
      final success = await authService.login();
      if (success) {
        await _checkAuthStatus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully logged in to GitHub!'),
            backgroundColor: Colors.green,
          ),
        );
        // Reload courses with authenticated access
        await _loadCourses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to login to GitHub'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleGitHubLogout() async {
    await authService.logout();
    await _checkAuthStatus();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logged out from GitHub')));
  }

  void filterDocuments(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredCourses = courses;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
        centerTitle: true,
        actions: [
          if (isAuthenticated)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _handleGitHubLogout();
                }
              },
              itemBuilder:
                  (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'user_info',
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userInfo?['login'] ?? 'User',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'GitHub Authenticated',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  ],
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage:
                          userInfo?['avatar_url'] != null
                              ? NetworkImage(userInfo!['avatar_url'])
                              : null,
                      child:
                          userInfo?['avatar_url'] == null
                              ? const Icon(Icons.person, size: 16)
                              : null,
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                onPressed: _handleGitHubLogin,
                icon: const Icon(Icons.login, size: 18),
                label: const Text('GitHub Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Authentication Status Banner
          if (isAuthenticated)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border.all(color: Colors.green[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Logged in as ${userInfo?['login'] ?? 'User'} • GitHub API authenticated',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
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
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
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
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              errorMessage!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isLoading = true;
                                    errorMessage = null;
                                  });
                                  initState();
                                },
                                child: const Text('Retry'),
                              ),
                              if (errorMessage!.contains('rate limit') &&
                                  !isAuthenticated) ...[
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: _handleGitHubLogin,
                                  icon: const Icon(Icons.login),
                                  label: const Text('Login to GitHub'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    )
                    : courses.isEmpty
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
                    : filteredCourses.isEmpty
                    ? const Center(
                      child: Text(
                        'No courses found. Try a different search term.',
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filteredCourses.length,
                      itemBuilder: (context, index) {
                        final course = filteredCourses[index];
                        return CourseCard(data: course);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
