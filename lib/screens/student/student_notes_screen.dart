import 'package:flutter/material.dart';

class StudentNotesScreen extends StatelessWidget {
  const StudentNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notes = [
      ['Data Structures Notes', 'Unit 1 - Unit 5', Icons.description],
      ['Database Management Notes', 'SQL and Normalization', Icons.storage],
      ['Web Development Notes', 'HTML, CSS and JavaScript', Icons.web],
      ['Software Engineering Notes', 'SDLC and Agile', Icons.engineering],
      ['Computer Networks Notes', 'Networking Fundamentals', Icons.lan],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notes & Resources')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                child: Icon(note[2] as IconData),
              ),
              title: Text(
                note[0] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(note[1] as String),
              trailing: const Icon(Icons.open_in_new),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${note[0]} opened in demo mode.'),
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