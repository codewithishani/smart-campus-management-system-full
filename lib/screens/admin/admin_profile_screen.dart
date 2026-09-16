import 'package:flutter/material.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.admin_panel_settings, size: 55),
          ),
          const SizedBox(height: 15),
          const Center(
            child: Text(
              'System Administrator',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _info('Admin ID', 'A001'),
          _info('Department', 'Administration'),
          _info('Email', 'admin@smartcampus.edu'),
          _info('Phone', '+91 98765 11111'),
          _info('Role', 'System Administrator'),
          _info('Status', 'Active'),
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