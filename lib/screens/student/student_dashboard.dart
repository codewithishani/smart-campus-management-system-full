import 'package:flutter/material.dart';
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
import 'student_performance_screen.dart';
import 'student_ai_assistant_screen.dart';
import 'student_study_recommendations_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      {
        'title': 'Student Profile',
        'icon': Icons.person_outline,
        'screen': const StudentProfileScreen(),
      },
      {
        'title': 'Attendance',
        'icon': Icons.calendar_month_outlined,
        'screen': const StudentAttendanceScreen(),
      },
      {
        'title': 'Timetable',
        'icon': Icons.schedule_outlined,
        'screen': const StudentTimetableScreen(),
      },
      {
        'title': 'Subjects',
        'icon': Icons.menu_book_outlined,
        'screen': const StudentSubjectsScreen(),
      },
      {
        'title': 'Notes & Resources',
        'icon': Icons.description_outlined,
        'screen': const StudentNotesScreen(),
      },
      {
        'title': 'Assignments',
        'icon': Icons.assignment_outlined,
        'screen': const StudentAssignmentsScreen(),
      },
      {
        'title': 'Assignment Submission',
        'icon': Icons.upload_file_outlined,
        'screen': const StudentSubmissionScreen(),
      },
      {
        'title': 'Assignment Status',
        'icon': Icons.assignment_turned_in_outlined,
        'screen': const StudentAssignmentStatusScreen(),
      },
      {
        'title': 'Results & Marks',
        'icon': Icons.grade_outlined,
        'screen': const StudentResultsScreen(),
      },
      {
        'title': 'Exam Schedule',
        'icon': Icons.event_note_outlined,
        'screen': const StudentExamScheduleScreen(),
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
        'screen': const StudentComplaintsScreen(),
      },
      {
        'title': 'Complaint Status',
        'icon': Icons.track_changes_outlined,
        'screen': const StudentComplaintStatusScreen(),
      },
      {
        'title': 'Performance Insights',
        'icon': Icons.insights_outlined,
        'screen': const StudentPerformanceScreen(),
      },
      {
        'title': 'AI Assistant',
        'icon': Icons.smart_toy_outlined,
        'screen': const StudentAiAssistantScreen(),
      },
      {
        'title': 'Study Recommendations',
        'icon': Icons.lightbulb_outline,
        'screen': const StudentStudyRecommendationsScreen(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications are in demo mode.'),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentProfileScreen(),
                ),
              );
            },
          ),
          const LogoutButton(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, Rahul 👋',
              style: Theme.of(context).textTheme.headlineMedium,
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

            // Student information card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Rahul Patil',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text('Student ID: S001'),
                          SizedBox(height: 2),
                          Text('BCA • Semester 5 • Division A'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Academic overview
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
                    icon: Icons.calendar_month_outlined,
                    title: 'Attendance',
                    value: '85%',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _overviewCard(
                    icon: Icons.grade_outlined,
                    title: 'CGPA',
                    value: '8.2',
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

            // Student modules
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: modules.length,
              gridDelegate:
                  const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (context, index) {
                final module = modules[index];

                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => module['screen'] as Widget,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 27,
                            child: Icon(
                              module['icon'] as IconData,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            module['title'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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

            // Latest notice
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: const CircleAvatar(
                  child: Icon(Icons.notifications_active_outlined),
                ),
                title: const Text(
                  'Semester Examination',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    'Semester examinations will begin from 10 October 2026.',
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StudentNoticesScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
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
        padding: const EdgeInsets.symmetric(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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