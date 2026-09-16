import 'package:flutter/material.dart';

class CourseSubjectManagementScreen extends StatelessWidget {
  const CourseSubjectManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courses = [
      ['BCA', 'Programming, DBMS, Web Development'],
      ['BBA', 'Management, Accounting, Marketing'],
      ['B.Com', 'Finance, Economics, Business Law'],
      ['B.Sc', 'Physics, Chemistry, Mathematics'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Course & Subjects')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book),
              title: Text(course[0]),
              subtitle: Text(course[1]),
              trailing: const Icon(Icons.edit),
            ),
          );
        },
      ),
    );
  }
}