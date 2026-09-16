import 'package:flutter/material.dart';

class StudentPerformanceScreen extends StatelessWidget {
  const StudentPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Performance Insights')),
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
                      'Overall Performance',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '8.2 CGPA',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: 0.82,
                      minHeight: 10,
                    ),
                    const SizedBox(height: 8),
                    const Text('82% Academic Performance'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            _performanceCard(
              'Attendance',
              '85%',
              Icons.calendar_month,
              0.85,
            ),

            _performanceCard(
              'Assignments',
              '90%',
              Icons.assignment,
              0.90,
            ),

            _performanceCard(
              'Examinations',
              '82%',
              Icons.school,
              0.82,
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.lightbulb),
                title: const Text(
                  'Performance Insight',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Your academic performance is good. Continue focusing on regular attendance and assignments.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _performanceCard(
    String title,
    String value,
    IconData icon,
    double progress,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  LinearProgressIndicator(value: progress),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}