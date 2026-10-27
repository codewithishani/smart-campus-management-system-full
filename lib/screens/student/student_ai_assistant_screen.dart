import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StudentAiAssistantScreen extends StatefulWidget {
  final int studentId;

  const StudentAiAssistantScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentAiAssistantScreen> createState() =>
      _StudentAiAssistantScreenState();
}

class _StudentAiAssistantScreenState
    extends State<StudentAiAssistantScreen> {
  final TextEditingController controller = TextEditingController();

  final List<Map<String, String>> messages = [];

  bool isProcessing = false;

  Map<String, dynamic>? student;

  List<dynamic> attendanceData = [];
  List<dynamic> assignmentData = [];
  List<dynamic> submissionData = [];
  List<dynamic> resultData = [];
  List<dynamic> timetableData = [];
  List<dynamic> noticeData = [];
  List<dynamic> eventData = [];

  @override
  void initState() {
    super.initState();

    messages.add({
      'sender': 'AI',
      'message':
          'Hello! I am your Smart Campus Assistant. I can answer questions using your current campus data.',
    });

    loadStudentData();
  }

  Future<void> loadStudentData() async {
    try {
      final results = await Future.wait([
        ApiService.getStudent(widget.studentId),
        ApiService.getAttendance(),
        ApiService.getAssignments(),
        ApiService.getSubmissions(),
        ApiService.getResults(),
        ApiService.getTimetable(),
        ApiService.getNotices(),
        ApiService.getEvents(),
      ]);

      if (!mounted) return;

      final studentResult = results[0];
      if (studentResult is Map) {
        student = Map<String, dynamic>.from(studentResult);
      }

      final attendanceResult = results[1];
      if (attendanceResult is List) {
        attendanceData = attendanceResult;
      }

      final assignmentResult = results[2];
      if (assignmentResult is List) {
        assignmentData = assignmentResult;
      }

      final submissionResult = results[3];
      if (submissionResult is List) {
        submissionData = submissionResult;
      }

      final resultResult = results[4];
      if (resultResult is List) {
        resultData = resultResult;
      }

      final timetableResult = results[5];
      if (timetableResult is List) {
        timetableData = timetableResult;
      }

      final noticeResult = results[6];
      if (noticeResult is List) {
        noticeData = noticeResult;
      }

      final eventResult = results[7];
      if (eventResult is List) {
        eventData = eventResult;
      }

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      setState(() {
        messages.add({
          'sender': 'AI',
          'message':
              'I could not load your latest campus data. Please try again.',
        });
      });
    }
  }

  int? toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(
      value?.toString() ?? '',
    );
  }

  List<Map<String, dynamic>> getStudentAttendance() {
    return attendanceData
        .where((item) {
          if (item is! Map) return false;

          final record = Map<String, dynamic>.from(item);

          return toInt(
                record['student_id'] ?? record['studentId'],
              ) ==
              widget.studentId;
        })
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }

  List<Map<String, dynamic>> getStudentSubmissions() {
    return submissionData
        .where((item) {
          if (item is! Map) return false;

          final record = Map<String, dynamic>.from(item);

          return toInt(
                record['student_id'] ?? record['studentId'],
              ) ==
              widget.studentId;
        })
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }

  List<Map<String, dynamic>> getStudentResults() {
    return resultData
        .where((item) {
          if (item is! Map) return false;

          final record = Map<String, dynamic>.from(item);

          return toInt(
                record['student_id'] ?? record['studentId'],
              ) ==
              widget.studentId;
        })
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }

  int countPresent(
    List<Map<String, dynamic>> attendance,
  ) {
    int count = 0;

    for (final record in attendance) {
      final status =
          (record['status'] ?? '').toString().toLowerCase();

      if (record['is_present'] == true ||
          record['present'] == true ||
          status == 'present' ||
          status == 'p' ||
          status == 'attended') {
        count++;
      }
    }

    return count;
  }

  double getAttendancePercentage() {
    final attendance = getStudentAttendance();

    if (attendance.isEmpty) {
      return 0;
    }

    return (countPresent(attendance) / attendance.length) * 100;
  }

  String getStudentName() {
    return student?['name']?.toString() ?? 'Student';
  }

  String answerQuestion(String question) {
    final text = question.toLowerCase().trim();

    if (student == null) {
      return 'Your student data is still loading. Please try again in a moment.';
    }

    if (text.contains('hello') ||
        text == 'hi' ||
        text.contains('hey')) {
      return 'Hello ${getStudentName()}! What would you like to know about your campus data?';
    }

    if (text.contains('attendance')) {
      final attendance = getStudentAttendance();

      if (attendance.isEmpty) {
        return 'I could not find any attendance records for your student account.';
      }

      final present = countPresent(attendance);
      final percentage = getAttendancePercentage();

      return 'Your current attendance is '
          '${percentage.toStringAsFixed(1)}%. '
          'You are marked present in $present out of '
          '${attendance.length} attendance records.';
    }

    if (text.contains('assignment') ||
        text.contains('homework')) {
      final submissions = getStudentSubmissions();

      final submittedIds = <int>{};

      for (final submission in submissions) {
        final assignmentId = toInt(
          submission['assignment_id'] ??
              submission['assignmentId'],
        );

        if (assignmentId != null) {
          submittedIds.add(assignmentId);
        }
      }

      final total = assignmentData.length;

      int submitted = 0;

      for (final assignment in assignmentData) {
        if (assignment is! Map) continue;

        final data = Map<String, dynamic>.from(
          assignment,
        );

        final assignmentId = toInt(
          data['assignment_id'] ??
              data['assignmentId'],
        );

        if (assignmentId != null &&
            submittedIds.contains(assignmentId)) {
          submitted++;
        }
      }

      return 'I found $total assignments in the system. '
          'You have submitted $submitted of them based on your submission records.';
    }

    if (text.contains('result') ||
        text.contains('marks') ||
        text.contains('grade')) {
      final results = getStudentResults();

      if (results.isEmpty) {
        return 'No examination result records were found for your student account.';
      }

      double obtained = 0;
      double total = 0;

      for (final result in results) {
        final marks = double.tryParse(
              (result['marks_obtained'] ??
                      result['marksObtained'] ??
                      result['marks'] ??
                      '')
                  .toString(),
            ) ??
            0;

        final totalMarks = double.tryParse(
              (result['total_marks'] ??
                      result['totalMarks'] ??
                      result['max_marks'] ??
                      result['maximum_marks'] ??
                      '')
                  .toString(),
            ) ??
            0;

        obtained += marks;
        total += totalMarks;
      }

      if (total == 0) {
        return 'I found ${results.length} result records, but the available records do not contain usable total marks.';
      }

      final percentage = (obtained / total) * 100;

      return 'You have ${results.length} result records. '
          'Your calculated marks percentage from those records is '
          '${percentage.toStringAsFixed(1)}%.';
    }

    if (text.contains('exam') ||
        text.contains('examination')) {
      return 'Your exam schedule is available in the Exam Schedule section. '
          'The system currently has ${resultData.length} result records for all students.';
    }

    if (text.contains('timetable') ||
        text.contains('schedule') ||
        text.contains('class')) {
      return 'Your timetable is available in the Timetable section. '
          'Open that section to see your current class schedule.';
    }

    if (text.contains('notice') ||
        text.contains('announcement')) {
      return 'There are currently ${noticeData.length} notices available in the Smart Campus system. '
          'Open Notices to read the latest announcements.';
    }

    if (text.contains('event')) {
      return 'There are currently ${eventData.length} campus events available in the Smart Campus system. '
          'Open Campus Events for their dates, timings and venues.';
    }

    if (text.contains('complaint')) {
      return 'You can submit a complaint from the Complaints section. '
          'After submission, use Complaint Status to track your complaint.';
    }

    if (text.contains('performance')) {
      final attendance = getAttendancePercentage();

      final results = getStudentResults();

      return 'Your current attendance is '
          '${attendance.toStringAsFixed(1)}%, '
          'and you have ${results.length} examination result records. '
          'For the complete performance calculation, open Performance Insights.';
    }

    if (text.contains('profile') ||
        text.contains('my name') ||
        text.contains('who am i')) {
      return 'You are ${getStudentName()}. '
          'Your student ID is ${widget.studentId}.';
    }

    if (text.contains('help')) {
      return 'You can ask me about your attendance, assignments, results, '
          'performance, profile, timetable, notices, events, exams, or complaints.';
    }

    return 'I can currently answer questions using your Smart Campus data. '
        'Try asking about your attendance, assignments, results, performance, '
        'profile, timetable, notices, events, exams, or complaints.';
  }

  void sendMessage() {
    final text = controller.text.trim();

    if (text.isEmpty || isProcessing) {
      return;
    }

    setState(() {
      messages.add({
        'sender': 'You',
        'message': text,
      });

      isProcessing = true;
    });

    controller.clear();

    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        if (!mounted) return;

        final response = answerQuestion(text);

        setState(() {
          messages.add({
            'sender': 'AI',
            'message': response,
          });

          isProcessing = false;
        });
      },
    );
  }

  Widget buildMessage(
    Map<String, String> message,
  ) {
    final isUser = message['sender'] == 'You';

    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 340,
        ),
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUser
                          ? Icons.person
                          : Icons.smart_toy,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      message['sender'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  message['message'] ?? '',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildQuickQuestions() {
    final questions = [
      'What is my attendance?',
      'How many assignments have I submitted?',
      'Show my results',
      'What is my performance?',
      'What is my student ID?',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        4,
        12,
        8,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: questions.map((question) {
          return ActionChip(
            label: Text(question),
            onPressed: isProcessing
                ? null
                : () {
                    controller.text = question;
                    sendMessage();
                  },
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessage(
                  messages[index],
                );
              },
            ),
          ),
          if (isProcessing)
            const Padding(
              padding: EdgeInsets.only(
                bottom: 8,
              ),
              child: Text(
                'Assistant is processing your data...',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
          buildQuickQuestions(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                10,
                4,
                10,
                10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textInputAction:
                          TextInputAction.send,
                      decoration:
                          const InputDecoration(
                        hintText: 'Ask something...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) =>
                          sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: isProcessing
                        ? null
                        : sendMessage,
                    icon: const Icon(
                      Icons.send,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}