
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
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

class ParentDashboard extends StatefulWidget {
  final int parentId;

  const ParentDashboard({
    super.key,
    required this.parentId,
  });

  @override
  State<ParentDashboard> createState() =>
      _ParentDashboardState();
}

class _ParentDashboardState
    extends State<ParentDashboard> {
  Map<String, dynamic>? parent;
  List<Map<String, dynamic>> linkedStudents = [];
  Map<String, dynamic>? latestNotice;

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
        ApiService.getParents(),
        ApiService.getParentStudentLinks(),
        ApiService.getStudents(),
        ApiService.getNotices(),
      ]);

      final parents = results[0];
      final links = results[1];
      final students = results[2];
      final notices = results[3];

      Map<String, dynamic>? foundParent;

      for (final item in parents) {
        if (item is! Map) continue;

        final data = Map<String, dynamic>.from(item);

        final parentId = getIntValue(
          data,
          ['parent_id', 'id'],
        );

        if (parentId == widget.parentId) {
          foundParent = data;
          break;
        }
      }

      if (foundParent == null) {
        throw Exception('Parent not found');
      }

      final studentIds = <int>[];

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

        if (studentId != 0 &&
            !studentIds.contains(studentId)) {
          studentIds.add(studentId);
        }
      }

      final resolvedStudents =
          <Map<String, dynamic>>[];

      for (final item in students) {
        if (item is! Map) continue;

        final student =
            Map<String, dynamic>.from(item);

        final studentId = getIntValue(
          student,
          ['student_id', 'id'],
        );

        if (studentIds.contains(studentId)) {
          resolvedStudents.add(student);
        }
      }

      Map<String, dynamic>? resolvedLatestNotice;

      final noticeList = <Map<String, dynamic>>[];

      for (final item in notices) {
        if (item is! Map) continue;

        final notice =
            Map<String, dynamic>.from(item);

        noticeList.add(notice);
      }

      noticeList.sort((a, b) {
        final aDate = DateTime.tryParse(
              getStringValue(
                a,
                ['publish_date', 'created_at'],
                defaultValue: '',
              ),
            ) ??
            DateTime.fromMillisecondsSinceEpoch(0);

        final bDate = DateTime.tryParse(
              getStringValue(
                b,
                ['publish_date', 'created_at'],
                defaultValue: '',
              ),
            ) ??
            DateTime.fromMillisecondsSinceEpoch(0);

        return bDate.compareTo(aDate);
      });

      if (noticeList.isNotEmpty) {
        resolvedLatestNotice = noticeList.first;
      }

      if (!mounted) return;

      setState(() {
        parent = foundParent;
        linkedStudents = resolvedStudents;
        latestNotice = resolvedLatestNotice;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load parent dashboard.';
      });
    }
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
    String defaultValue = 'Not available',
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

  String getParentName() {
    if (parent == null) {
      return 'Parent';
    }

    return getStringValue(
      parent!,
      ['name'],
      defaultValue: 'Parent',
    );
  }

  String getStudentSummary() {
    if (linkedStudents.isEmpty) {
      return 'No linked students found';
    }

    if (linkedStudents.length == 1) {
      return '1 registered student';
    }

    return '${linkedStudents.length} registered students';
  }

  String getLatestNoticeTitle() {
    if (latestNotice == null) {
      return 'No notices available';
    }

    return getStringValue(
      latestNotice!,
      ['title'],
      defaultValue: 'Campus Notice',
    );
  }

  String getLatestNoticeDescription() {
    if (latestNotice == null) {
      return 'No recent college announcements are available.';
    }

    return getStringValue(
      latestNotice!,
      ['description'],
      defaultValue:
          'Open Notices to view college announcements.',
    );
  }

  List<Map<String, dynamic>> buildModules() {
    return [
      {
        'title': 'Parent Profile',
        'icon': Icons.person_outline,
        'screen': ParentProfileScreen(
          parentId: widget.parentId,
        ),
      },
      {
        'title': 'Linked Student Profile',
        'icon': Icons.school_outlined,
        'screen': LinkedStudentProfileScreen(
          parentId: widget.parentId,
        ),
      },
      {
        'title': 'Attendance Monitoring',
        'icon': Icons.calendar_month_outlined,
        'screen': ParentAttendanceScreen(
          parentId: widget.parentId,
        ),
      },
      {
        'title': 'Timetable',
        'icon': Icons.schedule_outlined,
        'screen': ParentTimetableScreen(
          parentId: widget.parentId,
        ),
      },
      {
        'title': 'Assignment Status',
        'icon': Icons.assignment_turned_in_outlined,
        'screen': ParentAssignmentStatusScreen(
          widget.parentId,
        ),
      },
      {
        'title': 'Results & Marks',
        'icon': Icons.grade_outlined,
        'screen': ParentResultsScreen(
          parentId: widget.parentId,
        ),
      },
      {
        'title': 'Academic Performance',
        'icon': Icons.insights_outlined,
        'screen': ParentAcademicPerformanceScreen(
          widget.parentId,
        ),
      },
      {
        'title': 'Examination Schedule',
        'icon': Icons.event_note_outlined,
        'screen': ParentExamScheduleScreen(
          parentId: widget.parentId,
        ),
      },
      {
        'title': 'Notices',
        'icon': Icons.campaign_outlined,
        'screen': const ParentNoticesScreen(),
      },
      {
        'title': 'Leave Information',
        'icon': Icons.event_available_outlined,
        'screen': ParentLeaveInformationScreen(
          widget.parentId,
        ),
      },
      {
        'title': 'Notifications',
        'icon': Icons.notifications_outlined,
        'screen': ParentNotificationsScreen(
          parentId: widget.parentId,
        ),
      },
      {
        'title': 'Faculty Contact',
        'icon': Icons.contact_phone_outlined,
        'screen': ParentFacultyContactScreen(
          parentId: widget.parentId,
        ),
      },
    ];
  }

  void openScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  Widget buildOverviewCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
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
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDashboard() {
    final modules = buildModules();

    return RefreshIndicator(
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
              'Hello, ${getParentName()} 👋',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium,
            ),

            const SizedBox(height: 5),

            const Text(
              'Monitor your child\'s academic progress',
              style: TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 18),

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
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            getParentName(),
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Parent ID: ${widget.parentId}',
                          ),

                          const SizedBox(height: 2),

                          Text(
                            getStudentSummary(),
                          ),
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
                buildOverviewCard(
                  icon: Icons.calendar_month_outlined,
                  title: 'Attendance',
                  value: 'View',
                  onTap: () {
                    openScreen(
                      ParentAttendanceScreen(
                        parentId: widget.parentId,
                      ),
                    );
                  },
                ),

                const SizedBox(width: 10),

                buildOverviewCard(
                  icon: Icons.grade_outlined,
                  title: 'Results',
                  value: 'View',
                  onTap: () {
                    openScreen(
                      ParentResultsScreen(
                        parentId: widget.parentId,
                      ),
                    );
                  },
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
              itemBuilder: (context, index) {
                final module = modules[index];

                return Card(
                  child: InkWell(
                    borderRadius:
                        BorderRadius.circular(16),
                    onTap: () {
                      openScreen(
                        module['screen'] as Widget,
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
                            module['title'] as String,
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
              'Latest Update',
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
                leading: const CircleAvatar(
                  child: Icon(
                    Icons.notifications_active_outlined,
                  ),
                ),
                title: Text(
                  getLatestNoticeTitle(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding:
                      const EdgeInsets.only(top: 5),
                  child: Text(
                    getLatestNoticeDescription(),
                    maxLines: 3,
                    overflow:
                        TextOverflow.ellipsis,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),
                onTap: () {
                  openScreen(
                    const ParentNoticesScreen(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
                  'Unable to load dashboard.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });

                loadDashboard();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(
              Icons.notifications_outlined,
            ),
            onPressed: () {
              openScreen(
                ParentNotificationsScreen(
                  parentId: widget.parentId,
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
              openScreen(
                ParentProfileScreen(
                  parentId: widget.parentId,
                ),
              );
            },
          ),
          const LogoutButton(),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? buildError()
              : buildDashboard(),
    );
  }
}

