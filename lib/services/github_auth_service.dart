import 'package:http/http.dart' as http;

class GitHubAuthService {
  // Get GitHub Personal Access Token from environment variables
  static const String _token = String.fromEnvironment('GITHUB_TOKEN');

  /// Check if GitHub token is configured
  bool isAuthenticated() {
    return _token.isNotEmpty;
  }

  /// Get the GitHub token (for compatibility with existing code)
  String? getAccessToken() {
    return _token.isNotEmpty ? _token : null;
  }

  /// Validate that the GitHub token is configured
  bool _validateConfig() {
    if (_token.isEmpty) {
      throw Exception(
        'GitHub token not configured. Please set GITHUB_TOKEN environment variable.',
      );
    }
    return true;
  }

  /// Make an authenticated GitHub API request
  Future<http.Response> authenticatedRequest(
    String url, {
    Map<String, String>? additionalHeaders,
  }) async {
    _validateConfig();

    final headers = <String, String>{
      'Accept': 'application/vnd.github.v3+json',
      'Authorization': 'Bearer $_token',
      ...?additionalHeaders,
    };

    return http.get(Uri.parse(url), headers: headers);
  }

  /// Check if a response indicates rate limiting
  static bool isRateLimited(http.Response response) {
    return response.statusCode == 403 &&
        response.headers['x-ratelimit-remaining'] == '0';
  }

  /// Get rate limit info from response headers
  static Map<String, String> getRateLimitInfo(http.Response response) {
    return {
      'limit': response.headers['x-ratelimit-limit'] ?? 'Unknown',
      'remaining': response.headers['x-ratelimit-remaining'] ?? 'Unknown',
      'reset': response.headers['x-ratelimit-reset'] ?? 'Unknown',
    };
  }
}
