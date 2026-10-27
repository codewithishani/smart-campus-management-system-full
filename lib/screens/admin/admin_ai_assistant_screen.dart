import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminAiAssistantScreen extends StatefulWidget {
  const AdminAiAssistantScreen({super.key});

  @override
  State<AdminAiAssistantScreen> createState() =>
      _AdminAiAssistantScreenState();
}

class _AdminAiAssistantScreenState
    extends State<AdminAiAssistantScreen> {
  final TextEditingController _controller =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  final List<Map<String, String>> messages = [
    {
      'sender': 'AI',
      'message':
          'Hello Admin! I am your Smart Campus AI Assistant. I can answer questions using your real campus database.',
    },
  ];

  bool _isProcessing = false;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();

    if (text.isEmpty || _isProcessing) {
      return;
    }

    setState(() {
      messages.add({
        'sender': 'Admin',
        'message': text,
      });

      _isProcessing = true;
    });

    _controller.clear();
    _scrollToBottom();

    final response = await _generateResponse(text);

    if (!mounted) {
      return;
    }

    setState(() {
      messages.add({
        'sender': 'AI',
        'message': response,
      });

      _isProcessing = false;
    });

    _scrollToBottom();
  }

  Future<String> _generateResponse(
    String question,
  ) async {
    final query = question.toLowerCase().trim();

    try {
      final data = await Future.wait([
        ApiService.getStudents(),
        ApiService.getFaculty(),
        ApiService.getParents(),
        ApiService.getDepartments(),
        ApiService.getCourses(),
        ApiService.getSubjects(),
        ApiService.getClasses(),
        ApiService.getAttendance(),
        ApiService.getAssignments(),
        ApiService.getSubmissions(),
        ApiService.getResults(),
        ApiService.getNotices(),
        ApiService.getEvents(),
        ApiService.getComplaints(),
        ApiService.getLeaveRequests(),
        ApiService.getNotifications(),
        ApiService.getUsers(),
      ]);

      final students = data[0];
      final faculty = data[1];
      final parents = data[2];
      final departments = data[3];
      final courses = data[4];
      final subjects = data[5];
      final classes = data[6];
      final attendance = data[7];
      final assignments = data[8];
      final submissions = data[9];
      final results = data[10];
      final notices = data[11];
      final events = data[12];
      final complaints = data[13];
      final leaveRequests = data[14];
      final notifications = data[15];
      final users = data[16];

      if (query.contains('student') ||
          query.contains('students')) {
        if (query.contains('count') ||
            query.contains('how many') ||
            query.contains('total')) {
          return 'There are ${students.length} students registered in the Smart Campus database.';
        }

        return 'The Smart Campus database currently contains '
            '${students.length} students, '
            '${faculty.length} faculty members, and '
            '${parents.length} parents.';
      }

      if (query.contains('faculty') ||
          query.contains('teacher') ||
          query.contains('teachers')) {
        return 'There are ${faculty.length} faculty members registered in the Smart Campus database.';
      }

      if (query.contains('parent') ||
          query.contains('parents')) {
        return 'There are ${parents.length} parent accounts registered in the Smart Campus database.';
      }

      if (query.contains('attendance') ||
          query.contains('present') ||
          query.contains('absent')) {
        int present = 0;
        int absent = 0;
        int other = 0;

        for (final item in attendance) {
          if (item is! Map) {
            continue;
          }

          final record = Map<String, dynamic>.from(item);

          final status =
              (record['status'] ??
                      record['attendance_status'] ??
                      '')
                  .toString()
                  .toLowerCase()
                  .trim();

          if (status == 'present' ||
              status == 'p' ||
              status == 'true') {
            present++;
          } else if (status == 'absent' ||
              status == 'a' ||
              status == 'false') {
            absent++;
          } else {
            other++;
          }
        }

        final recorded = present + absent;

        if (recorded == 0) {
          return 'I could not find usable present/absent attendance records in the database.';
        }

        final percentage = (present / recorded) * 100;

        return 'Campus attendance summary:\n\n'
            'Present records: $present\n'
            'Absent records: $absent\n'
            'Other records: $other\n'
            'Total usable records: $recorded\n'
            'Overall attendance percentage: '
            '${percentage.toStringAsFixed(1)}%';
      }

      if (query.contains('assignment') ||
          query.contains('assignments')) {
        return 'There are ${assignments.length} assignments in the database and '
            '${submissions.length} submission records.';
      }

      if (query.contains('submission') ||
          query.contains('submissions')) {
        return 'The Smart Campus database contains '
            '${submissions.length} submission records for '
            '${assignments.length} assignments.';
      }

      if (query.contains('result') ||
          query.contains('results') ||
          query.contains('marks') ||
          query.contains('academic')) {
        if (results.isEmpty) {
          return 'There are currently no examination result records in the database.';
        }

        double obtained = 0;
        double total = 0;
        int usableRecords = 0;

        for (final item in results) {
          if (item is! Map) {
            continue;
          }

          final result = Map<String, dynamic>.from(item);

          final obtainedValue = double.tryParse(
                (result['marks_obtained'] ??
                        result['marksObtained'] ??
                        result['marks'] ??
                        '')
                    .toString(),
              ) ??
              0;

          final totalValue = double.tryParse(
                (result['total_marks'] ??
                        result['totalMarks'] ??
                        result['max_marks'] ??
                        result['maximum_marks'] ??
                        '')
                    .toString(),
              ) ??
              0;

          if (totalValue > 0) {
            obtained += obtainedValue;
            total += totalValue;
            usableRecords++;
          }
        }

        if (total <= 0) {
          return 'There are ${results.length} result records in the database, but usable total-mark values were not found.';
        }

        final percentage = (obtained / total) * 100;

        return 'Academic result summary:\n\n'
            'Result records: ${results.length}\n'
            'Usable records: $usableRecords\n'
            'Calculated marks percentage: '
            '${percentage.toStringAsFixed(1)}%';
      }

      if (query.contains('notice') ||
          query.contains('notices')) {
        return 'There are ${notices.length} notices available in the Smart Campus database.';
      }

      if (query.contains('event') ||
          query.contains('events')) {
        return 'There are ${events.length} campus events available in the Smart Campus database.';
      }

      if (query.contains('complaint') ||
          query.contains('complaints')) {
        return 'There are ${complaints.length} complaint records in the Smart Campus database.';
      }

      if (query.contains('leave') ||
          query.contains('leaves')) {
        return 'There are ${leaveRequests.length} leave request records in the Smart Campus database.';
      }

      if (query.contains('notification') ||
          query.contains('notifications')) {
        return 'There are ${notifications.length} notification records in the Smart Campus database.';
      }

      if (query.contains('course') ||
          query.contains('courses')) {
        return 'There are ${courses.length} courses registered across '
            '${departments.length} departments.';
      }

      if (query.contains('subject') ||
          query.contains('subjects')) {
        return 'There are ${subjects.length} subjects registered in the Smart Campus database.';
      }

      if (query.contains('class') ||
          query.contains('classes') ||
          query.contains('division')) {
        return 'There are ${classes.length} classes registered in the Smart Campus database.';
      }

      if (query.contains('database') ||
          query.contains('campus data') ||
          query.contains('overview') ||
          query.contains('summary') ||
          query.contains('report')) {
        return 'Smart Campus database overview:\n\n'
            'Students: ${students.length}\n'
            'Faculty: ${faculty.length}\n'
            'Parents: ${parents.length}\n'
            'Departments: ${departments.length}\n'
            'Courses: ${courses.length}\n'
            'Subjects: ${subjects.length}\n'
            'Classes: ${classes.length}\n'
            'Attendance records: ${attendance.length}\n'
            'Assignments: ${assignments.length}\n'
            'Submissions: ${submissions.length}\n'
            'Results: ${results.length}\n'
            'Notices: ${notices.length}\n'
            'Events: ${events.length}\n'
            'Complaints: ${complaints.length}\n'
            'Leave requests: ${leaveRequests.length}\n'
            'Notifications: ${notifications.length}\n'
            'Users: ${users.length}';
      }

      if (query.contains('help') ||
          query.contains('what can you do') ||
          query.contains('how can you help')) {
        return 'I can answer questions using the Smart Campus database.\n\n'
            'You can ask me about:\n'
            '• Students\n'
            '• Faculty\n'
            '• Parents\n'
            '• Attendance\n'
            '• Assignments and submissions\n'
            '• Results and marks\n'
            '• Courses and subjects\n'
            '• Classes\n'
            '• Notices\n'
            '• Events\n'
            '• Complaints\n'
            '• Leave requests\n'
            '• Notifications\n'
            '• Overall campus statistics';
      }

      return 'I can search the real Smart Campus database for you.\n\n'
          'Try asking:\n'
          '• "How many students are there?"\n'
          '• "Show attendance summary."\n'
          '• "How many assignments are there?"\n'
          '• "How many complaints are there?"\n'
          '• "Show campus overview."\n'
          '• "How many faculty members are there?"';
    } catch (e) {
      return 'I could not retrieve the requested information from the backend. '
          'Please make sure the FastAPI server is running and try again.';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildMessage(
    Map<String, String> message,
  ) {
    final isAdmin = message['sender'] == 'Admin';

    return Align(
      alignment: isAdmin
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isAdmin
                        ? Icons.person
                        : Icons.smart_toy,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    message['sender']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                message['message']!,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickQuestion(
    String question,
  ) {
    return ActionChip(
      label: Text(question),
      onPressed: _isProcessing
          ? null
          : () {
              _controller.text = question;
              _sendMessage();
            },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Admin Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(
                  messages[index],
                );
              },
            ),
          ),

          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Checking campus database...',
                  ),
                ],
              ),
            ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            child: Row(
              children: [
                _buildQuickQuestion(
                  'How many students are there?',
                ),
                const SizedBox(width: 8),
                _buildQuickQuestion(
                  'Show attendance summary',
                ),
                const SizedBox(width: 8),
                _buildQuickQuestion(
                  'Show campus overview',
                ),
                const SizedBox(width: 8),
                _buildQuickQuestion(
                  'How many complaints are there?',
                ),
              ],
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      decoration: const InputDecoration(
                        hintText: 'Ask the AI Assistant...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed:
                        _isProcessing ? null : _sendMessage,
                    icon: const Icon(Icons.send),
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