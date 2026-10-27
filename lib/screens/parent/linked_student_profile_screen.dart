
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class LinkedStudentProfileScreen extends StatefulWidget {
  final int parentId;

  const LinkedStudentProfileScreen({
    super.key,
    required this.parentId,
  });

  @override
  State<LinkedStudentProfileScreen> createState() =>
      _LinkedStudentProfileScreenState();
}

class _LinkedStudentProfileScreenState
    extends State<LinkedStudentProfileScreen> {
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> departments = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadStudentProfiles();
  }

  Future<void> loadStudentProfiles() async {
    try {
      final data = await Future.wait([
        ApiService.getParentStudentLinks(),
        ApiService.getStudents(),
        ApiService.getCourses(),
        ApiService.getDepartments(),
      ]);

      final links = data[0];
      final studentData = data[1];
      final courseData = data[2];
      final departmentData = data[3];

      final linkedStudentIds = <int>[];

      for (final item in links) {
        if (item is! Map) continue;

        final link = Map<String, dynamic>.from(item);

        final linkedParentId = getIntValue(
          link,
          ['parent_id'],
        );

        if (linkedParentId != widget.parentId) {
          continue;
        }

        final studentId = getIntValue(
          link,
          ['student_id'],
        );

        if (studentId > 0 &&
            !linkedStudentIds.contains(studentId)) {
          linkedStudentIds.add(studentId);
        }
      }

      final foundStudents = <Map<String, dynamic>>[];

      for (final item in studentData) {
        if (item is! Map) continue;

        final student = Map<String, dynamic>.from(item);

        final studentId = getIntValue(
          student,
          ['student_id', 'id'],
        );

        if (linkedStudentIds.contains(studentId)) {
          foundStudents.add(student);
        }
      }

      final foundCourses = <Map<String, dynamic>>[];

      for (final item in courseData) {
        if (item is! Map) continue;

        foundCourses.add(
          Map<String, dynamic>.from(item),
        );
      }

      final foundDepartments = <Map<String, dynamic>>[];

      for (final item in departmentData) {
        if (item is! Map) continue;

        foundDepartments.add(
          Map<String, dynamic>.from(item),
        );
      }

      if (!mounted) return;

      setState(() {
        students = foundStudents;
        courses = foundCourses;
        departments = foundDepartments;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load linked student profile.';
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

  Map<String, dynamic>? findCourse(
    Map<String, dynamic> student,
  ) {
    final courseId = getIntValue(
      student,
      ['course_id'],
    );

    if (courseId == 0) {
      return null;
    }

    for (final course in courses) {
      final id = getIntValue(
        course,
        ['course_id', 'id'],
      );

      if (id == courseId) {
        return course;
      }
    }

    return null;
  }

  Map<String, dynamic>? findDepartment(
    Map<String, dynamic> student,
    Map<String, dynamic>? course,
  ) {
    int departmentId = getIntValue(
      student,
      ['department_id'],
    );

    if (departmentId == 0 && course != null) {
      departmentId = getIntValue(
        course,
        ['department_id'],
      );
    }

    if (departmentId == 0) {
      return null;
    }

    for (final department in departments) {
      final id = getIntValue(
        department,
        ['department_id', 'id'],
      );

      if (id == departmentId) {
        return department;
      }
    }

    return null;
  }

  String getStudentName(
    Map<String, dynamic> student,
  ) {
    return getStringValue(
      student,
      ['name'],
      defaultValue: 'Student',
    );
  }

  String getStudentId(
    Map<String, dynamic> student,
  ) {
    final studentId = getIntValue(
      student,
      ['student_id', 'id'],
    );

    return studentId == 0
        ? 'Not available'
        : studentId.toString();
  }

  String getCourseName(
    Map<String, dynamic> student,
    Map<String, dynamic>? course,
  ) {
    if (course != null) {
      return getStringValue(
        course,
        [
          'course_name',
          'name',
          'title',
        ],
      );
    }

    return getStringValue(
      student,
      ['course_name'],
    );
  }

  String getSemester(
    Map<String, dynamic> student,
  ) {
    final value = student['semester'];

    if (value == null ||
        value.toString().trim().isEmpty) {
      return 'Not available';
    }

    final semester = value.toString();

    return semester
            .toLowerCase()
            .contains('semester')
        ? semester
        : 'Semester $semester';
  }

  String getRollNumber(
    Map<String, dynamic> student,
  ) {
    return getStringValue(
      student,
      ['roll_no'],
    );
  }

  String getDepartmentName(
    Map<String, dynamic> student,
    Map<String, dynamic>? department,
  ) {
    if (department != null) {
      return getStringValue(
        department,
        [
          'department_name',
          'name',
        ],
      );
    }

    return getStringValue(
      student,
      ['department_name'],
    );
  }

  Widget buildItem(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
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
                  'Unable to load student profile.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });

                loadStudentProfiles();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStudentCard(
    Map<String, dynamic> student,
  ) {
    final course = findCourse(student);

    final department = findDepartment(
      student,
      course,
    );

    return Card(
      margin: const EdgeInsets.only(
        bottom: 24,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 48,
              child: Icon(
                Icons.school,
                size: 52,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              getStudentName(student),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 22),

            buildItem(
              'Student ID',
              getStudentId(student),
              Icons.badge_outlined,
            ),

            buildItem(
              'Roll Number',
              getRollNumber(student),
              Icons.format_list_numbered,
            ),

            buildItem(
              'Course',
              getCourseName(
                student,
                course,
              ),
              Icons.school_outlined,
            ),

            buildItem(
              'Department',
              getDepartmentName(
                student,
                department,
              ),
              Icons.account_balance_outlined,
            ),

            buildItem(
              'Semester',
              getSemester(student),
              Icons.calendar_today_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfile() {
    if (students.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadStudentProfiles,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 100),
            Icon(
              Icons.person_off_outlined,
              size: 70,
            ),
            SizedBox(height: 18),
            Text(
              'No linked student found.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This parent account does not currently have a linked student.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadStudentProfiles,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          30,
        ),
        children: [
          Text(
            students.length == 1
                ? 'Linked Student'
                : 'Linked Students',
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            students.length == 1
                ? 'Student information linked to your parent account.'
                : '${students.length} students are linked to your parent account.',
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 18),

          ...students.map(
            (student) => buildStudentCard(student),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Linked Student Profile',
        ),
      ),
      body: isLoading
          ? buildLoading()
          : errorMessage != null
              ? buildError()
              : buildProfile(),
    );
  }
}

