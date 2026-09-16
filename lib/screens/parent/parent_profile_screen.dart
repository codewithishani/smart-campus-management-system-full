import 'package:flutter/material.dart';

class ParentProfileScreen extends StatelessWidget {
  const ParentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parent Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 48,
            child: Icon(Icons.person, size: 55),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Mr. Rajesh Patil',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _info('Parent ID', 'P001'),
          _info('Email', 'rajesh.patil@example.com'),
          _info('Phone', '+91 98765 43210'),
          _info('Occupation', 'Business'),
          _info('Linked Student', 'Rahul Patil'),
          _info('Relationship', 'Father'),
        ],
      ),
    );
  }

  Widget _info(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}