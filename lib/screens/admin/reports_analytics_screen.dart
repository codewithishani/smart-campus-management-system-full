import 'package:flutter/material.dart';

class ReportsAnalyticsScreen extends StatelessWidget {
  const ReportsAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _report(
            'Student Attendance',
            'Overall attendance: 85%',
            Icons.fact_check,
          ),
          _report(
            'Academic Performance',
            'Average CGPA: 7.9',
            Icons.trending_up,
          ),
          _report(
            'Assignment Submission',
            '82% assignments submitted',
            Icons.assignment,
          ),
          _report(
            'Active Users',
            '1,200 active users',
            Icons.people,
          ),
          _report(
            'Complaints',
            '78% complaints resolved',
            Icons.report_problem,
          ),
          _report(
            'Events',
            '12 events conducted/planned',
            Icons.event,
          ),
        ],
      ),
    );
  }

  Widget _report(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(value),
        trailing: const Icon(Icons.bar_chart),
      ),
    );
  }
}