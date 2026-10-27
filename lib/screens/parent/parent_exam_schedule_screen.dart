import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ParentExamScheduleScreen extends StatefulWidget {
  final int parentId;

  const ParentExamScheduleScreen({
    super.key,
    required this.parentId,
  });

  @override
  State<ParentExamScheduleScreen> createState() =>
      _ParentExamScheduleScreenState();
}

class _ParentExamScheduleScreenState
    extends State<ParentExamScheduleScreen> {
  List<dynamic> exams = [];
  List<dynamic> subjects = [];
  List<dynamic> students = [];
  List<dynamic> linkedStudents = [];
  List<dynamic> classes = [];

  int selectedStudentId = 0;
  int linkedClassId = 0;
  int linkedCourseId = 0;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadExamSchedule();
  }

  Future<void> loadExamSchedule() async {
    try {
      final data = await Future.wait([
        ApiService.getParentStudentLinks(),
        ApiService.getStudents(),
        ApiService.getExams(),
        ApiService.getSubjects(),
        ApiService.getClasses(),
      ]);

      final links = data[0];
      final studentData = data[1];
      final examData = data[2];
      final subjectData = data[3];
      final classData = data[4];

      final studentIds = <int>{};

      for (final item in links) {
        if (item is! Map) continue;

        final link = Map<String, dynamic>.from(item);

        final parentId = getIntValue(
          link,
          ['parent_id'],
        );

        if (parentId != widget.parentId) {
          continue;
        }

        final studentId = getIntValue(
          link,
          ['student_id'],
        );

        if (studentId != 0) {
          studentIds.add(studentId);
        }
      }

      final resolvedStudents = <Map<String, dynamic>>[];

      for (final item in studentData) {
        if (item is! Map) continue;

        final student = Map<String, dynamic>.from(item);

        final studentId = getIntValue(
          student,
          ['student_id', 'id'],
        );

        if (studentIds.contains(studentId)) {
          resolvedStudents.add(student);
        }
      }

      int initialStudentId = 0;

      if (resolvedStudents.isNotEmpty) {
        initialStudentId = getIntValue(
          resolvedStudents.first,
          ['student_id', 'id'],
        );
      }

      if (!mounted) return;

      setState(() {
        students = studentData;
        linkedStudents = resolvedStudents;
        exams = examData;
        subjects = subjectData;
        classes = classData;
        selectedStudentId = initialStudentId;
        isLoading = false;
        errorMessage = null;
      });

      updateSelectedStudent(initialStudentId);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load examination schedule.';
      });
    }
  }

  void updateSelectedStudent(int studentId) {
    int courseId = 0;
    int classId = 0;

    for (final item in students) {
      if (item is! Map) continue;

      final student = Map<String, dynamic>.from(item);

      final currentStudentId = getIntValue(
        student,
        ['student_id', 'id'],
      );

      if (currentStudentId != studentId) {
        continue;
      }

      courseId = getIntValue(
        student,
        ['course_id'],
      );

      classId = getIntValue(
        student,
        ['class_id'],
      );

      break;
    }

    if (classId == 0 && courseId != 0) {
      for (final item in classes) {
        if (item is! Map) continue;

        final classItem = Map<String, dynamic>.from(item);

        final currentCourseId = getIntValue(
          classItem,
          ['course_id'],
        );

        if (currentCourseId == courseId) {
          classId = getIntValue(
            classItem,
            ['class_id', 'id'],
          );
          break;
        }
      }
    }

    if (!mounted) return;

    setState(() {
      selectedStudentId = studentId;
      linkedClassId = classId;
      linkedCourseId = courseId;
    });
  }

  int getIntValue(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value is int) {
        return value;
      }

      if (value is num) {
        return value.toInt();
      }

      final parsed = int.tryParse(
        value?.toString() ?? '',
      );

      if (parsed != null) {
        return parsed;
      }
    }

    return 0;
  }

  String getStringValue(
    Map<String, dynamic> data,
    List<String> keys, {
    String defaultValue = '',
  }) {
    for (final key in keys) {
      final value = data[key];

      if (value != null &&
          value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return defaultValue;
  }

  String getStudentName(int studentId) {
    for (final item in linkedStudents) {
      if (item is! Map) continue;

      final student = Map<String, dynamic>.from(item);

      final currentStudentId = getIntValue(
        student,
        ['student_id', 'id'],
      );

      if (currentStudentId == studentId) {
        return getStringValue(
          student,
          ['name', 'student_name'],
          defaultValue: 'Student',
        );
      }
    }

    return 'Student';
  }

  Widget buildStudentSelector() {
    if (linkedStudents.length <= 1) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: DropdownButtonFormField<int>(
          initialValue: selectedStudentId == 0
              ? null
              : selectedStudentId,
          decoration: const InputDecoration(
            labelText: 'Select Student',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          items: linkedStudents.map<DropdownMenuItem<int>>(
            (item) {
              final student =
                  Map<String, dynamic>.from(item);

              final studentId = getIntValue(
                student,
                ['student_id', 'id'],
              );

              final studentName = getStringValue(
                student,
                ['name', 'student_name'],
                defaultValue: 'Student',
              );

              return DropdownMenuItem<int>(
                value: studentId,
                child: Text(studentName),
              );
            },
          ).toList(),
          onChanged: (value) {
            if (value != null) {
              updateSelectedStudent(value);
            }
          },
        ),
      ),
    );
  }

  String getSubjectName(int subjectId) {
    for (final item in subjects) {
      if (item is! Map) continue;

      final subject = Map<String, dynamic>.from(item);

      final currentSubjectId = getIntValue(
        subject,
        ['subject_id', 'id'],
      );

      if (currentSubjectId == subjectId) {
        return getStringValue(
          subject,
          [
            'subject_name',
            'name',
            'title',
          ],
          defaultValue: 'Subject',
        );
      }
    }

    return 'Subject';
  }

  String formatDate(String value) {
    if (value.isEmpty) {
      return '';
    }

    try {
      final date = DateTime.parse(value);

      final day = date.day.toString().padLeft(2, '0');
      final month =
          date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      return '$day/$month/$year';
    } catch (_) {
      return value;
    }
  }

  String formatTime(String value) {
    if (value.isEmpty) {
      return '';
    }

    try {
      final parts = value.split(':');

      if (parts.length < 2) {
        return value;
      }

      int hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final period = hour >= 12 ? 'PM' : 'AM';

      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour -= 12;
      }

      return '$hour:${minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return value;
    }
  }

  List<Map<String, dynamic>> getStudentExams() {
    final result = <Map<String, dynamic>>[];

    if (linkedClassId == 0) {
      return result;
    }

    for (final item in exams) {
      if (item is! Map) continue;

      final exam = Map<String, dynamic>.from(item);

      final examClassId = getIntValue(
        exam,
        ['class_id'],
      );

      if (examClassId != linkedClassId) {
        continue;
      }

      result.add(exam);
    }

    result.sort((a, b) {
      final dateA = getStringValue(
        a,
        ['exam_date', 'date'],
      );

      final dateB = getStringValue(
        b,
        ['exam_date', 'date'],
      );

      final dateCompare = dateA.compareTo(dateB);

      if (dateCompare != 0) {
        return dateCompare;
      }

      final timeA = getStringValue(
        a,
        ['start_time', 'time'],
      );

      final timeB = getStringValue(
        b,
        ['start_time', 'time'],
      );

      return timeA.compareTo(timeB);
    });

    return result;
  }

  Widget buildExamCard(
    Map<String, dynamic> exam,
  ) {
    final subjectId = getIntValue(
      exam,
      ['subject_id'],
    );

    final subjectName = subjectId != 0
        ? getSubjectName(subjectId)
        : getStringValue(
            exam,
            [
              'subject_name',
              'subject',
            ],
            defaultValue: 'Subject',
          );

    final examName = getStringValue(
      exam,
      [
        'exam_name',
        'name',
        'title',
      ],
      defaultValue: 'Examination',
    );

    final examDate = getStringValue(
      exam,
      [
        'exam_date',
        'date',
      ],
    );

    final startTime = getStringValue(
      exam,
      [
        'start_time',
        'time',
      ],
    );

    final endTime = getStringValue(
      exam,
      ['end_time'],
    );

    final room = getStringValue(
      exam,
      [
        'room_no',
        'room',
        'venue',
      ],
    );

    String timeText = '';

    if (startTime.isNotEmpty) {
      timeText = formatTime(startTime);

      if (endTime.isNotEmpty) {
        timeText +=
            ' - ${formatTime(endTime)}';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: const CircleAvatar(
          child: Icon(Icons.event),
        ),
        title: Text(
          subjectName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(examName),
              const SizedBox(height: 5),
              if (examDate.isNotEmpty)
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formatDate(examDate),
                    ),
                  ],
                ),
              if (timeText.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Text(timeText),
                    ],
                  ),
                ),
              if (room.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.room,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Text('Room: $room'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 55,
            ),
            const SizedBox(height: 14),
            Text(
              errorMessage ??
                  'Unable to load examination schedule.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });

                loadExamSchedule();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return buildLoading();
    }

    if (errorMessage != null) {
      return buildError();
    }

    if (linkedStudents.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadExamSchedule,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 100),
            Icon(
              Icons.link_off,
              size: 70,
            ),
            SizedBox(height: 18),
            Text(
              'No linked student found.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    final studentExams = getStudentExams();

    return RefreshIndicator(
      onRefresh: loadExamSchedule,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          buildStudentSelector(),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.event),
              ),
              title: const Text(
                'Examination Schedule',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                getStudentName(selectedStudentId),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (linkedClassId == 0)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 60,
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Class information not found.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'The selected student is not currently mapped to a class.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else if (studentExams.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 60,
                    ),
                    SizedBox(height: 14),
                    Text(
                      'No examination schedule found.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Upcoming examinations for the selected student will appear here.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.calendar_month,
                ),
                title: Text(
                  '${studentExams.length} examination${studentExams.length == 1 ? '' : 's'} scheduled',
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...studentExams.map(buildExamCard),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Examination Schedule',
        ),
      ),
      body: buildBody(),
    );
  }
}