import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = (baseUrl ?? ApiConfig.baseUrl).replaceAll(
        regTrailingSlash,
        '',
      );

  final http.Client _client;
  final String _baseUrl;
  String? _token;

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  void setToken(String token) => _token = token;

  void clearToken() => _token = null;

  Future<Map<String, dynamic>> getAuthStatus() {
    return getJson('/auth/status');
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) {
    return postJson('/auth/login', {
      'username': username,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> getJson(String path) async {
    final request = http.Request('GET', Uri.parse('$_baseUrl$path'));
    _addAuthHeader(request);
    return _send(request);
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final request = http.Request('POST', Uri.parse('$_baseUrl$path'))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode(body);
    _addAuthHeader(request);
    return _send(request);
  }

  Future<Map<String, dynamic>> putJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final request = http.Request('PUT', Uri.parse('$_baseUrl$path'))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode(body);
    _addAuthHeader(request);
    return _send(request);
  }

  Future<Map<String, dynamic>> deleteJson(String path) async {
    final request = http.Request('DELETE', Uri.parse('$_baseUrl$path'));
    _addAuthHeader(request);
    return _send(request);
  }

  void _addAuthHeader(http.Request request) {
    if (_token != null && _token!.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
  }

  Future<Map<String, dynamic>> _send(http.Request request) async {
    try {
      final streamed = await _client.send(request);
      final response = await http.Response.fromStream(streamed);
      final dynamic decoded = response.body.isEmpty
          ? null
          : jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          _extractError(decoded, response.body),
          statusCode: response.statusCode,
        );
      }
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is List) {
        return {'data': decoded};
      }
      return <String, dynamic>{};
    } on ApiException {
      rethrow;
    } on FormatException catch (error) {
      throw ApiException('The server returned invalid JSON: ${error.message}');
    } catch (error) {
      throw ApiException('Could not connect to the API: $error');
    }
  }

  String _extractError(dynamic decoded, String fallback) {
    if (decoded is Map<String, dynamic>) {
      final detail = decoded['detail'];
      if (detail is String) return detail;
      if (detail is Map<String, dynamic>) {
        final message = detail['message'];
        final keitaroError = detail['keitaro_error'];
        if (message is String && keitaroError is String) {
          return '$message\n$keitaroError';
        }
        if (message is String) return message;
      }
      if (decoded['message'] is String) return decoded['message'] as String;
    }
    return fallback.isEmpty ? 'The API request failed.' : fallback;
  }

  void dispose() => _client.close();
}

final RegExp regTrailingSlash = RegExp(r'\/+$');
