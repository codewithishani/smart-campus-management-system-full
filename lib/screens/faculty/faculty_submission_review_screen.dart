import 'package:flutter/material.dart';

class FacultySubmissionReviewScreen extends StatelessWidget {
  const FacultySubmissionReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final submissions = [
      ['Rahul Patil', 'Binary Tree Implementation', 'Submitted'],
      ['Sneha Joshi', 'Binary Tree Implementation', 'Reviewed'],
      ['Aditya Kulkarni', 'SQL Database Project', 'Submitted'],
      ['Priya Deshmukh', 'Agile Case Study', 'Reviewed'],
      ['Rohan Shinde', 'Network Design Report', 'Pending'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Submission Review')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: submissions.length,
        itemBuilder: (context, index) {
          final item = submissions[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.description),
              ),
              title: Text(
                item[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(item[1]),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item[2],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: item[2] == 'Pending'
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Review',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Submission review is in demo mode.',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}