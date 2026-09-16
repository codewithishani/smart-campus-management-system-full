import 'package:flutter/material.dart';

class AcademicDataManagementScreen extends StatelessWidget {
  const AcademicDataManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      ['Attendance Records', '500 Students', 'Updated Today'],
      ['Marks Records', '500 Students', 'Updated Yesterday'],
      ['Assignment Records', '1,250 Records', 'Updated Today'],
      ['Examination Records', '500 Students', 'Updated 2 Days Ago'],
      ['Academic Results', '450 Published', 'Current Semester'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Academic Data')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.assessment),
              title: Text(item[0]),
              subtitle: Text('${item[1]}\n${item[2]}'),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}