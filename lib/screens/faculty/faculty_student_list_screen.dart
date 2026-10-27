import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'faculty_dashboard.dart';

class FacultyStudentListScreen extends StatefulWidget {
  const FacultyStudentListScreen({super.key});

  @override
  State<FacultyStudentListScreen> createState() =>
      _FacultyStudentListScreenState();
}

class _FacultyStudentListScreenState
    extends State<FacultyStudentListScreen> {
  List<dynamic> students = [];
  List<dynamic> classes = [];
  List<dynamic> assignments = [];

  bool isLoading = true;
  String? errorMessage;

  int? get facultyId => FacultyDashboard.currentFacultyId;

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (facultyId == null) {
        setState(() {
          isLoading = false;
          errorMessage =
              'Faculty session not found. Please login again.';
        });
        return;
      }

      final results = await Future.wait([
        ApiService.getStudents(),
        ApiService.getClasses(),
        ApiService.getAssignments(),
      ]);

      if (!mounted) return;

      setState(() {
        students = List<dynamic>.from(results[0]);
        classes = List<dynamic>.from(results[1]);
        assignments = List<dynamic>.from(results[2]);
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load student list. Please check the backend server.';
      });
    }
  }

  int? parseId(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString().trim() ?? '',
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

  int? getClassTeacherId(
    Map<String, dynamic> item,
  ) {
    return parseId(
      item['class_teacher_id'],
    );
  }

  int? getAssignmentFacultyId(
    Map<String, dynamic> item,
  ) {
    return parseId(
      item['faculty_id'],
    );
  }

  int? getAssignmentClassId(
    Map<String, dynamic> item,
  ) {
    return parseId(
      item['class_id'],
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

  String getStudentId(
    Map<String, dynamic> student,
  ) {
    return (
      student['student_code'] ??
      student['roll_no'] ??
      student['enrollment_no'] ??
      student['student_id'] ??
      'N/A'
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

  String getClassName(
    Map<String, dynamic> classData,
  ) {
    return (
      classData['class_name'] ??
      classData['name'] ??
      classData['class_code'] ??
      'Class'
    ).toString();
  }

  String getSemester(
    Map<String, dynamic> student,
  ) {
    return (
      student['semester'] ?? ''
    ).toString();
  }

  String getCourseName(
    Map<String, dynamic> student,
  ) {
    return (
      student['course_name'] ??
      student['course'] ??
      ''
    ).toString();
  }

  List<Map<String, dynamic>> getFacultyClasses() {
    final result = <Map<String, dynamic>>[];
    final currentFacultyId = facultyId;

    if (currentFacultyId == null) {
      return result;
    }

    final addedClassIds = <int>{};

    /*
     * Include classes where the faculty is the class teacher.
     */
    for (final item in classes) {
      if (item is! Map) {
        continue;
      }

      final classData =
          Map<String, dynamic>.from(item);

      final classId =
          getClassId(classData);

      final classTeacherId =
          getClassTeacherId(classData);

      if (classId != null &&
          classTeacherId == currentFacultyId &&
          addedClassIds.add(classId)) {
        result.add(classData);
      }
    }

    /*
     * Also include classes where this faculty teaches
     * through an assignment.
     *
     * This is required because faculty_id in Assignments
     * is independent of class_teacher_id.
     */
    final assignmentClassIds = assignments
        .whereType<Map>()
        .map(
          (item) =>
              Map<String, dynamic>.from(item),
        )
        .where(
          (assignment) =>
              getAssignmentFacultyId(assignment) ==
              currentFacultyId,
        )
        .map(getAssignmentClassId)
        .whereType<int>()
        .toSet();

    for (final item in classes) {
      if (item is! Map) {
        continue;
      }

      final classData =
          Map<String, dynamic>.from(item);

      final classId =
          getClassId(classData);

      if (classId != null &&
          assignmentClassIds.contains(classId) &&
          addedClassIds.add(classId)) {
        result.add(classData);
      }
    }

    return result;
  }

  List<Map<String, dynamic>> getFilteredStudents() {
    final facultyClasses = getFacultyClasses();

    if (facultyClasses.isEmpty) {
      return [];
    }

    final classIds = facultyClasses
        .map(getClassId)
        .whereType<int>()
        .toSet();

    final courseIds = facultyClasses
        .map(getClassCourseId)
        .whereType<int>()
        .toSet();

    return students
        .whereType<Map>()
        .map(
          (student) =>
              Map<String, dynamic>.from(
            student,
          ),
        )
        .where((student) {
          /*
           * If the API provides class_id for a student,
           * use the exact class relationship first.
           */
          final studentClassId =
              getStudentClassId(student);

          if (studentClassId != null &&
              classIds.contains(studentClassId)) {
            return true;
          }

          /*
           * The current Students table does not contain
           * class_id. It contains course_id, so use the
           * course relationship as the database-supported
           * fallback.
           */
          final studentCourseId =
              getStudentCourseId(student);

          if (studentCourseId != null &&
              courseIds.contains(studentCourseId)) {
            return true;
          }

          return false;
        })
        .toList();
  }

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
                  'Unable to load students.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: loadStudents,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNoClassState() {
    return RefreshIndicator(
      onRefresh: loadStudents,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 150),
          const Center(
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
                    'No class is currently assigned to this faculty.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Students cannot be displayed until a class is assigned.',
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

  Widget buildNoStudentsState(
    List<Map<String, dynamic>> facultyClasses,
  ) {
    return RefreshIndicator(
      onRefresh: loadStudents,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 60,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No students found in the assigned class.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Assigned class: ${facultyClasses.map(getClassName).join(', ')}',
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

  Widget buildStudentCard(
    Map<String, dynamic> student,
    int index,
  ) {
    final studentId =
        getStudentId(student);

    final studentName =
        getStudentName(student);

    final semester =
        getSemester(student);

    final course =
        getCourseName(student);

    String academicInfo = '';

    if (course.isNotEmpty) {
      academicInfo = course;
    }

    if (semester.isNotEmpty) {
      if (academicInfo.isNotEmpty) {
        academicInfo += ' • ';
      }

      academicInfo += 'Semester $semester';
    }

    if (academicInfo.isEmpty) {
      academicInfo = 'Student';
    }

    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        leading: CircleAvatar(
          child: Text(
            studentName.isNotEmpty
                ? studentName[0].toUpperCase()
                : '${index + 1}',
          ),
        ),
        title: Text(
          studentName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '$studentId • $academicInfo',
        ),
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
      return const Center(
        child: Text(
          'Faculty session not found. Please login again.',
        ),
      );
    }

    final facultyClasses =
        getFacultyClasses();

    if (facultyClasses.isEmpty) {
      return buildNoClassState();
    }

    final filteredStudents =
        getFilteredStudents();

    if (filteredStudents.isEmpty) {
      return buildNoStudentsState(
        facultyClasses,
      );
    }

    return RefreshIndicator(
      onRefresh: loadStudents,
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(16),
        itemCount:
            filteredStudents.length + 1,
        itemBuilder:
            (context, index) {
          if (index == 0) {
            return Container(
              margin:
                  const EdgeInsets.only(
                bottom: 14,
              ),
              padding:
                  const EdgeInsets.all(14),
              decoration:
                  BoxDecoration(
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assigned Class',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    facultyClasses
                        .map(getClassName)
                        .join(', '),
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${filteredStudents.length} student(s)',
                  ),
                ],
              ),
            );
          }

          final student =
              filteredStudents[index - 1];

          return buildStudentCard(
            student,
            index - 1,
          );
        },
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student List'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                isLoading ? null : loadStudents,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: buildBody(),
    );
  }
}