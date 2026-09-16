import 'package:flutter/material.dart';

class StudentStudyRecommendationsScreen extends StatelessWidget {
  const StudentStudyRecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recommendations = [
      [
        'Focus on Database Management',
        'Spend extra time practicing SQL queries and normalization.',
        Icons.storage,
      ],
      [
        'Maintain Attendance',
        'Your current attendance is good. Continue attending regular classes.',
        Icons.calendar_month,
      ],
      [
        'Complete Pending Assignments',
        'Complete Data Structures and Networks assignments before their deadlines.',
        Icons.assignment,
      ],
      [
        'Exam Preparation',
        'Start revision early for the upcoming semester examinations.',
        Icons.school,
      ],
      [
        'Practice Programming',
        'Practice coding problems regularly to improve problem-solving skills.',
        Icons.code,
      ],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Recommendations'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final recommendation = recommendations[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    child: Icon(
                      recommendation[2] as IconData,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation[0] as String,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          recommendation[1] as String,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}