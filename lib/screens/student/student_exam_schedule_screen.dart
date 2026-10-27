import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StudentExamScheduleScreen extends StatefulWidget {
  final int studentId;

  const StudentExamScheduleScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentExamScheduleScreen> createState() =>
      _StudentExamScheduleScreenState();
}

class _StudentExamScheduleScreenState
    extends State<StudentExamScheduleScreen> {
  List<dynamic> exams = [];
  List<dynamic> subjects = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadExamSchedule();
  }

  Future<void> loadExamSchedule() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getStudent(widget.studentId),
        ApiService.getClasses(),
        ApiService.getExams(),
        ApiService.getSubjects(),
      ]);

      final student =
          results[0] as Map<String, dynamic>;

      final classes =
          results[1] as List<dynamic>;

      final examData =
          results[2] as List<dynamic>;

      final subjectData =
          results[3] as List<dynamic>;

      final studentCourseId =
          student['course_id'];

      final studentSemester =
          student['semester'];

      Map<String, dynamic>? studentClass;

      for (final item in classes) {
        if (item is! Map) {
          continue;
        }

        final classData =
            Map<String, dynamic>.from(item);

        final classCourseId =
            classData['course_id'];

        final classSemester =
            classData['semester'];

        final courseMatches =
            classCourseId?.toString() ==
                studentCourseId?.toString();

        final semesterMatches =
            classSemester == null ||
            classSemester.toString().isEmpty ||
            classSemester.toString() ==
                studentSemester?.toString();

        if (courseMatches && semesterMatches) {
          studentClass = classData;
          break;
        }
      }

      if (studentClass == null) {
        throw Exception(
          'Student class not found.',
        );
      }

      final classId =
          studentClass['class_id'] ??
          studentClass['id'];

      if (classId == null) {
        throw Exception(
          'Student class ID not found.',
        );
      }

      final filteredExams =
          examData.where((item) {
        if (item is! Map) {
          return false;
        }

        final exam =
            Map<String, dynamic>.from(item);

        final examClassId =
            exam['class_id'] ??
            exam['classId'];

        return examClassId?.toString() ==
            classId.toString();
      }).toList();

      if (!mounted) {
        return;
      }

      setState(() {
        exams = filteredExams;
        subjects = subjectData;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load exam schedule.';
      });
    }
  }

  String getSubjectName(
    Map<String, dynamic> exam,
  ) {
    final subjectId =
        exam['subject_id'] ??
        exam['subjectId'];

    for (final item in subjects) {
      if (item is! Map) {
        continue;
      }

      final subject =
          Map<String, dynamic>.from(item);

      final currentSubjectId =
          subject['subject_id'] ??
          subject['id'];

      if (currentSubjectId?.toString() ==
          subjectId?.toString()) {
        return (
          subject['subject_name'] ??
          subject['name'] ??
          subject['title'] ??
          'Unknown Subject'
        ).toString();
      }
    }

    return subjectId == null
        ? 'Unknown Subject'
        : 'Subject ID: $subjectId';
  }

  String formatDate(dynamic value) {
    if (value == null) {
      return 'Date not available';
    }

    final date =
        DateTime.tryParse(value.toString());

    if (date == null) {
      return value.toString();
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  String formatTime(dynamic value) {
    if (value == null) {
      return '--';
    }

    final text = value.toString();
    final parts = text.split(':');

    if (parts.length < 2) {
      return text;
    }

    final hour =
        int.tryParse(parts[0]) ?? 0;

    final minute =
        int.tryParse(parts[1]) ?? 0;

    final period =
        hour >= 12 ? 'PM' : 'AM';

    final displayHour =
        hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:'
        '${minute.toString().padLeft(2, '0')} '
        '$period';
  }

  String getTimeRange(
    Map<String, dynamic> exam,
  ) {
    final startTime =
        formatTime(exam['start_time']);

    final endTime =
        formatTime(exam['end_time']);

    return '$startTime - $endTime';
  }

  Widget buildExamCard(
    Map<String, dynamic> exam,
  ) {
    final subjectName =
        getSubjectName(exam);

    final examName =
        (exam['exam_name'] ??
                exam['name'] ??
                'Exam')
            .toString();

    final examDate =
        formatDate(exam['exam_date']);

    final timeRange =
        getTimeRange(exam);

    final roomNo =
        (exam['room_no'] ??
                exam['room'] ??
                exam['venue'] ??
                '')
            .toString();

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.all(14),
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
          padding:
              const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(examName),
              const SizedBox(height: 4),
              Text(
                'Date: $examDate',
              ),
              const SizedBox(height: 2),
              Text(
                'Time: $timeRange',
              ),
              if (roomNo.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'Room: $roomNo',
                ),
              ],
            ],
          ),
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 50,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                textAlign:
                    TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed:
                    loadExamSchedule,
                child:
                    const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (exams.isEmpty) {
      return RefreshIndicator(
        onRefresh:
            loadExamSchedule,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 60,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No exams scheduled.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Your exam schedule will appear here.',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh:
          loadExamSchedule,
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(16),
        itemCount: exams.length,
        itemBuilder:
            (context, index) {
          final exam =
              Map<String, dynamic>.from(
            exams[index] as Map,
          );

          return buildExamCard(exam);
        },
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Exam Schedule'),
      ),
      body: buildBody(),
    );
  }
}