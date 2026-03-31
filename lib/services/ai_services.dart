import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static Future<String> sendChatToAI(String userMessage) async {
    // Update URL dengan IP WiFi yang benar
    final url = Uri.parse('http://192.168.100.138:8000/chat');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'message': userMessage,
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