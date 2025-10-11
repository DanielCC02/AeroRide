import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';

class AuthService {
  Future<void> login(String email, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('Código: ${response.statusCode}');
    print('Respuesta: ${response.body}');
  }
}
