import 'package:flutter/material.dart';
import '../../widgets/logout_button.dart';

import 'parent_profile_screen.dart';
import 'linked_student_profile_screen.dart';
import 'parent_attendance_screen.dart';
import 'parent_timetable_screen.dart';
import 'parent_assignment_status_screen.dart';
import 'parent_results_screen.dart';
import 'parent_academic_performance_screen.dart';
import 'parent_exam_schedule_screen.dart';
import 'parent_notices_screen.dart';
import 'parent_leave_information_screen.dart';
import 'parent_notifications_screen.dart';
import 'parent_faculty_contact_screen.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      {
        'title': 'Parent Profile',
        'icon': Icons.person_outline,
        'screen': const ParentProfileScreen(),
      },
      {
        'title': 'Linked Student Profile',
        'icon': Icons.school_outlined,
        'screen': const LinkedStudentProfileScreen(),
      },
      {
        'title': 'Attendance Monitoring',
        'icon': Icons.calendar_month_outlined,
        'screen': const ParentAttendanceScreen(),
      },
      {
        'title': 'Timetable',
        'icon': Icons.schedule_outlined,
        'screen': const ParentTimetableScreen(),
      },
      {
        'title': 'Assignment Status',
        'icon': Icons.assignment_turned_in_outlined,
        'screen': const ParentAssignmentStatusScreen(),
      },
      {
        'title': 'Results & Marks',
        'icon': Icons.grade_outlined,
        'screen': const ParentResultsScreen(),
      },
      {
        'title': 'Academic Performance',
        'icon': Icons.insights_outlined,
        'screen': const ParentAcademicPerformanceScreen(),
      },
      {
        'title': 'Examination Schedule',
        'icon': Icons.event_note_outlined,
        'screen': const ParentExamScheduleScreen(),
      },
      {
        'title': 'Notices',
        'icon': Icons.campaign_outlined,
        'screen': const ParentNoticesScreen(),
      },
      {
        'title': 'Leave Information',
        'icon': Icons.event_available_outlined,
        'screen': const ParentLeaveInformationScreen(),
      },
      {
        'title': 'Notifications',
        'icon': Icons.notifications_outlined,
        'screen': const ParentNotificationsScreen(),
      },
      {
        'title': 'Faculty Contact',
        'icon': Icons.contact_phone_outlined,
        'screen': const ParentFacultyContactScreen(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ParentNotificationsScreen(),
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
                  builder: (_) => const ParentProfileScreen(),
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
              'Hello, Parent 👋',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 5),
            Text(
              'Monitor your child\'s academic progress',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 18),

            // Parent information
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
                            'Mr. Rajesh Patil',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text('Parent ID: P001'),
                          SizedBox(height: 2),
                          Text('Parent of Rahul Patil'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Linked student
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      child: Icon(
                        Icons.school_outlined,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Linked Student',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Rahul Patil',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text('BCA • Semester 5 • Student ID: S001'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

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
              'Parent Services',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

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

            const Text(
              'Latest Update',
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
                  child: Icon(
                    Icons.notifications_active_outlined,
                  ),
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
                      builder: (_) => const ParentNoticesScreen(),
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