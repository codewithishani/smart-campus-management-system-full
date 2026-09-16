import 'package:flutter/material.dart';

class LinkedStudentProfileScreen extends StatelessWidget {
  const LinkedStudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Linked Student Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 48,
            child: Icon(Icons.school, size: 52),
          ),
          const SizedBox(height: 15),
          const Center(
            child: Text(
              'Rahul Patil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _item('Student ID', 'S001'),
          _item('Course', 'Bachelor of Computer Applications'),
          _item('Semester', 'Semester 5'),
          _item('Division', 'A'),
          _item('Roll Number', '21'),
          _item('Department', 'Computer Applications'),
          _item('Academic Year', '2026–2027'),
        ],
      ),
    );
  }

  Widget _item(String title, String value) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}