import 'package:flutter/material.dart';

class FacultyNoticePublishingScreen extends StatefulWidget {
  const FacultyNoticePublishingScreen({super.key});

  @override
  State<FacultyNoticePublishingScreen> createState() =>
      _FacultyNoticePublishingScreenState();
}

class _FacultyNoticePublishingScreenState
    extends State<FacultyNoticePublishingScreen> {
  final titleController = TextEditingController();
  final messageController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    super.dispose();
  }

  void publishNotice() {
    if (titleController.text.trim().isEmpty ||
        messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notice published in demo mode.'),
      ),
    );

    titleController.clear();
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notice Publishing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Publish Notice',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 18),

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Notice Title',
                prefixIcon: Icon(Icons.title),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: messageController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Notice Message',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.campaign),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: publishNotice,
              icon: const Icon(Icons.publish),
              label: const Text('Publish Notice'),
            ),
          ],
        ),
      ),
    );
  }
}