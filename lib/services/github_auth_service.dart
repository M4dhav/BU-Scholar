import 'dart:convert';
import 'dart:html' as html;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class GitHubAuthService {
  // Get credentials from environment variables (works with Vercel)
  static const String clientId = String.fromEnvironment('GITHUB_CLIENT_ID');
  static const String clientSecret = String.fromEnvironment('GITHUB_CLIENT_SECRET');
  static const String redirectUri = String.fromEnvironment('GITHUB_REDIRECT_URI', 
    defaultValue: 'http://localhost:3001/auth/callback');

  static const String _tokenKey = 'github_access_token';
  static const String _userKey = 'github_user_info';

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Get stored user info
  Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return json.decode(userJson) as Map<String, dynamic>;
    }
    return null;
  }

  /// Validate that environment variables are configured
  bool _validateConfig() {
    if (clientId.isEmpty || clientSecret.isEmpty) {
      throw Exception(
        'GitHub OAuth credentials not configured. Please check your .env file.',
      );
    }
    return true;
  }

  /// Initiate GitHub OAuth login for web
  Future<bool> login() async {
    try {
      _validateConfig();

      // For web, redirect to GitHub OAuth page
      final state = DateTime.now().millisecondsSinceEpoch.toString();
      final authUrl =
          'https://github.com/login/oauth/authorize'
          '?client_id=$clientId'
          '&redirect_uri=${Uri.encodeComponent(redirectUri)}'
          '&scope=user:email'
          '&state=$state';

      // Store state for verification
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('oauth_state', state);

      // Redirect to GitHub OAuth
      html.window.location.href = authUrl;

      return true; // This won't be reached due to redirect
    } catch (e) {
      print('GitHub OAuth error: $e');
      return false;
    }
  }

  /// Handle OAuth callback and exchange code for token
  Future<bool> handleOAuthCallback({String? code, String? state}) async {
    try {
      // If code and state not provided, try to get them from URL
      final uri = Uri.parse(html.window.location.href);
      final authCode = code ?? uri.queryParameters['code'];
      final authState = state ?? uri.queryParameters['state'];
      final error = uri.queryParameters['error'];

      if (error != null) {
        throw Exception('OAuth error: $error');
      }

      if (authCode == null) {
        throw Exception('No authorization code received');
      }

      // Verify state parameter
      final prefs = await SharedPreferences.getInstance();
      final storedState = prefs.getString('oauth_state');
      if (authState != storedState) {
        throw Exception('Invalid state parameter');
      }

      // Exchange code for token
      final tokenResponse = await http.post(
        Uri.parse('https://github.com/login/oauth/access_token'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body:
            'client_id=$clientId'
            '&client_secret=$clientSecret'
            '&code=$authCode'
            '&redirect_uri=${Uri.encodeComponent(redirectUri)}',
      );

      if (tokenResponse.statusCode != 200) {
        throw Exception(
          'Failed to exchange code for token: ${tokenResponse.body}',
        );
      }

      final tokenData = json.decode(tokenResponse.body);
      final accessToken = tokenData['access_token'] as String?;

      if (accessToken == null) {
        final errorDesc =
            tokenData['error_description'] ?? 'Access token not received';
        throw Exception('Token exchange failed: $errorDesc');
      }

      // Get user information
      final userResponse = await http.get(
        Uri.parse('https://api.github.com/user'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (userResponse.statusCode != 200) {
        throw Exception('Failed to fetch user information');
      }

      final userData = json.decode(userResponse.body);

      // Store token and user info
      await prefs.setString(_tokenKey, accessToken);
      await prefs.setString(_userKey, json.encode(userData));
      await prefs.remove('oauth_state'); // Clean up

      // Clear the OAuth parameters from URL
      html.window.history.replaceState({}, '', '/');

      return true;
    } catch (e) {
      print('OAuth callback error: $e');
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  /// Make an authenticated GitHub API request
  Future<http.Response> authenticatedRequest(
    String url, {
    Map<String, String>? additionalHeaders,
  }) async {
    final token = await getAccessToken();

    final headers = <String, String>{
      'Accept': 'application/vnd.github.v3+json',
      if (token != null) 'Authorization': 'Bearer $token',
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
