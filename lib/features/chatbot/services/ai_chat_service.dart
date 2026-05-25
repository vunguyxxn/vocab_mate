import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiChatService {
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');

  static const String _model = 'llama-3.1-8b-instant';

  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  static Future<String> ask(String userMessage) async {
    final message = userMessage.trim();

    if (message.isEmpty) {
      return 'Bạn hãy nhập câu hỏi trước nhé.';
    }

    if (_apiKey.isEmpty) {
      throw Exception(
        'Chưa có GROQ_API_KEY. Hãy chạy app với --dart-define=GROQ_API_KEY=...',
      );
    }

    if (kDebugMode) {
      debugPrint(
        'Groq key loaded: length=${_apiKey.length}, suffix=${_apiKey.substring(_apiKey.length - 4)}',
      );
      debugPrint('Groq model: $_model');
    }

    return _callGroq(message);
  }

  static Future<String> _callGroq(String message) async {
    late http.Response response;

    try {
      response = await http
          .post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': '''
Bạn là VocabMate AI, trợ lý học tiếng Anh trong app VocabMate.

Quy tắc trả lời:
- Trả lời bằng tiếng Việt.
- Ngắn gọn, dễ hiểu cho sinh viên Việt Nam.
- Nếu người dùng hỏi từ vựng, giải thích nghĩa tiếng Việt.
- Luôn có 1 ví dụ tiếng Anh ngắn và dịch tiếng Việt.
- Nếu hỏi ngữ pháp, giải thích đơn giản, có ví dụ.
- Không trả lời lan man.
- Không nhắc lại toàn bộ câu hỏi nếu không cần.
''',
            },
            {
              'role': 'user',
              'content': message,
            },
          ],
          'temperature': 0.5,
          'top_p': 0.8,
          'max_tokens': 250,
          'stream': false,
        }),
      )
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw Exception(
        'AI phản hồi quá lâu. Hãy kiểm tra mạng hoặc thử lại sau.',
      );
    } catch (e) {
      throw Exception('Không thể kết nối AI: $e');
    }

    if (kDebugMode) {
      debugPrint('Groq status: ${response.statusCode}');
      debugPrint('Groq body: ${response.body}');
    }

    if (response.statusCode == 401) {
      throw Exception(
        '401: GROQ_API_KEY không hợp lệ. Hãy kiểm tra lại API key.',
      );
    }

    if (response.statusCode == 429) {
      throw Exception(
        '429: AI đang bị giới hạn quota/tần suất. Hãy đợi một lát rồi thử lại.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'AI API lỗi ${response.statusCode}: ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final choices = data['choices'];
    if (choices is! List || choices.isEmpty) {
      return 'Mình chưa tạo được câu trả lời. Bạn thử hỏi lại ngắn hơn nhé.';
    }

    final firstChoice = choices.first;
    if (firstChoice is! Map<String, dynamic>) {
      return 'Mình chưa đọc được câu trả lời từ AI.';
    }

    final responseMessage = firstChoice['message'];
    if (responseMessage is! Map<String, dynamic>) {
      return 'Mình chưa nhận được nội dung trả lời phù hợp.';
    }

    final content = responseMessage['content']?.toString().trim();

    if (content == null || content.isEmpty) {
      return 'Mình chưa có câu trả lời phù hợp.';
    }

    return content;
  }
}