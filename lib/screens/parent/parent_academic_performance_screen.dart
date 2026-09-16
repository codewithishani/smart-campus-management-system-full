import 'package:flutter/material.dart';

class ParentAcademicPerformanceScreen extends StatelessWidget {
  const ParentAcademicPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Academic Performance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _performanceCard(
            'Overall Performance',
            'Very Good',
            Icons.trending_up,
          ),
          _performanceCard(
            'Attendance',
            '85%',
            Icons.fact_check,
          ),
          _performanceCard(
            'Current CGPA',
            '8.2',
            Icons.grade,
          ),
          _performanceCard(
            'Assignments',
            '8 / 10 Submitted',
            Icons.assignment,
          ),
          _performanceCard(
            'Class Participation',
            'Good',
            Icons.groups,
          ),
          _performanceCard(
            'Academic Trend',
            'Improving',
            Icons.show_chart,
          ),
        ],
      ),
    );
  }

  Widget _performanceCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}