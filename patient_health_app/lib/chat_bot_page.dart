import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatBotPage extends StatefulWidget {
  final String username;

  const ChatBotPage({super.key, required this.username});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  final String _systemPrompt = """
You are a professional medical assistant. Your role is to analyze the patient’s symptoms and respond ONLY in the following format:

- **Category**: Not Severe / Severe / Critical  
- **Advice**: [Short and clear medical advice]

Follow these rules:
1. If symptoms are minor (like mild cold, body pain), categorize as **Not Severe**. Suggest rest, hot water bath, or a painkiller.
2. If symptoms indicate something concerning (like high fever, breathlessness), categorize as **Severe**. Suggest first aid and recommend visiting a hospital.
3. If symptoms are alarming (chest pain, seizures, etc.), categorize as **Critical**. Recommend calling emergency services and list nearby hospital advice.

Do NOT include any other text outside the format above. Be professional, calm, and concise.
""";

  Future<void> _sendMessage(String userInput) async {
    if (userInput.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'message': userInput});
      _isLoading = true;
      _controller.clear();
    });

    try {
      final response = await _getGeminiResponse(userInput);
      setState(() {
        _messages.add({'role': 'ai', 'message': response});
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'ai', 'message': 'Something went wrong: $e'});
      });
    }

    setState(() => _isLoading = false);
  }

  Future<String> _getGeminiResponse(String input) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: '', // Replace this with your actual API key
    );

    final chat = model.startChat(history: [
      Content.text(_systemPrompt),
    ]);

    final response = await chat.sendMessage(Content.text(input));
    return response.text ?? 'No response';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medical Chat Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg['message'] ?? ''),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Describe your symptoms...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
