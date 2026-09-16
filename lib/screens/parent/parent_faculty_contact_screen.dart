import 'package:flutter/material.dart';

class ParentFacultyContactScreen extends StatelessWidget {
  const ParentFacultyContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faculty = [
      [
        'Prof. Amit Sharma',
        'Class Teacher',
        'Computer Applications',
        'amit.sharma@example.com',
      ],
      [
        'Prof. Neha Joshi',
        'Programming Faculty',
        'Computer Applications',
        'neha.joshi@example.com',
      ],
      [
        'Prof. Rahul Deshmukh',
        'DBMS Faculty',
        'Computer Applications',
        'rahul.d@example.com',
      ],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Faculty Contact')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faculty.length,
        itemBuilder: (context, index) {
          final person = faculty[index];

          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(
                person[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${person[1]}\n${person[2]}\n${person[3]}',
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.email),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Email option selected for ${person[0]}',
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}