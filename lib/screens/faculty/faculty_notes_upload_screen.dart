import 'package:flutter/material.dart';

class FacultyNotesUploadScreen extends StatelessWidget {
  const FacultyNotesUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes Upload')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Notes & Resources',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),

            DropdownButtonFormField<String>(
              initialValue: 'Data Structures',
              decoration: const InputDecoration(
                labelText: 'Select Subject',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Data Structures',
                  child: Text('Data Structures'),
                ),
                DropdownMenuItem(
                  value: 'Database Management',
                  child: Text('Database Management'),
                ),
                DropdownMenuItem(
                  value: 'Software Engineering',
                  child: Text('Software Engineering'),
                ),
              ],
              onChanged: (_) {},
            ),

            const SizedBox(height: 16),

            const TextField(
              decoration: InputDecoration(
                labelText: 'Resource Title',
                prefixIcon: Icon(Icons.title),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    const Icon(
                      Icons.cloud_upload,
                      size: 55,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Select Resource File',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'File picker will be connected later.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Choose File'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Notes uploaded in demo mode.',
                    ),
                  ),
                );
              },
              child: const Text('Upload Notes'),
            ),
          ],
        ),
      ),
    );
  }
}