import 'package:flutter/material.dart';

class FacultyAiAssistantScreen extends StatefulWidget {
  const FacultyAiAssistantScreen({super.key});

  @override
  State<FacultyAiAssistantScreen> createState() =>
      _FacultyAiAssistantScreenState();
}

class _FacultyAiAssistantScreenState
    extends State<FacultyAiAssistantScreen> {
  final controller = TextEditingController();

  final List<Map<String, String>> messages = [
    {
      'sender': 'AI',
      'message':
          'Hello! I am your AI Faculty Assistant. How can I help you?',
    },
  ];

  void sendMessage() {
    final text = controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      messages.add({
        'sender': 'You',
        'message': text,
      });

      messages.add({
        'sender': 'AI',
        'message':
            'This is a demo AI response. Real AI integration will be connected later.',
      });
    });

    controller.clear();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Faculty Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message['sender'] == 'You';

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            message['sender']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(message['message']!),
                        ],
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
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Ask the AI assistant...',
                      ),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: sendMessage,
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