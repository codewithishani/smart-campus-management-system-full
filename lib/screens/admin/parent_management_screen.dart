import 'package:flutter/material.dart';

class ParentManagementScreen extends StatelessWidget {
  const ParentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final parents = [
      ['P001', 'Rajesh Patil', 'Rahul Patil'],
      ['P002', 'Sunita Sharma', 'Priya Sharma'],
      ['P003', 'Mahesh Joshi', 'Amit Joshi'],
      ['P004', 'Kavita More', 'Sneha More'],
      ['P005', 'Suresh Desai', 'Rohan Desai'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Parent Management')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: parents.length,
        itemBuilder: (context, index) {
          final parent = parents[index];

          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.family_restroom),
              ),
              title: Text(parent[1]),
              subtitle: Text(
                'Parent ID: ${parent[0]}\nStudent: ${parent[2]}',
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}