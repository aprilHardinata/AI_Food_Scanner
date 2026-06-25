import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static Future<String> sendChatToAI(String userMessage, {String threadId = "default_thread"}) async {
    // Update URL dengan IP WiFi yang benar
    final url = Uri.parse('http://192.168.0.100:8000/chat');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'message': userMessage,
          'thread_id': threadId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply']; 
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Gagal terhubung: $e";
    }
  }
}