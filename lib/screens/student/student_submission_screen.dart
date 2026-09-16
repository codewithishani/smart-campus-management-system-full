import 'package:flutter/material.dart';

class StudentSubmissionScreen extends StatefulWidget {
  const StudentSubmissionScreen({super.key});

  @override
  State<StudentSubmissionScreen> createState() =>
      _StudentSubmissionScreenState();
}

class _StudentSubmissionScreenState
    extends State<StudentSubmissionScreen> {
  String selectedAssignment = 'Data Structures Assignment';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assignment Submission')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit Assignment',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),

            DropdownButtonFormField<String>(
              initialValue: selectedAssignment,
              decoration: const InputDecoration(
                labelText: 'Select Assignment',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Data Structures Assignment',
                  child: Text('Data Structures Assignment'),
                ),
                DropdownMenuItem(
                  value: 'Database Assignment',
                  child: Text('Database Assignment'),
                ),
                DropdownMenuItem(
                  value: 'Web Development Assignment',
                  child: Text('Web Development Assignment'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedAssignment = value;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_upload, size: 55),
                    const SizedBox(height: 12),
                    const Text(
                      'Upload Assignment File',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'PDF, DOC or ZIP file can be uploaded here.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
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
                      'Assignment submitted in demo mode.',
                    ),
                  ),
                );
              },
              child: const Text('Submit Assignment'),
            ),
          ],
        ),
      ),
    );
  }
}