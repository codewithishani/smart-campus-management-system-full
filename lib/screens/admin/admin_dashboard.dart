import 'package:flutter/material.dart';
import '../../widgets/logout_button.dart';

import 'admin_profile_screen.dart';
import 'student_management_screen.dart';
import 'faculty_management_screen.dart';
import 'parent_management_screen.dart';
import 'user_management_screen.dart';
import 'role_permissions_screen.dart';
import 'department_management_screen.dart';
import 'course_subject_management_screen.dart';
import 'class_management_screen.dart';
import 'academic_data_management_screen.dart';
import 'notice_management_screen.dart';
import 'event_management_screen.dart';
import 'complaint_management_screen.dart';
import 'notification_management_screen.dart';
import 'reports_analytics_screen.dart';
import 'admin_ai_assistant_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      {
        'title': 'Admin Profile',
        'icon': Icons.admin_panel_settings_outlined,
        'screen': const AdminProfileScreen(),
      },
      {
        'title': 'Student Management',
        'icon': Icons.school_outlined,
        'screen': const StudentManagementScreen(),
      },
      {
        'title': 'Faculty Management',
        'icon': Icons.people_outline,
        'screen': const FacultyManagementScreen(),
      },
      {
        'title': 'Parent Management',
        'icon': Icons.family_restroom_outlined,
        'screen': const ParentManagementScreen(),
      },
      {
        'title': 'User Management',
        'icon': Icons.manage_accounts_outlined,
        'screen': const UserManagementScreen(),
      },
      {
        'title': 'Role & Permissions',
        'icon': Icons.security_outlined,
        'screen': const RolePermissionsScreen(),
      },
      {
        'title': 'Department Management',
        'icon': Icons.business_outlined,
        'screen': const DepartmentManagementScreen(),
      },
      {
        'title': 'Course & Subjects',
        'icon': Icons.menu_book_outlined,
        'screen': const CourseSubjectManagementScreen(),
      },
      {
        'title': 'Class Management',
        'icon': Icons.class_outlined,
        'screen': const ClassManagementScreen(),
      },
      {
        'title': 'Academic Data',
        'icon': Icons.assessment_outlined,
        'screen': const AcademicDataManagementScreen(),
      },
      {
        'title': 'Notice Management',
        'icon': Icons.campaign_outlined,
        'screen': const NoticeManagementScreen(),
      },
      {
        'title': 'Event Management',
        'icon': Icons.event_outlined,
        'screen': const EventManagementScreen(),
      },
      {
        'title': 'Complaint Management',
        'icon': Icons.report_problem_outlined,
        'screen': const ComplaintManagementScreen(),
      },
      {
        'title': 'Notification Management',
        'icon': Icons.notifications_outlined,
        'screen': const NotificationManagementScreen(),
      },
      {
        'title': 'Reports & Analytics',
        'icon': Icons.analytics_outlined,
        'screen': const ReportsAnalyticsScreen(),
      },
      {
        'title': 'AI Admin Assistant',
        'icon': Icons.smart_toy_outlined,
        'screen': const AdminAiAssistantScreen(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationManagementScreen(),
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
                  builder: (_) => const AdminProfileScreen(),
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
              'Hello, Admin 👋',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 5),
            Text(
              'Manage and monitor the Smart Campus system',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 18),

            // Administrator information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      child: Icon(
                        Icons.admin_panel_settings_outlined,
                        size: 34,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'System Administrator',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text('Admin ID: A001'),
                          SizedBox(height: 2),
                          Text('Administration Department'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'System Overview',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.45,
              ),
              children: const [
                _OverviewCard(
                  title: 'Students',
                  value: '500',
                  subtitle: 'Registered students',
                  icon: Icons.school_outlined,
                ),
                _OverviewCard(
                  title: 'Faculty',
                  value: '40',
                  subtitle: 'Teaching staff',
                  icon: Icons.people_outline,
                ),
                _OverviewCard(
                  title: 'Departments',
                  value: '25',
                  subtitle: 'Active departments',
                  icon: Icons.business_outlined,
                ),
                _OverviewCard(
                  title: 'Events',
                  value: '12',
                  subtitle: 'Campus events',
                  icon: Icons.event_outlined,
                ),
              ],
            ),

            const SizedBox(height: 22),

            const Text(
              'Administration Services',
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
              'System Update',
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
                  child: Icon(Icons.analytics_outlined),
                ),
                title: const Text(
                  'Campus Management Overview',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    'System data and administrative services are available in demo mode.',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              child: Icon(icon),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
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