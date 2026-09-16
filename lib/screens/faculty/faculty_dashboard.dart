import 'package:flutter/material.dart';
import '../../widgets/logout_button.dart';

import 'faculty_profile_screen.dart';
import 'faculty_class_subjects_screen.dart';
import 'faculty_student_list_screen.dart';
import 'faculty_attendance_screen.dart';
import 'faculty_notes_upload_screen.dart';
import 'faculty_assignment_management_screen.dart';
import 'faculty_submission_review_screen.dart';
import 'faculty_marks_management_screen.dart';
import 'faculty_notice_publishing_screen.dart';
import 'faculty_leave_requests_screen.dart';
import 'faculty_student_performance_screen.dart';
import 'faculty_ai_assistant_screen.dart';

class FacultyDashboard extends StatelessWidget {
  const FacultyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      {
        'title': 'Faculty Profile',
        'icon': Icons.person_outline,
        'screen': const FacultyProfileScreen(),
      },
      {
        'title': 'Class & Subjects',
        'icon': Icons.menu_book_outlined,
        'screen': const FacultyClassSubjectsScreen(),
      },
      {
        'title': 'Student List',
        'icon': Icons.people_outline,
        'screen': const FacultyStudentListScreen(),
      },
      {
        'title': 'Attendance Management',
        'icon': Icons.calendar_month_outlined,
        'screen': const FacultyAttendanceScreen(),
      },
      {
        'title': 'Notes Upload',
        'icon': Icons.upload_file_outlined,
        'screen': const FacultyNotesUploadScreen(),
      },
      {
        'title': 'Assignment Management',
        'icon': Icons.assignment_outlined,
        'screen': const FacultyAssignmentManagementScreen(),
      },
      {
        'title': 'Submission Review',
        'icon': Icons.fact_check_outlined,
        'screen': const FacultySubmissionReviewScreen(),
      },
      {
        'title': 'Marks Management',
        'icon': Icons.grade_outlined,
        'screen': const FacultyMarksManagementScreen(),
      },
      {
        'title': 'Notice Publishing',
        'icon': Icons.campaign_outlined,
        'screen': const FacultyNoticePublishingScreen(),
      },
      {
        'title': 'Leave Requests',
        'icon': Icons.event_available_outlined,
        'screen': const FacultyLeaveRequestsScreen(),
      },
      {
        'title': 'Student Performance',
        'icon': Icons.insights_outlined,
        'screen': const FacultyStudentPerformanceScreen(),
      },
      {
        'title': 'AI Faculty Assistant',
        'icon': Icons.smart_toy_outlined,
        'screen': const FacultyAiAssistantScreen(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Dashboard'),
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
                  builder: (_) => const FacultyProfileScreen(),
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
              'Hello, Faculty 👋',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 5),
            Text(
              'Welcome to your Smart Campus workspace',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 18),

            // Faculty information
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
                            'Dr. Priya Sharma',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text('Faculty ID: F001'),
                          SizedBox(height: 2),
                          Text('Computer Applications Department'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Faculty overview
            const Text(
              'Teaching Overview',
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
                    icon: Icons.people_outline,
                    title: 'Students',
                    value: '120',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _overviewCard(
                    icon: Icons.class_outlined,
                    title: 'Classes',
                    value: '4',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            const Text(
              'Faculty Services',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Faculty services
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

            // Quick information
            const Text(
              'Quick Information',
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
                  child: Icon(Icons.campaign_outlined),
                ),
                title: const Text(
                  'Latest Academic Update',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    'Semester examination preparation and student performance review are in progress.',
                  ),
                ),
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