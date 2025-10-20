import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl;
  String? _token;
  ApiService({required this.baseUrl, String? token}) : _token = token;

  // Use localhost for Flutter Web
  static ApiService instance = ApiService(baseUrl: 'http://localhost:8080');

  void setBaseUrl(String url) {
    instance = ApiService(baseUrl: url);
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> _loadToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  Map<String, String> _jsonHeaders([bool withAuth = false]) {
    final headers = {"Content-Type": "application/json"};
    if (withAuth && _token != null) headers['Authorization'] = 'Token $_token';
    return headers;
  }

  Future<Map<String, dynamic>> fetchDashboard() async {
    await _loadToken();
    final res = await http.get(Uri.parse('$baseUrl/api/dashboard/'),
        headers: _jsonHeaders(true));
    print('Dashboard response: ${res.statusCode} ${res.body}');
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load dashboard');
  }

  Future<bool> createCourse(
      {required String name,
      required String term,
      int? studentCount,
      required String description,
      required String code}) async {
    await _loadToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/courses/'),
      headers: _jsonHeaders(true),
      body: jsonEncode(
          {"name": name, "term": term, "students": studentCount ?? 0}),
    );
    print('Create course response: ${res.statusCode} ${res.body}');
    return res.statusCode == 201 || res.statusCode == 200;
  }

  Future<bool> addQuestion(
      {required String text,
      required String type,
      required String difficulty}) async {
    await _loadToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/questions/'),
      headers: _jsonHeaders(true),
      body: jsonEncode({"text": text, "type": type, "difficulty": difficulty}),
    );
    print('Add question response: ${res.statusCode} ${res.body}');
    return res.statusCode == 201 || res.statusCode == 200;
  }

  Future<bool> register(
      {required String name,
      required String email,
      required String password}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/register/'),
      headers: _jsonHeaders(false),
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );
    print('Register response: ${res.statusCode} ${res.body}');
    if (res.statusCode == 201 || res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token != null) await _saveToken(token);
      return true;
    }
    return false;
  }

  Future<bool> login({required String email, required String password}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/login/'),
      headers: _jsonHeaders(false),
      body: jsonEncode({"email": email, "password": password}),
    );
    print('Login response: ${res.statusCode} ${res.body}');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token != null) await _saveToken(token);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}

/*import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl;
  String? _token;
  ApiService({required this.baseUrl, String? token}) : _token = token;

  static ApiService instance = ApiService(baseUrl: 'http://localhost:8080');

  void setBaseUrl(String url) {
    // simple runtime setter
    instance = ApiService(baseUrl: url);
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> _loadToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  Map<String, String> _jsonHeaders([bool withAuth = false]) {
    final headers = {"Content-Type": "application/json"};
    if (withAuth && _token != null) headers['Authorization'] = 'Token $_token';
    return headers;
  }

  Future<Map<String, dynamic>> fetchDashboard() async {
    await _loadToken();
    final res = await http.get(Uri.parse('\$baseUrl/api/dashboard'), headers: _jsonHeaders(true));
    if (res.statusCode == 200) return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Failed to load dashboard');
  }

  Future<bool> createCourse({required String name, required String term, int? studentCount}) async {
    await _loadToken();
    final res = await http.post(Uri.parse('\$baseUrl/api/courses'), headers: _jsonHeaders(true), body: jsonEncode({"name": name, "term": term, "students": studentCount ?? 0}));
    return res.statusCode == 201 || res.statusCode == 200;
  }

  Future<bool> addQuestion({required String text, required String type, required String difficulty}) async {
    await _loadToken();
    final res = await http.post(Uri.parse('\$baseUrl/api/questions'), headers: _jsonHeaders(true), body: jsonEncode({"text": text, "type": type, "difficulty": difficulty}));
    return res.statusCode == 201 || res.statusCode == 200;
  }

  Future<bool> register({required String name, required String email, required String password}) async {
    final res = await http.post(Uri.parse('\$baseUrl/api/auth/register'), headers: _jsonHeaders(false), body: jsonEncode({"name": name, "email": email, "password": password}));
    if (res.statusCode == 201 || res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token != null) await _saveToken(token);
      return true;
    }
    return false;
  }

  Future<bool> login({required String email, required String password}) async {
    final res = await http.post(Uri.parse('\$baseUrl/api/auth/login'), headers: _jsonHeaders(false), body: jsonEncode({"email": email, "password": password}));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token != null) await _saveToken(token);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Add other stubs: tests, analytics
}
*/
