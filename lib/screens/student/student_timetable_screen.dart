import 'package:flutter/material.dart';

class StudentTimetableScreen extends StatelessWidget {
  const StudentTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timetable')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const Text(
                'Weekly Class Timetable',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: Table(
                  border: TableBorder.all(
                    color: Colors.grey,
                    width: 0.8,
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(1.25),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(1),
                    4: FlexColumnWidth(1),
                    5: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(
                      children: [
                        _cell('Time', true),
                        _cell('Mon', true),
                        _cell('Tue', true),
                        _cell('Wed', true),
                        _cell('Thu', true),
                        _cell('Fri', true),
                      ],
                    ),
                    _row(
                      '9:00\n- 10:00',
                      'Data\nStructures',
                      'Database',
                      'Web\nDevelopment',
                      'Software\nEngineering',
                      'Networks',
                    ),
                    _row(
                      '10:15\n- 11:15',
                      'Database',
                      'Web\nDevelopment',
                      'Networks',
                      'Data\nStructures',
                      'Software\nEngineering',
                    ),
                    _row(
                      '11:15\n- 12:15',
                      'Networks',
                      'Software\nEngineering',
                      'Database',
                      'Web\nDevelopment',
                      'Data\nStructures',
                    ),
                    TableRow(
                      children: [
                        _cell('12:15\n- 1:15', false),
                        _lunch(),
                        _lunch(),
                        _lunch(),
                        _lunch(),
                        _lunch(),
                      ],
                    ),
                    _row(
                      '1:15\n- 2:15',
                      'Web\nDevelopment',
                      'Networks',
                      'Data\nStructures',
                      'Database',
                      'Software\nEngineering',
                    ),
                    _row(
                      '2:15\n- 3:15',
                      'Software\nEngineering',
                      'Data\nStructures',
                      'Web\nDevelopment',
                      'Networks',
                      'Database',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.circle, size: 10),
                  SizedBox(width: 5),
                  Text('Regular Classes'),
                  SizedBox(width: 20),
                  Icon(Icons.restaurant, size: 16),
                  SizedBox(width: 5),
                  Text('Lunch Break'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static TableRow _row(
    String time,
    String mon,
    String tue,
    String wed,
    String thu,
    String fri,
  ) {
    return TableRow(
      children: [
        _cell(time, false),
        _cell(mon, false),
        _cell(tue, false),
        _cell(wed, false),
        _cell(thu, false),
        _cell(fri, false),
      ],
    );
  }

  static Widget _cell(String text, bool header) {
    return Container(
      height: header ? 42 : 58,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(3),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: header ? 13 : 11,
          fontWeight: header ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  static Widget _lunch() {
    return Container(
      height: 58,
      alignment: Alignment.center,
      child: const Icon(Icons.restaurant, size: 20),
    );
  }
}