// lib/services/api_client.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'token_storage.dart';
import 'api_errors.dart';
import 'auth_service.dart';

class ApiClient extends http.BaseClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final http.Client _inner = http.Client();

  Duration timeout = const Duration(seconds: 20);

  // Rutas que NO deben llevar Authorization
  final Set<String> _publicPaths = {
    '/auth/login',
    '/auth/register',
    '/auth/forgot-password',
    '/auth/reset-password',
    '/auth/verify-email',
    '/auth/refresh',
  };

  bool _isRefreshing = false;

  Uri _buildUri(String path, [Map<String, String>? q]) {
    final u = Uri.parse('${ApiConfig.baseUrl}$path');
    return q == null ? u : u.replace(queryParameters: q);
    // Nota: deja ApiConfig.baseUrl tal cual (http://10.0.2.2:5192)
  }

  Map<String, String> _mergeHeaders(
    Map<String, String>? headers, {
    bool withJson = true,
  }) {
    final h = <String, String>{};
    if (withJson) {
      h['Content-Type'] = 'application/json';
      h['Accept'] = 'application/json';
    }
    if (headers != null) h.addAll(headers);
    return h;
  }

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Permite usar ApiClient como any BaseClient
    return _inner.send(request);
  }

  Future<http.Response> _runWithAuth(
    Future<http.Response> Function(String? token) runner,
    String path,
  ) async {
    String? token = await TokenStorage.getAccessToken();
    http.Response res = await runner(token).timeout(timeout);

    // Si 401 → intenta refresh una vez
    if (res.statusCode == 401 && !_publicPaths.contains(path)) {
      if (!_isRefreshing) {
        _isRefreshing = true;
        try {
          final ok = await AuthService().refreshToken();
          if (ok) {
            token = await TokenStorage.getAccessToken();
          }
        } finally {
          _isRefreshing = false;
        }
      } else {
        // Si ya hay un refresh en curso, espera un poquito y reintenta con el nuevo token
        await Future.delayed(const Duration(milliseconds: 350));
        token = await TokenStorage.getAccessToken();
      }

      if (token != null && token.isNotEmpty) {
        res = await runner(token).timeout(timeout);
      }
    }

    return res;
  }

  // ----------- Helpers de alto nivel -----------
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
    bool jsonHeaders = true,
  }) async {
    final uri = _buildUri(path, query);
    final h = _mergeHeaders(headers, withJson: jsonHeaders);

    final res = await _runWithAuth((token) async {
      final hdrs = Map<String, String>.from(h);
      if (!_publicPaths.contains(path) && token != null && token.isNotEmpty) {
        hdrs['Authorization'] = 'Bearer $token';
      }
      return http.get(uri, headers: hdrs);
    }, path);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return <String, dynamic>{};
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) return data;
      return {'data': data};
    }
    throw ApiErrors.fromResponse(res);
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    // getJson debe devolver siempre un Map<String, dynamic>
    final Map<String, dynamic> data = await getJson(
      path,
      query: query,
      headers: headers,
    );

    // Preferimos "data", luego "items"
    final dynamic payload = data.containsKey('data')
        ? data['data']
        : (data.containsKey('items') ? data['items'] : null);

    if (payload is List) return payload;
    if (payload is Map<String, dynamic>) return [payload];

    // Último recurso: si el backend respondió un Map plano, devolvemos sus valores como lista
    if (payload == null && data.isNotEmpty) {
      return data.values.toList();
    }

    return <dynamic>[];
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    final h = _mergeHeaders(headers);

    final res = await _runWithAuth((token) async {
      final hdrs = Map<String, String>.from(h);
      if (!_publicPaths.contains(path) && token != null && token.isNotEmpty) {
        hdrs['Authorization'] = 'Bearer $token';
      }
      return http.post(uri, headers: hdrs, body: jsonEncode(body ?? {}));
    }, path);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return <String, dynamic>{};
      final data = jsonDecode(res.body);
      return (data is Map<String, dynamic>) ? data : {'data': data};
    }
    throw ApiErrors.fromResponse(res);
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    final h = _mergeHeaders(headers);

    final res = await _runWithAuth((token) async {
      final hdrs = Map<String, String>.from(h);
      if (!_publicPaths.contains(path) && token != null && token.isNotEmpty) {
        hdrs['Authorization'] = 'Bearer $token';
      }
      return http.put(uri, headers: hdrs, body: jsonEncode(body ?? {}));
    }, path);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return <String, dynamic>{};
      final data = jsonDecode(res.body);
      return (data is Map<String, dynamic>) ? data : {'data': data};
    }
    throw ApiErrors.fromResponse(res);
  }

  Future<void> deleteJson(String path, {Map<String, String>? headers}) async {
    final uri = _buildUri(path);
    final h = _mergeHeaders(headers);

    final res = await _runWithAuth((token) async {
      final hdrs = Map<String, String>.from(h);
      if (!_publicPaths.contains(path) && token != null && token.isNotEmpty) {
        hdrs['Authorization'] = 'Bearer $token';
      }
      return http.delete(uri, headers: hdrs);
    }, path);

    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw ApiErrors.fromResponse(res);
  }
}
