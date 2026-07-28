import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    String userText = _controller.text;
    
    // Tampilkan pesan user di layar
    setState(() {
      _messages.add({'role': 'user', 'text': userText});
      _isLoading = true;
      _controller.clear();
    });

    // Panggil API Python 
    String aiResponse = await AiService.sendChatToAI(userText);

    // Tampilkan balasan AI di layar
    setState(() {
      _messages.add({'role': 'ai', 'text': aiResponse});
      _isLoading = false;
    });
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    setState(() {
      _messages.add({'role': 'user', 'text': '📸 [Gambar dikirim]'});
      _isLoading = true;
    });

    // Panggil API Python dengan gambar
    String aiResponse = await AiService.sendChatToAI(
      "Tolong analisa gambar makanan ini dan perkirakan kalorinya.",
      base64Image: base64Image,
    );

    setState(() {
      _messages.add({'role': 'ai', 'text': aiResponse});
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Ahli Gizi'),
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- AREA OBROLAN ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  bool isUser = msg['role'] == 'user';
                  
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.green.shade100 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(15).copyWith(
                          bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(15),
                          bottomLeft: isUser ? const Radius.circular(15) : const Radius.circular(0),
                        )
                      ),
                      child: Text(msg['text']!, style: const TextStyle(fontSize: 15)),
                    ),
                  );
                },
              ),
            ),

            // --- LOADING INDIKATOR ---
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),

            // --- AREA KETIK PESAN ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.green, size: 28),
                    onPressed: _pickAndSendImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Tanya kalori makanan...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 24,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
