import 'package:flutter/material.dart';

class FacultyStudentPerformanceScreen extends StatelessWidget {
  const FacultyStudentPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final students = [
      ['Rahul Patil', 'S001', '85%', '8.2'],
      ['Sneha Joshi', 'S002', '92%', '9.1'],
      ['Aditya Kulkarni', 'S003', '78%', '7.5'],
      ['Priya Deshmukh', 'S004', '88%', '8.6'],
      ['Rohan Shinde', 'S005', '81%', '7.9'],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Performance'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              student[0],
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(student[1]),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                    children: [
                      _stat('Attendance', student[2]),
                      _stat('CGPA', student[3]),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _stat(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(title),
      ],
    );
  }
}