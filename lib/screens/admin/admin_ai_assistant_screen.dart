import 'package:flutter/material.dart';

class AdminAiAssistantScreen extends StatefulWidget {
  const AdminAiAssistantScreen({super.key});

  @override
  State<AdminAiAssistantScreen> createState() =>
      _AdminAiAssistantScreenState();
}

class _AdminAiAssistantScreenState
    extends State<AdminAiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, String>> messages = [
    {
      'sender': 'AI',
      'message':
          'Hello Admin! I am your Smart Campus AI Assistant. How can I help you?',
    },
  ];

  void _sendMessage() {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      return;
    }

    setState(() {
      messages.add({
        'sender': 'Admin',
        'message': text,
      });

      messages.add({
        'sender': 'AI',
        'message':
            'Demo AI response: I can help analyze students, attendance, academic reports, notices and campus data.',
      });
    });

    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Admin Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isAdmin = message['sender'] == 'Admin';

                return Align(
                  alignment: isAdmin
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        message['message']!,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Ask the AI Assistant...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}