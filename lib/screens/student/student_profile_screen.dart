import 'package:flutter/material.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 48,
              child: Icon(Icons.person, size: 55),
            ),
            const SizedBox(height: 12),
            const Text(
              'Rahul Patil',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('Student ID: S001'),
            const SizedBox(height: 20),

            _section(
              'Personal Information',
              [
                _row(Icons.person, 'Name', 'Rahul Patil'),
                _row(Icons.email, 'Email', 'rahul@example.com'),
                _row(Icons.phone, 'Phone', '+91 9876543210'),
                _row(Icons.location_on, 'City', 'Pune'),
              ],
            ),

            _section(
              'Academic Information',
              [
                _row(Icons.school, 'Course', 'BCA'),
                _row(Icons.calendar_month, 'Semester', '5'),
                _row(Icons.apartment, 'Department', 'Computer Applications'),
                _row(Icons.badge, 'Roll Number', 'BCA001'),
              ],
            ),

            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit Profile is a demo feature.'),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _section(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  static Widget _row(IconData icon, String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}