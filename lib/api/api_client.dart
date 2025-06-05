import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;

  ApiClient(
      {this.baseUrl = 'https://api.aimlapi.com/v1/'});

  Future<T> retryRequest<T>(Future<T> Function() request) async {
    while (true) {
      try {
        T response = await request();
        return response;
      } catch (e) {
        print("Ошибка запроса: $e. Повторная попытка...");
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  /// GET-запрос
  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(url, headers: headers);
    return _processResponse(response);
  }

  /// POST-запрос
  Future<dynamic> post(String endpoint,
      {Map<String, String>? headers, dynamic body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(url, headers: headers, body: body);
    return _processResponse(response);
  }

  /// PUT-запрос
  Future<dynamic> put(String endpoint,
      {Map<String, String>? headers, dynamic body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.put(url, headers: headers, body: body);
    return _processResponse(response);
  }

  /// DELETE-запрос
  Future<dynamic> delete(String endpoint,
      {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.delete(url, headers: headers);
    return _processResponse(response);
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return null;
    } else {
      throw Exception(
          'Ошибка: ${response.statusCode}\nТело ответа: ${response.body}');
    }
  }
}
