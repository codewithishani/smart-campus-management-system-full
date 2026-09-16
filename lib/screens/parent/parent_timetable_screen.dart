import 'package:flutter/material.dart';

class ParentTimetableScreen extends StatelessWidget {
  const ParentTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timetable')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Table(
          border: TableBorder.all(
            color: Colors.grey,
            width: 0.8,
          ),
          columnWidths: const {
            0: FixedColumnWidth(75),
            1: FlexColumnWidth(),
            2: FlexColumnWidth(),
            3: FlexColumnWidth(),
            4: FlexColumnWidth(),
            5: FlexColumnWidth(),
          },
          children: const [
            TableRow(
              decoration: BoxDecoration(
                color: Color(0xFFE8EDFF),
              ),
              children: [
                _Cell('Time', bold: true),
                _Cell('Mon', bold: true),
                _Cell('Tue', bold: true),
                _Cell('Wed', bold: true),
                _Cell('Thu', bold: true),
                _Cell('Fri', bold: true),
              ],
            ),
            TableRow(
              children: [
                _Cell('9:00'),
                _Cell('Programming'),
                _Cell('DBMS'),
                _Cell('Web Dev'),
                _Cell('Networks'),
                _Cell('Software Eng.'),
              ],
            ),
            TableRow(
              children: [
                _Cell('10:00'),
                _Cell('DBMS'),
                _Cell('Programming'),
                _Cell('Networks'),
                _Cell('Web Dev'),
                _Cell('Practical'),
              ],
            ),
            TableRow(
              children: [
                _Cell('11:00'),
                _Cell('Web Dev'),
                _Cell('Networks'),
                _Cell('DBMS'),
                _Cell('Programming'),
                _Cell('Seminar'),
              ],
            ),
            TableRow(
              children: [
                _Cell('1:00'),
                _Cell('Practical'),
                _Cell('Software Eng.'),
                _Cell('Programming'),
                _Cell('DBMS'),
                _Cell('Web Dev'),
              ],
            ),
            TableRow(
              children: [
                _Cell('2:00'),
                _Cell('Networks'),
                _Cell('Web Dev'),
                _Cell('Practical'),
                _Cell('Software Eng.'),
                _Cell('Programming'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final bool bold;

  const _Cell(
    this.text, {
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}