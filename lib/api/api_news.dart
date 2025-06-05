import 'dart:convert';

import 'api_client.dart';

class NewsApi {
  static final ApiClient apiClient = ApiClient();

  static Future<dynamic> news(String message) async {
    final model = "gpt-4o-mini";
    const String API_KEY = 'c84cacd0a1c94b29842333fa875c852c';
    return await apiClient.post(
      'chat/completions',
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $API_KEY',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {'role': 'user', 'content': message}
        ]
      }),
    );
  }
}
