import 'package:flutter/material.dart';

class FacultyMarksManagementScreen extends StatefulWidget {
  const FacultyMarksManagementScreen({super.key});

  @override
  State<FacultyMarksManagementScreen> createState() =>
      _FacultyMarksManagementScreenState();
}

class _FacultyMarksManagementScreenState
    extends State<FacultyMarksManagementScreen> {
  final List<Map<String, dynamic>> students = [
    {'name': 'Rahul Patil', 'id': 'S001', 'marks': 82},
    {'name': 'Sneha Joshi', 'id': 'S002', 'marks': 91},
    {'name': 'Aditya Kulkarni', 'id': 'S003', 'marks': 76},
    {'name': 'Priya Deshmukh', 'id': 'S004', 'marks': 88},
    {'name': 'Rohan Shinde', 'id': 'S005', 'marks': 80},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marks Management')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Data Structures - Internal Marks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(student['name']),
                    subtitle: Text(student['id']),
                    trailing: SizedBox(
                      width: 75,
                      child: TextFormField(
                        initialValue: '${student['marks']}',
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          labelText: 'Marks',
                        ),
                        onChanged: (value) {
                          final marks = int.tryParse(value);
                          if (marks != null) {
                            student['marks'] = marks;
                          }
                        },
                      ),
                    ),
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
                      'Marks saved in demo mode.',
                    ),
                  ),
                );
              },
              child: const Text('Save Marks'),
            ),
          ),
        ],
      ),
    );
  }
}