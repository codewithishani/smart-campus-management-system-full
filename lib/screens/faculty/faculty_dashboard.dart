import 'package:flutter/material.dart';

import '../../services/api_service.dart';
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

class FacultyDashboard extends StatefulWidget {
  final int facultyId;

  const FacultyDashboard({
    super.key,
    required this.facultyId,
  });

  static int? currentFacultyId;

  @override
  State<FacultyDashboard> createState() =>
      _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {
  Map<String, dynamic>? faculty;

  bool isLoading = true;
  String? errorMessage;

  int facultyStudentCount = 0;
  int facultyClassCount = 0;

  String departmentName = 'Department not available';

  @override
  void initState() {
    super.initState();

    FacultyDashboard.currentFacultyId = widget.facultyId;

    loadFaculty();
  }

  // ============================================================
  // LOAD FACULTY DASHBOARD DATA
  // ============================================================

  Future<void> loadFaculty() async {
    try {
      final results = await Future.wait([
        ApiService.getFaculty(),
        ApiService.getStudents(),
        ApiService.getClasses(),
        ApiService.getTimetable(),
        ApiService.getDepartments(),
      ]);

      final facultyList = results[0];
      final students = results[1];
      final classes = results[2];
      final timetable = results[3];
      final departments = results[4];

      // ==========================================================
      // FIND LOGGED-IN FACULTY
      // ==========================================================

      Map<String, dynamic>? currentFaculty;

      for (final item in facultyList) {
        if (item is! Map) {
          continue;
        }

        final facultyData =
            Map<String, dynamic>.from(item);

        final idValue =
            facultyData['faculty_id'] ??
                facultyData['id'];

        final facultyDatabaseId = idValue is int
            ? idValue
            : int.tryParse(
                idValue?.toString() ?? '',
              );

        if (facultyDatabaseId == widget.facultyId) {
          currentFaculty = facultyData;
          break;
        }
      }

      if (currentFaculty == null) {
        if (!mounted) {
          return;
        }

        setState(() {
          isLoading = false;
          errorMessage =
              'Faculty information not found.';
        });

        return;
      }

      // ==========================================================
      // GET FACULTY DEPARTMENT
      // ==========================================================

      final departmentIdValue =
          currentFaculty['department_id'] ??
              currentFaculty['departmentId'];

      final facultyDepartmentId =
          departmentIdValue is int
              ? departmentIdValue
              : int.tryParse(
                  departmentIdValue?.toString() ?? '',
                );

      String currentDepartmentName =
          'Department not available';

      if (facultyDepartmentId != null) {
        for (final item in departments) {
          if (item is! Map) {
            continue;
          }

          final department =
              Map<String, dynamic>.from(item);

          final idValue =
              department['department_id'] ??
                  department['id'];

          final databaseDepartmentId =
              idValue is int
                  ? idValue
                  : int.tryParse(
                      idValue?.toString() ?? '',
                    );

          if (databaseDepartmentId ==
              facultyDepartmentId) {
            currentDepartmentName =
                (
                  department['department_name'] ??
                      department['name'] ??
                      'Department not available'
                ).toString();

            break;
          }
        }
      }

      // ==========================================================
      // FIND FACULTY'S CLASSES
      //
      // A class belongs to faculty if:
      // 1. Faculty is class teacher
      // OR
      // 2. Faculty teaches that class in timetable
      // ==========================================================

      final Set<int> facultyClassIds = {};

      // ----------------------------------------------------------
      // CLASS TEACHER CLASSES
      // ----------------------------------------------------------

      for (final item in classes) {
        if (item is! Map) {
          continue;
        }

        final classData =
            Map<String, dynamic>.from(item);

        final teacherValue =
            classData['class_teacher_id'] ??
                classData['classTeacherId'];

        final classTeacherId = teacherValue is int
            ? teacherValue
            : int.tryParse(
                teacherValue?.toString() ?? '',
              );

        if (classTeacherId != widget.facultyId) {
          continue;
        }

        final classIdValue =
            classData['class_id'] ??
                classData['id'];

        final classId = classIdValue is int
            ? classIdValue
            : int.tryParse(
                classIdValue?.toString() ?? '',
              );

        if (classId != null) {
          facultyClassIds.add(classId);
        }
      }

      // ----------------------------------------------------------
      // TIMETABLE CLASSES
      // ----------------------------------------------------------

      for (final item in timetable) {
        if (item is! Map) {
          continue;
        }

        final timetableData =
            Map<String, dynamic>.from(item);

        final facultyValue =
            timetableData['faculty_id'] ??
                timetableData['facultyId'];

        final timetableFacultyId =
            facultyValue is int
                ? facultyValue
                : int.tryParse(
                    facultyValue?.toString() ?? '',
                  );

        if (timetableFacultyId != widget.facultyId) {
          continue;
        }

        final classValue =
            timetableData['class_id'] ??
                timetableData['classId'];

        final classId = classValue is int
            ? classValue
            : int.tryParse(
                classValue?.toString() ?? '',
              );

        if (classId != null) {
          facultyClassIds.add(classId);
        }
      }

      // ==========================================================
      // COUNT FACULTY CLASSES
      // ==========================================================

      final List<Map<String, dynamic>>
          facultyClasses = [];

      for (final item in classes) {
        if (item is! Map) {
          continue;
        }

        final classData =
            Map<String, dynamic>.from(item);

        final classIdValue =
            classData['class_id'] ??
                classData['id'];

        final classId = classIdValue is int
            ? classIdValue
            : int.tryParse(
                classIdValue?.toString() ?? '',
              );

        if (classId != null &&
            facultyClassIds.contains(classId)) {
          facultyClasses.add(classData);
        }
      }

      final int classCount =
          facultyClasses.length;

      // ==========================================================
      // FIND COURSE + SEMESTER FOR FACULTY CLASSES
      //
      // Student table doesn't have class_id.
      // Therefore we use:
      //
      // student.course_id
      // student.semester
      //
      // against:
      //
      // class.course_id
      // class.semester
      // ==========================================================

      final Set<String> facultyCourseSemesterPairs =
          {};

      for (final classData in facultyClasses) {
        final courseValue =
            classData['course_id'] ??
                classData['courseId'];

        final semesterValue =
            classData['semester'];

        final courseId = courseValue is int
            ? courseValue
            : int.tryParse(
                courseValue?.toString() ?? '',
              );

        final semester = semesterValue is int
            ? semesterValue
            : int.tryParse(
                semesterValue?.toString() ?? '',
              );

        if (courseId != null &&
            semester != null) {
          facultyCourseSemesterPairs.add(
            '$courseId-$semester',
          );
        }
      }

      // ==========================================================
      // COUNT STUDENTS
      // ==========================================================

      final Set<int> countedStudentIds = {};

      for (final item in students) {
        if (item is! Map) {
          continue;
        }

        final student =
            Map<String, dynamic>.from(item);

        final studentIdValue =
            student['student_id'] ??
                student['id'];

        final studentId = studentIdValue is int
            ? studentIdValue
            : int.tryParse(
                studentIdValue?.toString() ?? '',
              );

        final studentCourseValue =
            student['course_id'] ??
                student['courseId'];

        final studentSemesterValue =
            student['semester'];

        final studentCourseId =
            studentCourseValue is int
                ? studentCourseValue
                : int.tryParse(
                    studentCourseValue?.toString() ?? '',
                  );

        final studentSemester =
            studentSemesterValue is int
                ? studentSemesterValue
                : int.tryParse(
                    studentSemesterValue?.toString() ?? '',
                  );

        if (studentId == null ||
            studentCourseId == null ||
            studentSemester == null) {
          continue;
        }

        final studentPair =
            '$studentCourseId-$studentSemester';

        if (facultyCourseSemesterPairs
            .contains(studentPair)) {
          countedStudentIds.add(studentId);
        }
      }

      final int studentCount =
          countedStudentIds.length;

      // ==========================================================
      // UPDATE UI
      // ==========================================================

      if (!mounted) {
        return;
      }

      setState(() {
        faculty = currentFaculty;
        departmentName = currentDepartmentName;
        facultyStudentCount = studentCount;
        facultyClassCount = classCount;
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
            'Unable to load faculty information.';
      });
    }
  }

  // ============================================================
  // FACULTY DETAILS
  // ============================================================

  String getFacultyName() {
    if (faculty == null) {
      return 'Faculty';
    }

    return (
      faculty!['name'] ??
          faculty!['faculty_name'] ??
          faculty!['full_name'] ??
          'Faculty'
    ).toString();
  }

  String getFacultyCode() {
    if (faculty == null) {
      return 'Faculty ID ${widget.facultyId}';
    }

    return (
      faculty!['faculty_code'] ??
          faculty!['faculty_id_code'] ??
          faculty!['employee_id'] ??
          'Faculty ID ${widget.facultyId}'
    ).toString();
  }

  String getDepartment() {
    return departmentName;
  }

  // ============================================================
  // FACULTY MODULES
  // ============================================================

  List<Map<String, dynamic>> get modules => [
        {
          'title': 'Faculty Profile',
          'icon': Icons.person_outline,
          'screen': FacultyProfileScreen(
            facultyId: widget.facultyId,
          ),
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
          'screen':
              const FacultyAssignmentManagementScreen(),
        },
        {
          'title': 'Submission Review',
          'icon': Icons.fact_check_outlined,
          'screen':
              const FacultySubmissionReviewScreen(),
        },
        {
          'title': 'Marks Management',
          'icon': Icons.grade_outlined,
          'screen':
              const FacultyMarksManagementScreen(),
        },
        {
          'title': 'Notice Publishing',
          'icon': Icons.campaign_outlined,
          'screen':
              const FacultyNoticePublishingScreen(),
        },
        {
          'title': 'Leave Requests',
          'icon': Icons.event_available_outlined,
          'screen':
              const FacultyLeaveRequestsScreen(),
        },
        {
          'title': 'Student Performance',
          'icon': Icons.insights_outlined,
          'screen':
              const FacultyStudentPerformanceScreen(),
        },
        {
          'title': 'AI Faculty Assistant',
          'icon': Icons.smart_toy_outlined,
          'screen':
              const FacultyAiAssistantScreen(),
        },
      ];

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  Future<void> showNotifications() async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return const FacultyNotificationsDialog();
      },
    );
  }

  // ============================================================
  // LOADING STATE
  // ============================================================

  Widget buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget buildErrorState() {
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
                  'Unable to load faculty information.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });

                loadFaculty();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(
              Icons.notifications_outlined,
            ),
            onPressed: showNotifications,
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
                      FacultyProfileScreen(
                    facultyId: widget.facultyId,
                  ),
                ),
              );
            },
          ),
          const LogoutButton(),
        ],
      ),
      body: isLoading
          ? buildLoadingState()
          : errorMessage != null
              ? buildErrorState()
              : buildDashboard(),
    );
  }

  // ============================================================
  // DASHBOARD UI
  // ============================================================

  Widget buildDashboard() {
    return SingleChildScrollView(
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
            'Hello, ${getFacultyName()} 👋',
            style: Theme.of(context)
                .textTheme
                .headlineMedium,
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

          // ======================================================
          // FACULTY INFORMATION
          // ======================================================

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
                          getFacultyName(),
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'Faculty ID: ${getFacultyCode()}',
                        ),

                        const SizedBox(height: 2),

                        Text(
                          getDepartment(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ======================================================
          // TEACHING OVERVIEW
          // ======================================================

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
                  value:
                      facultyStudentCount.toString(),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _overviewCard(
                  icon: Icons.class_outlined,
                  title: 'Classes',
                  value:
                      facultyClassCount.toString(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ======================================================
          // FACULTY SERVICES
          // ======================================================

          const Text(
            'Faculty Services',
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
                          style: const TextStyle(
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

          // ======================================================
          // QUICK INFORMATION
          // ======================================================

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
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: const CircleAvatar(
                child: Icon(
                  Icons.campaign_outlined,
                ),
              ),
              title: const Text(
                'Latest Academic Update',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Padding(
                padding:
                    EdgeInsets.only(top: 5),
                child: Text(
                  'Semester examination preparation and student performance review are in progress.',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OVERVIEW CARD
  // ============================================================

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

// ================================================================
// FACULTY NOTIFICATIONS DIALOG
// ================================================================

class FacultyNotificationsDialog
    extends StatefulWidget {
  const FacultyNotificationsDialog({
    super.key,
  });

  @override
  State<FacultyNotificationsDialog> createState() =>
      _FacultyNotificationsDialogState();
}

class _FacultyNotificationsDialogState
    extends State<FacultyNotificationsDialog> {
  bool isLoading = true;
  String? errorMessage;

  List<dynamic> notifications = [];

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data =
          await ApiService.getNotifications();

      if (!mounted) {
        return;
      }

      setState(() {
        notifications =
            List<dynamic>.from(data);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load notifications.';
      });
    }
  }

  String getString(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  String getTitle(
    Map<String, dynamic> notification,
  ) {
    final title = getString(
      notification['title'] ??
          notification['notification_title'] ??
          notification['name'],
    );

    return title.isEmpty
        ? 'Notification'
        : title;
  }

  String getMessage(
    Map<String, dynamic> notification,
  ) {
    final message = getString(
      notification['message'] ??
          notification['description'] ??
          notification['body'] ??
          notification['content'],
    );

    return message.isEmpty
        ? 'No message available.'
        : message;
  }

  String getDate(
    Map<String, dynamic> notification,
  ) {
    final date = getString(
      notification['created_at'] ??
          notification['notification_date'] ??
          notification['created_date'] ??
          notification['date'],
    );

    if (date.isEmpty) {
      return '';
    }

    final parsedDate =
        DateTime.tryParse(date);

    if (parsedDate == null) {
      return date;
    }

    final day = parsedDate.day
        .toString()
        .padLeft(2, '0');

    final month = parsedDate.month
        .toString()
        .padLeft(2, '0');

    final year =
        parsedDate.year.toString();

    final hour = parsedDate.hour
        .toString()
        .padLeft(2, '0');

    final minute = parsedDate.minute
        .toString()
        .padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  bool isUnread(
    Map<String, dynamic> notification,
  ) {
    final value =
        notification['is_read'] ??
            notification['read'] ??
            notification['read_status'];

    if (value is bool) {
      return !value;
    }

    if (value is int) {
      return value == 0;
    }

    if (value is String) {
      final lower =
          value.toLowerCase();

      if (lower == 'true' ||
          lower == 'read' ||
          lower == '1') {
        return false;
      }

      if (lower == 'false' ||
          lower == 'unread' ||
          lower == '0') {
        return true;
      }
    }

    return false;
  }

  int getUnreadCount() {
    return notifications.where((item) {
      if (item is! Map) {
        return false;
      }

      return isUnread(
        Map<String, dynamic>.from(item),
      );
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount =
        getUnreadCount();

    return AlertDialog(
      titlePadding:
          const EdgeInsets.fromLTRB(
        20,
        18,
        12,
        8,
      ),
      contentPadding:
          const EdgeInsets.fromLTRB(
        12,
        8,
        12,
        12,
      ),
      title: Row(
        children: [
          const Expanded(
            child: Text(
              'Notifications',
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          if (unreadCount > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Text(
                '$unreadCount unread',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

          IconButton(
            tooltip: 'Refresh',
            onPressed: isLoading
                ? null
                : loadNotifications,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        height: 480,
        child: isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 50,
                          color: Colors.red,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          errorMessage!,
                          textAlign:
                              TextAlign.center,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        ElevatedButton.icon(
                          onPressed:
                              loadNotifications,
                          icon: const Icon(
                            Icons.refresh,
                          ),
                          label: const Text(
                            'Retry',
                          ),
                        ),
                      ],
                    ),
                  )
                : notifications.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Icon(
                              Icons
                                  .notifications_none,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(
                              height: 14,
                            ),
                            Text(
                              'No notifications',
                              style:
                                  TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              'You are all caught up.',
                              textAlign:
                                  TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount:
                            notifications.length,
                        separatorBuilder:
                            (_, _) =>
                                const Divider(
                          height: 1,
                        ),
                        itemBuilder:
                            (context, index) {
                          final item =
                              notifications[index];

                          if (item is! Map) {
                            return const SizedBox
                                .shrink();
                          }

                          final notification =
                              Map<String, dynamic>
                                  .from(item);

                          final unread =
                              isUnread(
                            notification,
                          );

                          final title =
                              getTitle(
                            notification,
                          );

                          final message =
                              getMessage(
                            notification,
                          );

                          final date =
                              getDate(
                            notification,
                          );

                          return Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                            decoration:
                                BoxDecoration(
                              color: unread
                                  ? Colors.blue
                                      .withValues(
                                      alpha: 0.06,
                                    )
                                  : null,
                              borderRadius:
                                  BorderRadius
                                      .circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                CircleAvatar(
                                  radius: 21,
                                  child: Icon(
                                    unread
                                        ? Icons
                                            .notifications
                                        : Icons
                                            .notifications_none,
                                    size: 21,
                                  ),
                                ),

                                const SizedBox(
                                  width: 12,
                                ),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Expanded(
                                            child:
                                                Text(
                                              title,
                                              style:
                                                  TextStyle(
                                                fontWeight:
                                                    unread
                                                        ? FontWeight.bold
                                                        : FontWeight.w600,
                                                fontSize:
                                                    15,
                                              ),
                                            ),
                                          ),

                                          if (unread)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration:
                                                  const BoxDecoration(
                                                color:
                                                    Colors.red,
                                                shape:
                                                    BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),

                                      const SizedBox(
                                        height: 5,
                                      ),

                                      Text(
                                        message,
                                        style:
                                            TextStyle(
                                          fontSize:
                                              13,
                                          color: Colors
                                              .grey
                                              .shade700,
                                        ),
                                      ),

                                      if (date
                                          .isNotEmpty) ...[
                                        const SizedBox(
                                          height: 7,
                                        ),
                                        Text(
                                          date,
                                          style:
                                              TextStyle(
                                            fontSize:
                                                11,
                                            color: Colors
                                                .grey
                                                .shade600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}