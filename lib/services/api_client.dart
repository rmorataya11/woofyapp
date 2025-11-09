import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/environment.dart';
import '../models/api_response.dart';
import '../utils/api_exceptions.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _storage = const FlutterSecureStorage();
  String? _accessToken;
  String? _refreshToken;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  Map<String, String> get _baseHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, String>> get _authHeaders async {
    final token = await getAccessToken();
    return {
      ..._baseHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    if (_accessToken != null) return _accessToken;
    _accessToken = await _storage.read(key: _accessTokenKey);
    return _accessToken;
  }

  Future<String?> getRefreshToken() async {
    if (_refreshToken != null) return _refreshToken;
    _refreshToken = await _storage.read(key: _refreshTokenKey);
    return _refreshToken;
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  String _buildUrl(String endpoint) {
    final baseUrl = Environment.baseUrl;
    final cleanEndpoint = endpoint.startsWith('/')
        ? endpoint.substring(1)
        : endpoint;
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return '$cleanBaseUrl/$cleanEndpoint';
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint));
      final uriWithParams = queryParams != null
          ? uri.replace(queryParameters: queryParams)
          : uri;

      final headers = requiresAuth ? await _authHeaders : _baseHeaders;

      final response = await http
          .get(uriWithParams, headers: headers)
          .timeout(Duration(seconds: Environment.requestTimeout));

      return _handleResponse<T>(response);
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    } on TimeoutException {
      throw ApiExceptionHandler.fromStatusCode(408, 'Request timeout');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint));
      final headers = requiresAuth ? await _authHeaders : _baseHeaders;

      final response = await http
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: Environment.requestTimeout));

      return _handleResponse<T>(response);
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    } on TimeoutException {
      throw ApiExceptionHandler.fromStatusCode(408, 'Request timeout');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint));
      final headers = requiresAuth ? await _authHeaders : _baseHeaders;

      final response = await http
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: Environment.requestTimeout));

      return _handleResponse<T>(response);
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    } on TimeoutException {
      throw ApiExceptionHandler.fromStatusCode(408, 'Request timeout');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint));
      final headers = requiresAuth ? await _authHeaders : _baseHeaders;

      final response = await http
          .patch(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(seconds: Environment.requestTimeout));

      return _handleResponse<T>(response);
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    } on TimeoutException {
      throw ApiExceptionHandler.fromStatusCode(408, 'Request timeout');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint));
      final headers = requiresAuth ? await _authHeaders : _baseHeaders;

      final response = await http
          .delete(uri, headers: headers)
          .timeout(Duration(seconds: Environment.requestTimeout));

      return _handleResponse<T>(response);
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    } on TimeoutException {
      throw ApiExceptionHandler.fromStatusCode(408, 'Request timeout');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  ApiResponse<T> _handleResponse<T>(http.Response response) {
    final statusCode = response.statusCode;

    dynamic jsonBody;
    try {
      if (response.body.isNotEmpty) {
        jsonBody = jsonDecode(response.body);
        if (jsonBody is List) {
          jsonBody = <String, dynamic>{
            'success': true,
            'message': 'Success',
            'data': jsonBody,
          };
        } else if (jsonBody is! Map<String, dynamic>) {
          throw FormatException('Formato de respuesta inválido');
        }
      }
    } catch (e) {
      if (statusCode >= 200 && statusCode < 300) {
        return ApiResponse<T>.success(
          message: 'Success',
          statusCode: statusCode,
        );
      } else {
        throw ApiExceptionHandler.fromStatusCode(
          statusCode,
          'Error: ${response.body}',
        );
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      final jsonMap = jsonBody as Map<String, dynamic>;
      return ApiResponse<T>(
        success: jsonMap['success'] ?? true,
        message: jsonMap['message'] ?? 'Success',
        data: jsonMap['data'] as T?,
        statusCode: statusCode,
      );
    }

    final jsonMap = jsonBody as Map<String, dynamic>?;
    final message = jsonMap?['message'] ?? 'Error desconocido';
    final errors = jsonMap?['errors'] as Map<String, dynamic>?;

    throw ApiExceptionHandler.fromStatusCode(
      statusCode,
      message,
      errors: errors,
    );
  }

  Future<ApiResponse<T>> postMultipart<T>(
    String endpoint, {
    required Map<String, String> fields,
    required String fileField,
    required String filePath,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint));
      final request = http.MultipartRequest('POST', uri);

      final headers = requiresAuth ? await _authHeaders : _baseHeaders;
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      request.fields.addAll(fields);

      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));

      final streamedResponse = await request.send().timeout(
        Duration(seconds: Environment.requestTimeout),
      );

      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse<T>(response);
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    } on TimeoutException {
      throw ApiExceptionHandler.fromStatusCode(408, 'Request timeout');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
