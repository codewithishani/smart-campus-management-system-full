import 'package:flutter/material.dart';

class ClassManagementScreen extends StatelessWidget {
  const ClassManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final classes = [
      ['BCA', 'Semester 5', 'Division A', '60 Students'],
      ['BCA', 'Semester 5', 'Division B', '55 Students'],
      ['BCA', 'Semester 3', 'Division A', '58 Students'],
      ['BBA', 'Semester 3', 'Division A', '50 Students'],
      ['B.Com', 'Semester 3', 'Division A', '45 Students'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Class Management')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: classes.length,
        itemBuilder: (context, index) {
          final item = classes[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.class_),
              title: Text('${item[0]} • ${item[1]}'),
              subtitle: Text(
                '${item[2]} • ${item[3]}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        },
      ),
    );
  }
}