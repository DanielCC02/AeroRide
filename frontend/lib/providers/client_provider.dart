// lib/providers/client_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../services/api_config.dart';
import '../services/token_storage.dart';

class ClientProvider extends ChangeNotifier {
  int? _userId;
  String? _error;
  bool _loading = false;

  int? get userId => _userId;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token no disponible');
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      // 1) /api/users/profile
      int? id = await _getIdFrom(
        '${ApiConfig.baseUrl}/api/users/profile',
        headers,
      );
      // 2) fallback /users/me
      id ??= await _getIdFrom('${ApiConfig.baseUrl}/users/me', headers);

      if (id == null) {
        throw Exception('No se pudo obtener el id de usuario');
      }

      _userId = id;
    } catch (e) {
      _error = 'Unable to load profile';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<int?> _getIdFrom(String url, Map<String, String> headers) async {
    try {
      final resp = await http.get(Uri.parse(url), headers: headers);
      if (resp.statusCode < 200 || resp.statusCode >= 300) return null;
      if (resp.body.isEmpty) return null;

      final data = jsonDecode(resp.body);

      // Tolerante a estructuras { id, ... } o { user: { id } } o { data: { id } }
      if (data is Map<String, dynamic>) {
        if (data['id'] is num) return (data['id'] as num).toInt();
        if (data['user'] is Map && (data['user']['id'] is num)) {
          return (data['user']['id'] as num).toInt();
        }
        if (data['data'] is Map && (data['data']['id'] is num)) {
          return (data['data']['id'] as num).toInt();
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  void clear() {
    _userId = null;
    notifyListeners();
  }
}
