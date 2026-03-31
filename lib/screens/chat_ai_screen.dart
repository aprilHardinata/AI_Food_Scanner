import 'package:flutter/material.dart';
import '../services/ai_services.dart'; // Pastikan path import ini sesuai dengan foldermu

class AiChatSidebar extends StatefulWidget {
  const AiChatSidebar({Key? key}) : super(key: key);

  @override
  State<AiChatSidebar> createState() => _AiChatSidebarState();
}

class _AiChatSidebarState extends State<AiChatSidebar> {
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

    // Panggil API Python kamu
    String aiResponse = await AiService.sendChatToAI(userText);

    // Tampilkan balasan AI di layar
    setState(() {
      _messages.add({'role': 'ai', 'text': aiResponse});
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Membatasi lebar agar cuma jadi "Side bar" (sekitar 75% layar)
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75, 
      child: SafeArea(
        child: Column(
          children: [
            // --- HEADER SIDEBAR ---
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green, // Disesuaikan dengan tema aplikasi nutrisi
              child: Row(
                children: [
                  const Icon(Icons.smart_toy, color: Colors.white),
                  const SizedBox(width: 10),
                  const Text('AI Ahli Gizi', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context), // Tutup sidebar
                  )
                ],
              ),
            ),

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