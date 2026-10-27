import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../widgets/logout_button.dart';

import 'student_profile_screen.dart';
import 'student_attendance_screen.dart';
import 'student_timetable_screen.dart';
import 'student_subjects_screen.dart';
import 'student_notes_screen.dart';
import 'student_assignments_screen.dart';
import 'student_submission_screen.dart';
import 'student_assignment_status_screen.dart';
import 'student_results_screen.dart';
import 'student_exam_schedule_screen.dart';
import 'student_notices_screen.dart';
import 'student_events_screen.dart';
import 'student_complaints_screen.dart';
import 'student_complaint_status_screen.dart';
import 'student_notifications_screen.dart';
import 'student_performance_screen.dart';
import 'student_ai_assistant_screen.dart';
import 'student_study_recommendations_screen.dart';

class StudentDashboard extends StatefulWidget {
  final int studentId;

  const StudentDashboard({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentDashboard> createState() =>
      _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  Map<String, dynamic>? studentData;

  List<dynamic> attendanceData = [];
  List<dynamic> resultsData = [];
  List<dynamic> noticesData = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final results = await Future.wait([
        ApiService.getStudent(widget.studentId),
        ApiService.getAttendance(),
        ApiService.getResults(),
        ApiService.getNotices(),
      ]);

      if (!mounted) return;

      final student = Map<String, dynamic>.from(
        results[0] as Map,
      );

      final attendance = results[1] as List<dynamic>;
      final resultRecords = results[2] as List<dynamic>;
      final notices = results[3] as List<dynamic>;

      setState(() {
        studentData = student;

        attendanceData = attendance.whereType<Map>().where((item) {
          final record =
              Map<String, dynamic>.from(item);

          final recordStudentId =
              record['student_id'] ??
              record['studentId'];

          return recordStudentId?.toString() ==
              widget.studentId.toString();
        }).toList();

        resultsData = resultRecords.where((item) {
          if (item is! Map) return false;

          final record =
              Map<String, dynamic>.from(item);

          final recordStudentId =
              record['student_id'] ??
              record['studentId'];

          return recordStudentId?.toString() ==
              widget.studentId.toString();
        }).toList();

        noticesData = notices;

        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load student dashboard.';
      });
    }
  }

  int get presentCount {
    return attendanceData.where((item) {
      if (item is! Map) return false;

      final record =
          Map<String, dynamic>.from(item);

      final status =
          (record['status'] ?? '')
              .toString()
              .trim()
              .toLowerCase();

      return record['is_present'] == true ||
          record['present'] == true ||
          status == 'present' ||
          status == 'p' ||
          status == 'attended';
    }).length;
  }

  int get attendanceTotal {
    return attendanceData.length;
  }

  int get attendancePercentage {
    if (attendanceTotal == 0) return 0;

    return ((presentCount / attendanceTotal) * 100)
        .round();
  }

  String getCgpa() {
    if (resultsData.isEmpty) {
      return 'N/A';
    }

    double total = 0;
    int count = 0;

    for (final item in resultsData) {
      if (item is! Map) continue;

      final result =
          Map<String, dynamic>.from(item);

      final value = result['cgpa'] ??
          result['gpa'] ??
          result['grade_point'] ??
          result['gradePoint'];

      if (value != null) {
        final number =
            double.tryParse(value.toString());

        if (number != null) {
          total += number;
          count++;
        }
      }
    }

    if (count == 0) {
      return 'N/A';
    }

    return (total / count).toStringAsFixed(2);
  }

  Map<String, dynamic>? get latestNotice {
    if (noticesData.isEmpty) {
      return null;
    }

    final sorted = noticesData
        .whereType<Map>()
        .map(
          (item) =>
              Map<String, dynamic>.from(item),
        )
        .toList();

    if (sorted.isEmpty) {
      return null;
    }

    sorted.sort((a, b) {
      final aDate = DateTime.tryParse(
            (a['created_at'] ??
                    a['notice_date'] ??
                    a['date'] ??
                    '')
                .toString(),
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0);

      final bDate = DateTime.tryParse(
            (b['created_at'] ??
                    b['notice_date'] ??
                    b['date'] ??
                    '')
                .toString(),
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0);

      return bDate.compareTo(aDate);
    });

    return sorted.first;
  }

  String getNoticeTitle() {
    final notice = latestNotice;

    if (notice == null) {
      return 'No notices available';
    }

    return (notice['title'] ??
            notice['notice_title'] ??
            notice['subject'] ??
            'Notice')
        .toString();
  }

  String getNoticeDescription() {
    final notice = latestNotice;

    if (notice == null) {
      return 'There are no notices available at the moment.';
    }

    return (notice['description'] ??
            notice['content'] ??
            notice['message'] ??
            'Open Notices to view details.')
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Student Dashboard'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
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
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });

                    loadDashboard();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final studentName =
        studentData?['name'] ?? 'Student';

    final studentSemester =
        studentData?['semester']?.toString() ?? '';

    final studentRollNo =
        studentData?['roll_no']?.toString() ?? '';

    final modules = [
      {
        'title': 'Student Profile',
        'icon': Icons.person_outline,
        'screen': StudentProfileScreen(
          studentId: widget.studentId,
        ),
      },
      {
        'title': 'Attendance',
        'icon': Icons.calendar_month_outlined,
        'screen': StudentAttendanceScreen(
          studentId: widget.studentId,
        ),
      },
      {
        'title': 'Timetable',
        'icon': Icons.schedule_outlined,
        'screen': StudentTimetableScreen(
          studentId: widget.studentId,
        ),
      },
      {
        'title': 'Subjects',
        'icon': Icons.menu_book_outlined,
        'screen': StudentSubjectsScreen(
          studentId: widget.studentId,
        ),
      },
      {
        'title': 'Notes & Resources',
        'icon': Icons.description_outlined,
        'screen': StudentNotesScreen(
          studentId: widget.studentId,
        ),
      },
      {
        'title': 'Assignments',
        'icon': Icons.assignment_outlined,
        'screen': StudentAssignmentsScreen(
          studentId: widget.studentId,
        ),
      },
      {
        'title': 'Assignment Submission',
        'icon': Icons.upload_file_outlined,
        'screen': StudentSubmissionScreen(
          studentId: widget.studentId,
        ),
      },
      {
        'title': 'Assignment Status',
        'icon': Icons.assignment_turned_in_outlined,
        'screen': StudentAssignmentStatusScreen(
          studentId: widget.studentId,
        ),
      },
      {
        'title': 'Results & Marks',
        'icon': Icons.grade_outlined,
        'screen': StudentResultsScreen(
          studentId: widget.studentId,
        ),
      },
      {
        'title': 'Exam Schedule',
        'icon': Icons.event_note_outlined,
        'screen': StudentExamScheduleScreen(
          studentId: widget.studentId,
        ),
      },
      {
        'title': 'Notices',
        'icon': Icons.campaign_outlined,
        'screen': const StudentNoticesScreen(),
      },
      {
        'title': 'Campus Events',
        'icon': Icons.event_outlined,
        'screen': const StudentEventsScreen(),
      },
      {
        'title': 'Complaints',
        'icon': Icons.report_problem_outlined,
        'screen': StudentComplaintsScreen(
          studentId: widget.studentId,
        ),
      },
      {
        'title': 'Complaint Status',
        'icon': Icons.track_changes_outlined,
        'screen': StudentComplaintStatusScreen(
          studentId: widget.studentId,
        ),
      },
      {
        'title': 'Notifications',
        'icon': Icons.notifications_outlined,
        'screen': StudentNotificationsScreen(
          studentId: widget.studentId,
        ),
      },
      {
        'title': 'Performance Insights',
        'icon': Icons.insights_outlined,
        'screen': StudentPerformanceScreen(
          studentId: widget.studentId,
        ),
      },
      {
        'title': 'AI Assistant',
        'icon': Icons.smart_toy_outlined,
        'screen': StudentAiAssistantScreen(
          studentId: widget.studentId,
        ),
      },
      {
        'title': 'Study Recommendations',
        'icon': Icons.lightbulb_outline,
        'screen': StudentStudyRecommendationsScreen(
          studentId: widget.studentId,
        ),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(
              Icons.notifications_outlined,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      StudentNotificationsScreen(
                    studentId: widget.studentId,
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(
              Icons.account_circle_outlined,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      StudentProfileScreen(
                    studentId: widget.studentId,
                  ),
                ),
              );
            },
          ),
          const LogoutButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadDashboard,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            16,
            18,
            16,
            28,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $studentName 👋',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium,
              ),
              const SizedBox(height: 5),
              Text(
                'Welcome back to Smart Campus',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 32,
                        child: Icon(
                          Icons.person,
                          size: 34,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              studentName.toString(),
                              style:
                                  const TextStyle(
                                fontSize: 19,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Student ID: ${widget.studentId}',
                            ),
                            if (studentRollNo.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Roll No: $studentRollNo',
                              ),
                            ],
                            if (studentSemester.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Semester $studentSemester',
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Academic Overview',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _overviewCard(
                      icon:
                          Icons.calendar_month_outlined,
                      title: 'Attendance',
                      value:
                          '$attendancePercentage%',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _overviewCard(
                      icon: Icons.grade_outlined,
                      title: 'CGPA',
                      value: getCgpa(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'Student Services',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: modules.length,
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
                itemBuilder:
                    (context, index) {
                  final module =
                      modules[index];

                  return Card(
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                module['screen']
                                    as Widget,
                          ),
                        );
                      },
                      child: Padding(
                        padding:
                            const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 27,
                              child: Icon(
                                module['icon']
                                    as IconData,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              module['title']
                                  as String,
                              textAlign:
                                  TextAlign.center,
                              style:
                                  const TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 22),
              const Text(
                'Latest Notice',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading:
                      const CircleAvatar(
                    child: Icon(
                      Icons
                          .notifications_active_outlined,
                    ),
                  ),
                  title: Text(
                    getNoticeTitle(),
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 5,
                    ),
                    child: Text(
                      getNoticeDescription(),
                    ),
                  ),
                  trailing:
                      const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const StudentNoticesScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _overviewCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              child: Icon(icon),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style:
                        const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}