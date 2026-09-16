import 'package:flutter/material.dart';

class FacultyAttendanceScreen extends StatefulWidget {
  const FacultyAttendanceScreen({super.key});

  @override
  State<FacultyAttendanceScreen> createState() =>
      _FacultyAttendanceScreenState();
}

class _FacultyAttendanceScreenState
    extends State<FacultyAttendanceScreen> {
  final List<Map<String, dynamic>> students = [
    {
      'name': 'Rahul Patil',
      'id': 'S001',
      'present': true,
    },
    {
      'name': 'Sneha Joshi',
      'id': 'S002',
      'present': true,
    },
    {
      'name': 'Aditya Kulkarni',
      'id': 'S003',
      'present': false,
    },
    {
      'name': 'Priya Deshmukh',
      'id': 'S004',
      'present': true,
    },
    {
      'name': 'Rohan Shinde',
      'id': 'S005',
      'present': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Management')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat(
                    'Present',
                    students.where((s) => s['present'] == true).length,
                  ),
                  _stat(
                    'Absent',
                    students.where((s) => s['present'] == false).length,
                  ),
                  _stat('Total', students.length),
                ],
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mark Attendance',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];

                return Card(
                  child: SwitchListTile(
                    title: Text(student['name']),
                    subtitle: Text(student['id']),
                    value: student['present'],
                    onChanged: (value) {
                      setState(() {
                        student['present'] = value;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Attendance saved in demo mode.',
                    ),
                  ),
                );
              },
              child: const Text('Save Attendance'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String title, int value) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(title),
      ],
    );
  }
}