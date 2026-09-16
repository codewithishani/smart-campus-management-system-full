import 'package:flutter/material.dart';

class StudentResultsScreen extends StatelessWidget {
  const StudentResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final results = [
      ['Data Structures', '82', 'A'],
      ['Database Management', '86', 'A'],
      ['Web Development', '79', 'B+'],
      ['Software Engineering', '88', 'A'],
      ['Computer Networks', '81', 'A'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Results & Marks')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Semester 5 Result',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '8.2 CGPA',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Overall Academic Performance'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            Card(
              child: Column(
                children: [
                  const ListTile(
                    title: Text(
                      'Subject-wise Marks',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...results.map(
                    (result) => ListTile(
                      leading: const Icon(Icons.book),
                      title: Text(result[0]),
                      subtitle: Text('Grade: ${result[2]}'),
                      trailing: Text(
                        '${result[1]} / 100',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}