import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StudentTimetableScreen extends StatefulWidget {
  final int studentId;

  const StudentTimetableScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentTimetableScreen> createState() =>
      _StudentTimetableScreenState();
}

class _StudentTimetableScreenState
    extends State<StudentTimetableScreen> {
  List<dynamic> timetableData = [];
  List<dynamic> subjectData = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadTimetable();
  }

  Future<void> loadTimetable() async {
    try {
      final results = await Future.wait([
        ApiService.getStudent(widget.studentId),
        ApiService.getClasses(),
        ApiService.getTimetable(),
        ApiService.getSubjects(),
      ]);

      if (!mounted) return;

      final student =
          Map<String, dynamic>.from(results[0] as Map);

      final classes = results[1] as List<dynamic>;
      final timetable = results[2] as List<dynamic>;
      final subjects = results[3] as List<dynamic>;

      final studentCourseId =
          student['course_id']?.toString();

      dynamic studentClass;

      for (final item in classes) {
        final classData =
            Map<String, dynamic>.from(item as Map);

        final classCourseId =
            classData['course_id']?.toString();

        if (studentCourseId != null &&
            classCourseId == studentCourseId) {
          studentClass = classData;
          break;
        }
      }

      if (studentClass == null) {
        setState(() {
          timetableData = [];
          subjectData = subjects;
          isLoading = false;
          errorMessage =
              'Class timetable not found for this student.';
        });
        return;
      }

      final classId =
          studentClass['class_id']?.toString() ??
              studentClass['id']?.toString();

      final filteredTimetable =
          timetable.where((item) {
        final timetableRecord =
            Map<String, dynamic>.from(item as Map);

        final timetableClassId =
            timetableRecord['class_id']?.toString();

        return timetableClassId == classId;
      }).toList();

      setState(() {
        timetableData = filteredTimetable;
        subjectData = subjects;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load timetable.';
      });
    }
  }

  String getSubject(
    String day,
    String startTime,
    String endTime,
  ) {
    for (final item in timetableData) {
      final record =
          Map<String, dynamic>.from(item as Map);

      final itemDay =
          record['day']?.toString().toLowerCase() ?? '';

      final itemStart =
          record['start_time']?.toString() ?? '';

      final itemEnd =
          record['end_time']?.toString() ?? '';

      if (itemDay == day.toLowerCase() &&
          itemStart.startsWith(startTime) &&
          itemEnd.startsWith(endTime)) {
        final subjectId =
            record['subject_id']?.toString();

        for (final subjectItem in subjectData) {
          final subject =
              Map<String, dynamic>.from(
            subjectItem as Map,
          );

          final id =
              subject['subject_id']?.toString() ??
                  subject['id']?.toString();

          if (id == subjectId) {
            return (subject['subject_name'] ??
                    subject['name'] ??
                    subject['title'] ??
                    'Subject $subjectId')
                .toString();
          }
        }

        return 'Subject $subjectId';
      }
    }

    return '—';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Timetable'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Timetable'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: loadTimetable,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadTimetable,
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
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: Table(
                        border: TableBorder.all(
                          color: Colors.grey,
                          width: 0.8,
                        ),
                        columnWidths: const {
                          0: FixedColumnWidth(90),
                          1: FixedColumnWidth(150),
                          2: FixedColumnWidth(150),
                          3: FixedColumnWidth(150),
                          4: FixedColumnWidth(150),
                          5: FixedColumnWidth(150),
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
                            '10:00\n- 11:00',
                            getSubject(
                              'Monday',
                              '10:00',
                              '11:00',
                            ),
                            getSubject(
                              'Tuesday',
                              '10:00',
                              '11:00',
                            ),
                            getSubject(
                              'Wednesday',
                              '10:00',
                              '11:00',
                            ),
                            getSubject(
                              'Thursday',
                              '10:00',
                              '11:00',
                            ),
                            getSubject(
                              'Friday',
                              '10:00',
                              '11:00',
                            ),
                          ),

                          _row(
                            '11:00\n- 12:00',
                            getSubject(
                              'Monday',
                              '11:00',
                              '12:00',
                            ),
                            getSubject(
                              'Tuesday',
                              '11:00',
                              '12:00',
                            ),
                            getSubject(
                              'Wednesday',
                              '11:00',
                              '12:00',
                            ),
                            getSubject(
                              'Thursday',
                              '11:00',
                              '12:00',
                            ),
                            getSubject(
                              'Friday',
                              '11:00',
                              '12:00',
                            ),
                          ),

                          _row(
                            '12:00\n- 1:00',
                            getSubject(
                              'Monday',
                              '12:00',
                              '13:00',
                            ),
                            getSubject(
                              'Tuesday',
                              '12:00',
                              '13:00',
                            ),
                            getSubject(
                              'Wednesday',
                              '12:00',
                              '13:00',
                            ),
                            getSubject(
                              'Thursday',
                              '12:00',
                              '13:00',
                            ),
                            getSubject(
                              'Friday',
                              '12:00',
                              '13:00',
                            ),
                          ),

                          TableRow(
                            children: [
                              _cell(
                                '1:00\n- 2:00',
                                false,
                              ),
                              _lunch(),
                              _lunch(),
                              _lunch(),
                              _lunch(),
                              _lunch(),
                            ],
                          ),

                          _row(
                            '2:00\n- 4:00',
                            getSubject(
                              'Monday',
                              '14:00',
                              '16:00',
                            ),
                            getSubject(
                              'Tuesday',
                              '14:00',
                              '16:00',
                            ),
                            getSubject(
                              'Wednesday',
                              '14:00',
                              '16:00',
                            ),
                            getSubject(
                              'Thursday',
                              '14:00',
                              '16:00',
                            ),
                            getSubject(
                              'Friday',
                              '14:00',
                              '16:00',
                            ),
                          ),

                          _row(
                            '4:00\n- 5:00',
                            getSubject(
                              'Monday',
                              '16:00',
                              '17:00',
                            ),
                            getSubject(
                              'Tuesday',
                              '16:00',
                              '17:00',
                            ),
                            getSubject(
                              'Wednesday',
                              '16:00',
                              '17:00',
                            ),
                            getSubject(
                              'Thursday',
                              '16:00',
                              '17:00',
                            ),
                            getSubject(
                              'Friday',
                              '16:00',
                              '17:00',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                    ),
                    SizedBox(width: 5),
                    Text('Regular Classes'),
                    SizedBox(width: 20),
                    Icon(
                      Icons.restaurant,
                      size: 16,
                    ),
                    SizedBox(width: 5),
                    Text('Lunch Break'),
                  ],
                ),
              ],
            ),
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

  static Widget _cell(
    String text,
    bool header,
  ) {
    return Container(
      height: header ? 42 : 65,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(5),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: header ? 13 : 12,
          fontWeight: header
              ? FontWeight.bold
              : FontWeight.w500,
        ),
      ),
    );
  }

  static Widget _lunch() {
    return Container(
      height: 65,
      alignment: Alignment.center,
      child: const Icon(
        Icons.restaurant,
        size: 20,
      ),
    );
  }
}