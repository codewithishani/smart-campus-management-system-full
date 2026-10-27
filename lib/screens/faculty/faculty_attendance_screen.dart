import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'faculty_dashboard.dart';

class FacultyAttendanceScreen extends StatefulWidget {
  const FacultyAttendanceScreen({super.key});

  @override
  State<FacultyAttendanceScreen> createState() =>
      _FacultyAttendanceScreenState();
}

class _FacultyAttendanceScreenState
    extends State<FacultyAttendanceScreen> {
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> facultyClasses = [];
  List<Map<String, dynamic>> subjects = [];
  List<Map<String, dynamic>> attendanceRecords = [];
  List<Map<String, dynamic>> assignments = [];

  Map<int, bool> attendanceStatus = {};
  Map<int, int> existingAttendanceIds = {};

  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  DateTime selectedDate = DateTime.now();
  int? selectedSubjectId;

  int? get facultyId => FacultyDashboard.currentFacultyId;

  @override
  void initState() {
    super.initState();
    loadAttendanceData();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> loadAttendanceData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getStudents(),
        ApiService.getAttendance(),
        ApiService.getClasses(),
        ApiService.getSubjects(),
        ApiService.getAssignments(),
      ]);

      final studentData = results[0];
      final attendanceData = results[1];
      final classData = results[2];
      final subjectData = results[3];
      final assignmentData = results[4];

      if (facultyId == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          errorMessage =
              'Faculty session not found. Please login again.';
        });

        return;
      }

      final loadedClasses = getFacultyClassesFromData(
        classData,
        assignmentData,
      );

      final classIds = loadedClasses
          .map(getClassId)
          .whereType<int>()
          .toSet();

      final courseIds = loadedClasses
          .map(getClassCourseId)
          .whereType<int>()
          .toSet();

      final loadedStudents = <Map<String, dynamic>>[];

      for (final item in studentData) {
        if (item is! Map) continue;

        final student = Map<String, dynamic>.from(item);

        final studentClassId = getStudentClassId(student);

        final studentCourseId = getStudentCourseId(student);

        bool belongs = false;

        if (studentClassId != null &&
            classIds.contains(studentClassId)) {
          belongs = true;
        }

        if (!belongs &&
            studentCourseId != null &&
            courseIds.contains(studentCourseId)) {
          belongs = true;
        }

        if (belongs) {
          loadedStudents.add(student);
        }
      }

      final loadedSubjects = getFacultySubjects(
        subjectData,
        loadedClasses,
        assignmentData,
      );

      final loadedAttendance = attendanceData
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        students = loadedStudents;
        facultyClasses = loadedClasses;
        subjects = loadedSubjects;
        assignments = assignmentData
            .whereType<Map>()
            .map(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();
        attendanceRecords = loadedAttendance;
        isLoading = false;
        errorMessage = null;

        if (selectedSubjectId == null &&
            subjects.isNotEmpty) {
          selectedSubjectId = getSubjectId(subjects.first);
        }
      });

      loadExistingAttendance();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load attendance data.';
      });
    }
  }

  // ============================================================
  // ID HELPERS
  // ============================================================

  int? parseId(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value == null) {
      return null;
    }

    return int.tryParse(
      value.toString().trim(),
    );
  }

  int? getClassId(
    Map<String, dynamic> item,
  ) {
    return parseId(
      item['class_id'] ?? item['id'],
    );
  }

  int? getClassCourseId(
    Map<String, dynamic> item,
  ) {
    return parseId(
      item['course_id'],
    );
  }

  int? getClassFacultyId(
    Map<String, dynamic> item,
  ) {
    return parseId(
      item['class_teacher_id'] ??
          item['faculty_id'] ??
          item['teacher_id'] ??
          item['assigned_faculty_id'],
    );
  }

  int? getAssignmentFacultyId(
    Map<String, dynamic> item,
  ) {
    return parseId(
      item['faculty_id'] ??
          item['teacher_id'] ??
          item['created_by'] ??
          item['assigned_to'],
    );
  }

  int? getAssignmentClassId(
    Map<String, dynamic> item,
  ) {
    return parseId(
      item['class_id'],
    );
  }

  int? getAssignmentSubjectId(
    Map<String, dynamic> item,
  ) {
    return parseId(
      item['subject_id'],
    );
  }

  int? getStudentId(
    Map<String, dynamic> item,
  ) {
    return parseId(
      item['student_id'] ?? item['id'],
    );
  }

  int? getStudentClassId(
    Map<String, dynamic> item,
  ) {
    return parseId(
      item['class_id'] ?? item['classId'],
    );
  }

  int? getStudentCourseId(
    Map<String, dynamic> item,
  ) {
    return parseId(
      item['course_id'] ?? item['courseId'],
    );
  }

  int? getSubjectId(
    Map<String, dynamic> item,
  ) {
    return parseId(
      item['subject_id'] ?? item['id'],
    );
  }

  int? getSubjectClassId(
    Map<String, dynamic> item,
  ) {
    return parseId(
      item['class_id'],
    );
  }

  int? getSubjectCourseId(
    Map<String, dynamic> item,
  ) {
    return parseId(
      item['course_id'],
    );
  }

  // ============================================================
  // FACULTY CLASSES
  // ============================================================

  List<Map<String, dynamic>> getFacultyClassesFromData(
    List<dynamic> classData,
    List<dynamic> assignmentData,
  ) {
    final classIds = <int>{};

    for (final item in classData) {
      if (item is! Map) continue;

      final data = Map<String, dynamic>.from(item);

      final classId = getClassId(data);

      if (classId == null) continue;

      if (getClassFacultyId(data) == facultyId) {
        classIds.add(classId);
      }
    }

    // A faculty can teach a subject without
    // being the class teacher.
    for (final item in assignmentData) {
      if (item is! Map) continue;

      final data = Map<String, dynamic>.from(item);

      if (getAssignmentFacultyId(data) == facultyId) {
        final classId = getAssignmentClassId(data);

        if (classId != null) {
          classIds.add(classId);
        }
      }
    }

    final result = <Map<String, dynamic>>[];

    for (final item in classData) {
      if (item is! Map) continue;

      final data = Map<String, dynamic>.from(item);

      final classId = getClassId(data);

      if (classId != null &&
          classIds.contains(classId)) {
        result.add(data);
      }
    }

    return result;
  }

  // ============================================================
  // FACULTY SUBJECTS
  // ============================================================

  List<Map<String, dynamic>> getFacultySubjects(
    List<dynamic> subjectData,
    List<Map<String, dynamic>> classes,
    List<dynamic> assignmentData,
  ) {
    final classIds = classes
        .map(getClassId)
        .whereType<int>()
        .toSet();

    final courseIds = classes
        .map(getClassCourseId)
        .whereType<int>()
        .toSet();

    final facultySubjectIds = <int>{};

    for (final item in assignmentData) {
      if (item is! Map) continue;

      final data = Map<String, dynamic>.from(item);

      if (getAssignmentFacultyId(data) == facultyId) {
        final subjectId = getAssignmentSubjectId(data);

        if (subjectId != null) {
          facultySubjectIds.add(subjectId);
        }
      }
    }

    final result = <Map<String, dynamic>>[];

    final addedIds = <int>{};

    for (final item in subjectData) {
      if (item is! Map) continue;

      final subject = Map<String, dynamic>.from(item);

      final subjectId = getSubjectId(subject);

      final subjectClassId = getSubjectClassId(subject);

      final subjectCourseId = getSubjectCourseId(subject);

      bool belongs = false;

      if (subjectClassId != null &&
          classIds.contains(subjectClassId)) {
        belongs = true;
      }

      if (!belongs &&
          subjectCourseId != null &&
          courseIds.contains(subjectCourseId)) {
        belongs = true;
      }

      if (!belongs &&
          subjectId != null &&
          facultySubjectIds.contains(subjectId)) {
        belongs = true;
      }

      if (belongs) {
        if (subjectId != null &&
            addedIds.contains(subjectId)) {
          continue;
        }

        if (subjectId != null) {
          addedIds.add(subjectId);
        }

        result.add(subject);
      }
    }

    return result;
  }

  // ============================================================
  // ATTENDANCE DATE
  // ============================================================

  String getSelectedDateString() {
    final year = selectedDate.year.toString().padLeft(
          4,
          '0',
        );

    final month = selectedDate.month.toString().padLeft(
          2,
          '0',
        );

    final day = selectedDate.day.toString().padLeft(
          2,
          '0',
        );

    return '$year-$month-$day';
  }

  bool sameDate(
    dynamic value,
  ) {
    if (value == null) {
      return false;
    }

    final text = value.toString();

    return text.startsWith(
      getSelectedDateString(),
    );
  }

  // ============================================================
  // LOAD EXISTING ATTENDANCE
  // ============================================================

  void loadExistingAttendance() {
    attendanceStatus = {};
    existingAttendanceIds = {};

    if (selectedSubjectId == null) {
      for (final student in students) {
        final studentId = getStudentId(student);

        if (studentId != null) {
          attendanceStatus[studentId] = false;
        }
      }

      if (mounted) {
        setState(() {});
      }

      return;
    }

    for (final student in students) {
      final studentId = getStudentId(student);

      if (studentId == null) {
        continue;
      }

      attendanceStatus[studentId] = false;

      for (final record in attendanceRecords) {
        final recordStudentId = parseId(
          record['student_id'],
        );

        final recordSubjectId = parseId(
          record['subject_id'],
        );

        final recordAttendanceId = parseId(
          record['attendance_id'] ?? record['id'],
        );

        final recordDate = record['attendance_date'];

        if (recordStudentId == studentId &&
            recordSubjectId == selectedSubjectId &&
            sameDate(recordDate)) {
          existingAttendanceIds[studentId] =
              recordAttendanceId ?? 0;

          final status = (record['status'] ?? '')
              .toString()
              .toLowerCase();

          attendanceStatus[studentId] =
              status == 'present' ||
                  status == 'p' ||
                  status == 'true';

          break;
        }
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      selectedDate = picked;
    });

    loadExistingAttendance();
  }

  // ============================================================
  // SAVE ATTENDANCE
  // ============================================================

  Future<void> saveAttendance() async {
    if (facultyId == null) {
      return;
    }

    if (selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a subject.',
          ),
        ),
      );

      return;
    }

    if (students.isEmpty) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final date = getSelectedDateString();

      for (final student in students) {
        final studentId = getStudentId(student);

        if (studentId == null) {
          continue;
        }

        final present = attendanceStatus[studentId] ?? false;

        final status = present ? 'Present' : 'Absent';

        final existingId = existingAttendanceIds[studentId];

        if (existingId != null && existingId > 0) {
          await ApiService.updateAttendance(
            attendanceId: existingId,
            studentId: studentId,
            subjectId: selectedSubjectId!,
            facultyId: facultyId!,
            attendanceDate: date,
            status: status,
          );
        } else {
          await ApiService.createAttendance(
            studentId: studentId,
            subjectId: selectedSubjectId!,
            facultyId: facultyId!,
            attendanceDate: date,
            status: status,
          );
        }
      }

      final refreshed = await ApiService.getAttendance();

      if (!mounted) return;

      attendanceRecords = refreshed
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();

      setState(() {
        isSaving = false;
      });

      loadExistingAttendance();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Attendance saved successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save attendance: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // DISPLAY HELPERS
  // ============================================================

  String getClassName(
    Map<String, dynamic> item,
  ) {
    return (
      item['class_name'] ??
      item['name'] ??
      item['class_code'] ??
      'Class'
    ).toString();
  }

  String getSubjectName(
    Map<String, dynamic> item,
  ) {
    return (
      item['subject_name'] ??
      item['name'] ??
      item['subject_code'] ??
      'Subject'
    ).toString();
  }

  String getSubjectCode(
    Map<String, dynamic> item,
  ) {
    return (
      item['subject_code'] ?? ''
    ).toString();
  }

  String getStudentName(
    Map<String, dynamic> student,
  ) {
    return (
      student['name'] ??
      student['student_name'] ??
      student['full_name'] ??
      'Student'
    ).toString();
  }

  String getStudentDisplayId(
    Map<String, dynamic> student,
  ) {
    return (
      student['roll_no'] ??
      student['student_code'] ??
      student['enrollment_no'] ??
      student['student_id'] ??
      'N/A'
    ).toString();
  }

  int getPresentCount() {
    return attendanceStatus.values
        .where((value) => value)
        .length;
  }

  int getAbsentCount() {
    return students.length - getPresentCount();
  }

  // ============================================================
  // UI
  // ============================================================

  Widget buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 55,
            ),
            const SizedBox(
              height: 14,
            ),
            Text(
              errorMessage ??
                  'Unable to load attendance data.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 18,
            ),
            ElevatedButton.icon(
              onPressed: loadAttendanceData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNoSessionState() {
    return RefreshIndicator(
      onRefresh: loadAttendanceData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: 60,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Faculty session not found.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please login again.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNoClassState() {
    return RefreshIndicator(
      onRefresh: loadAttendanceData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.class_outlined,
                    size: 60,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No class is assigned.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No class connected to this faculty was found.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTopControls() {
    final subject = subjects.where(
      (item) => getSubjectId(item) == selectedSubjectId,
    );

    final selectedSubject =
        subject.isNotEmpty ? subject.first : null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButtonFormField<int>(
            initialValue: selectedSubjectId,
            decoration: const InputDecoration(
              labelText: 'Select Subject',
              border: OutlineInputBorder(),
              prefixIcon: Icon(
                Icons.menu_book_outlined,
              ),
            ),
            items: subjects.map(
              (subject) {
                final id = getSubjectId(subject);

                final name = getSubjectName(subject);

                final code = getSubjectCode(subject);

                return DropdownMenuItem<int>(
                  value: id,
                  child: Text(
                    code.isEmpty
                        ? name
                        : '$name ($code)',
                  ),
                );
              },
            ).toList(),
            onChanged: (value) {
              setState(() {
                selectedSubjectId = value;
              });

              loadExistingAttendance();
            },
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: selectDate,
            borderRadius: BorderRadius.circular(10),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Attendance Date',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.calendar_today,
                ),
              ),
              child: Text(
                getSelectedDateString(),
              ),
            ),
          ),
          if (selectedSubject != null)
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Subject: ${getSubjectName(selectedSubject)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildClassBanner() {
    final names = facultyClasses
        .map(getClassName)
        .join(', ');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        8,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.withValues(
          alpha: 0.08,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.school_outlined,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              'Assigned classes: $names',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStats() {
    return Card(
      margin: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        16,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _stat(
              'Present',
              getPresentCount(),
            ),
            _stat(
              'Absent',
              getAbsentCount(),
            ),
            _stat(
              'Total',
              students.length,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStudentCard(
    Map<String, dynamic> student,
  ) {
    final studentId = getStudentId(student);

    if (studentId == null) {
      return const SizedBox.shrink();
    }

    final name = getStudentName(student);

    final roll = getStudentDisplayId(student);

    final isPresent = attendanceStatus[studentId] ?? false;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: SwitchListTile(
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(roll),
        value: isPresent,
        secondary: CircleAvatar(
          child: Text(
            name.isEmpty
                ? '?'
                : name[0].toUpperCase(),
          ),
        ),
        onChanged: isSaving
            ? null
            : (value) {
                setState(() {
                  attendanceStatus[studentId] = value;
                });
              },
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return buildLoadingState();
    }

    if (errorMessage != null) {
      return buildErrorState();
    }

    if (facultyId == null) {
      return buildNoSessionState();
    }

    if (facultyClasses.isEmpty) {
      return buildNoClassState();
    }

    if (subjects.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadAttendanceData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 160),
            Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 60,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No subjects found.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No subjects are connected to the faculty classes.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (students.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadAttendanceData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 160),
            Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 60,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No students found.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No students are connected to this faculty class.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        buildClassBanner(),
        buildTopControls(),
        buildStats(),
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Mark Attendance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: loadAttendanceData,
            child: ListView.builder(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              itemBuilder: (context, index) {
                return buildStudentCard(
                  students[index],
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            16,
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : saveAttendance,
              icon: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.save_outlined,
                    ),
              label: Text(
                isSaving
                    ? 'Saving...'
                    : 'Save Attendance',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _stat(
    String title,
    int value,
  ) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(title),
      ],
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance Management',
        ),
      ),
      body: buildBody(),
    );
  }
}