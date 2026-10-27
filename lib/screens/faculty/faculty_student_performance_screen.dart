import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'faculty_dashboard.dart';

class FacultyStudentPerformanceScreen extends StatefulWidget {
  const FacultyStudentPerformanceScreen({super.key});

  @override
  State<FacultyStudentPerformanceScreen> createState() =>
      _FacultyStudentPerformanceScreenState();
}

class _FacultyStudentPerformanceScreenState
    extends State<FacultyStudentPerformanceScreen> {
  List<dynamic> students = [];
  List<dynamic> attendance = [];
  List<dynamic> assignments = [];
  List<dynamic> submissions = [];
  List<dynamic> results = [];
  List<dynamic> classes = [];

  bool isLoading = true;
  String? errorMessage;

  int? get facultyId => FacultyDashboard.currentFacultyId;

  @override
  void initState() {
    super.initState();
    loadPerformance();
  }

  Future<void> loadPerformance() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (facultyId == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          errorMessage =
              'Faculty session not found. Please login again.';
        });

        return;
      }

      final data = await Future.wait([
        ApiService.getStudents(),
        ApiService.getAttendance(),
        ApiService.getAssignments(),
        ApiService.getSubmissions(),
        ApiService.getResults(),
        ApiService.getClasses(),
      ]);

      if (!mounted) return;

      setState(() {
        students = List<dynamic>.from(data[0]);
        attendance = List<dynamic>.from(data[1]);
        assignments = List<dynamic>.from(data[2]);
        submissions = List<dynamic>.from(data[3]);
        results = List<dynamic>.from(data[4]);
        classes = List<dynamic>.from(data[5]);

        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load student performance data. Please check the backend server.';
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

      if (value is num) {
        return value.toInt();
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

  double getDoubleValue(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value is num) {
        return value.toDouble();
      }

      final parsed = double.tryParse(
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
    String defaultValue = '',
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

  int getStudentId(
    Map<String, dynamic> student,
  ) {
    return getIntValue(
      student,
      [
        'student_id',
        'id',
      ],
    );
  }

  String getStudentName(
    Map<String, dynamic> student,
  ) {
    return getStringValue(
      student,
      [
        'name',
        'student_name',
        'full_name',
      ],
      defaultValue: 'Student',
    );
  }

  String getStudentCode(
    Map<String, dynamic> student,
  ) {
    return getStringValue(
      student,
      [
        'student_code',
        'roll_no',
        'enrollment_no',
      ],
      defaultValue: 'N/A',
    );
  }

  int getClassId(
    Map<String, dynamic> classData,
  ) {
    return getIntValue(
      classData,
      [
        'class_id',
        'id',
      ],
    );
  }

  int getClassCourseId(
    Map<String, dynamic> classData,
  ) {
    return getIntValue(
      classData,
      [
        'course_id',
      ],
    );
  }

  int getClassTeacherId(
    Map<String, dynamic> classData,
  ) {
    return getIntValue(
      classData,
      [
        'class_teacher_id',
      ],
    );
  }

  int getAssignmentFacultyId(
    Map<String, dynamic> assignment,
  ) {
    return getIntValue(
      assignment,
      [
        'faculty_id',
      ],
    );
  }

  int getAssignmentClassId(
    Map<String, dynamic> assignment,
  ) {
    return getIntValue(
      assignment,
      [
        'class_id',
      ],
    );
  }

  int getAssignmentSubjectId(
    Map<String, dynamic> assignment,
  ) {
    return getIntValue(
      assignment,
      [
        'subject_id',
      ],
    );
  }

  int getStudentClassId(
    Map<String, dynamic> student,
  ) {
    return getIntValue(
      student,
      [
        'class_id',
        'classId',
      ],
    );
  }

  int getStudentCourseId(
    Map<String, dynamic> student,
  ) {
    return getIntValue(
      student,
      [
        'course_id',
        'courseId',
      ],
    );
  }

  List<Map<String, dynamic>> getFacultyClasses() {
    final currentFacultyId = facultyId;

    if (currentFacultyId == null) {
      return [];
    }

    final result = <Map<String, dynamic>>[];
    final addedClassIds = <int>{};

    /*
     * First include classes where this faculty is the
     * class teacher.
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

      if (classId > 0 &&
          classTeacherId == currentFacultyId &&
          addedClassIds.add(classId)) {
        result.add(classData);
      }
    }

    /*
     * Also include classes where this faculty teaches
     * through an assignment.
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
        .where((id) => id > 0)
        .toSet();

    for (final item in classes) {
      if (item is! Map) {
        continue;
      }

      final classData =
          Map<String, dynamic>.from(item);

      final classId =
          getClassId(classData);

      if (classId > 0 &&
          assignmentClassIds.contains(classId) &&
          addedClassIds.add(classId)) {
        result.add(classData);
      }
    }

    return result;
  }

  Set<int> getFacultyClassIds() {
    return getFacultyClasses()
        .map(getClassId)
        .where((id) => id > 0)
        .toSet();
  }

  Set<int> getFacultyCourseIds() {
    return getFacultyClasses()
        .map(getClassCourseId)
        .where((id) => id > 0)
        .toSet();
  }

  Set<int> getFacultySubjectIds() {
    final currentFacultyId = facultyId;

    if (currentFacultyId == null) {
      return {};
    }

    return assignments
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
        .map(getAssignmentSubjectId)
        .where((id) => id > 0)
        .toSet();
  }

  bool studentBelongsToFacultyClass(
    Map<String, dynamic> student,
  ) {
    final facultyClassIds =
        getFacultyClassIds();

    final facultyCourseIds =
        getFacultyCourseIds();

    if (facultyClassIds.isEmpty &&
        facultyCourseIds.isEmpty) {
      return false;
    }

    final studentClassId =
        getStudentClassId(student);

    if (studentClassId > 0 &&
        facultyClassIds.contains(studentClassId)) {
      return true;
    }

    /*
     * The current Students table does not contain
     * class_id, so course_id is used for the actual
     * database relationship.
     */
    final studentCourseId =
        getStudentCourseId(student);

    if (studentCourseId > 0 &&
        facultyCourseIds.contains(studentCourseId)) {
      return true;
    }

    return false;
  }

  List<Map<String, dynamic>> getFacultyStudents() {
    if (facultyId == null) {
      return [];
    }

    return students
        .whereType<Map>()
        .map(
          (item) =>
              Map<String, dynamic>.from(item),
        )
        .where(studentBelongsToFacultyClass)
        .toList();
  }

  bool assignmentBelongsToFaculty(
    Map<String, dynamic> assignment,
  ) {
    final currentFacultyId = facultyId;

    if (currentFacultyId == null) {
      return false;
    }

    final assignmentFacultyId =
        getAssignmentFacultyId(assignment);

    if (assignmentFacultyId == currentFacultyId) {
      return true;
    }

    final assignmentClassId =
        getAssignmentClassId(assignment);

    return getFacultyClassIds().contains(
      assignmentClassId,
    );
  }

  double calculateAttendance(
    int studentId,
  ) {
    int present = 0;
    int total = 0;

    for (final item in attendance) {
      if (item is! Map) {
        continue;
      }

      final record =
          Map<String, dynamic>.from(item);

      final recordStudentId =
          getIntValue(
        record,
        [
          'student_id',
          'studentId',
        ],
      );

      if (recordStudentId != studentId) {
        continue;
      }

      final status = getStringValue(
        record,
        [
          'status',
          'attendance_status',
        ],
      ).trim().toLowerCase();

      if (status.isEmpty) {
        continue;
      }

      total++;

      if (status == 'present' ||
          status == 'p' ||
          status == 'true') {
        present++;
      }
    }

    if (total == 0) {
      return 0;
    }

    return (present / total) * 100;
  }

  double calculateAssignmentPerformance(
    int studentId,
  ) {
    final facultyAssignments = assignments
        .whereType<Map>()
        .map(
          (item) =>
              Map<String, dynamic>.from(item),
        )
        .where(assignmentBelongsToFaculty)
        .toList();

    if (facultyAssignments.isEmpty) {
      return 0;
    }

    final assignmentIds = facultyAssignments
        .map(
          (assignment) => getIntValue(
            assignment,
            [
              'assignment_id',
              'id',
            ],
          ),
        )
        .where((id) => id > 0)
        .toSet();

    final submittedAssignmentIds = <int>{};

    for (final item in submissions) {
      if (item is! Map) {
        continue;
      }

      final submission =
          Map<String, dynamic>.from(item);

      final submissionStudentId =
          getIntValue(
        submission,
        [
          'student_id',
          'studentId',
        ],
      );

      if (submissionStudentId != studentId) {
        continue;
      }

      final assignmentId =
          getIntValue(
        submission,
        [
          'assignment_id',
          'assignmentId',
        ],
      );

      if (assignmentIds.contains(assignmentId)) {
        submittedAssignmentIds.add(
          assignmentId,
        );
      }
    }

    if (assignmentIds.isEmpty) {
      return 0;
    }

    return (submittedAssignmentIds.length /
            assignmentIds.length) *
        100;
  }

  double calculateExamPerformance(
    int studentId,
  ) {
    final facultySubjectIds =
        getFacultySubjectIds();

    double obtained = 0;
    double total = 0;
    bool hasRelevantResults = false;

    for (final item in results) {
      if (item is! Map) {
        continue;
      }

      final result =
          Map<String, dynamic>.from(item);

      final resultStudentId =
          getIntValue(
        result,
        [
          'student_id',
          'studentId',
        ],
      );

      if (resultStudentId != studentId) {
        continue;
      }

      final subjectId =
          getIntValue(
        result,
        [
          'subject_id',
          'subjectId',
        ],
      );

      /*
       * When faculty assignment subjects are available,
       * restrict results to those subjects.
       */
      if (facultySubjectIds.isNotEmpty &&
          !facultySubjectIds.contains(subjectId)) {
        continue;
      }

      final totalMarks =
          getDoubleValue(
        result,
        [
          'total_marks',
        ],
      );

      final marksObtained =
          getDoubleValue(
        result,
        [
          'marks_obtained',
        ],
      );

      if (totalMarks <= 0) {
        continue;
      }

      hasRelevantResults = true;

      obtained += marksObtained;
      total += totalMarks;
    }

    if (!hasRelevantResults || total <= 0) {
      return 0;
    }

    return (obtained / total) * 100;
  }

  double calculateOverallPerformance(
    int studentId,
  ) {
    final attendancePercentage =
        calculateAttendance(studentId);

    final assignmentPercentage =
        calculateAssignmentPerformance(
      studentId,
    );

    final examPercentage =
        calculateExamPerformance(studentId);

    final available = <double>[];

    /*
     * A metric is included only when there is actual
     * underlying data for that metric.
     */
    final hasAttendance =
        attendance.any(
      (item) {
        if (item is! Map) {
          return false;
        }

        final record =
            Map<String, dynamic>.from(item);

        return getIntValue(
              record,
              [
                'student_id',
                'studentId',
              ],
            ) ==
            studentId &&
            getStringValue(
              record,
              [
                'status',
                'attendance_status',
              ],
            ).trim().isNotEmpty;
      },
    );

    final hasFacultyAssignments =
        assignments.any(
      (item) {
        if (item is! Map) {
          return false;
        }

        final assignment =
            Map<String, dynamic>.from(item);

        return assignmentBelongsToFaculty(
          assignment,
        );
      },
    );

    final hasExamResults =
        results.any(
      (item) {
        if (item is! Map) {
          return false;
        }

        final result =
            Map<String, dynamic>.from(item);

        final resultStudentId =
            getIntValue(
          result,
          [
            'student_id',
            'studentId',
          ],
        );

        if (resultStudentId != studentId) {
          return false;
        }

        final subjectId =
            getIntValue(
          result,
          [
            'subject_id',
            'subjectId',
          ],
        );

        final facultySubjectIds =
            getFacultySubjectIds();

        if (facultySubjectIds.isNotEmpty &&
            !facultySubjectIds.contains(subjectId)) {
          return false;
        }

        return getDoubleValue(
              result,
              [
                'total_marks',
              ],
            ) >
            0;
      },
    );

    if (hasAttendance) {
      available.add(attendancePercentage);
    }

    if (hasFacultyAssignments) {
      available.add(assignmentPercentage);
    }

    if (hasExamResults) {
      available.add(examPercentage);
    }

    if (available.isEmpty) {
      return 0;
    }

    return available.reduce(
          (a, b) => a + b,
        ) /
        available.length;
  }

  Color getPerformanceColor(
    double percentage,
  ) {
    if (percentage >= 75) {
      return Colors.green;
    }

    if (percentage >= 50) {
      return Colors.orange;
    }

    return Colors.red;
  }

  String getPerformanceLabel(
    double percentage,
  ) {
    if (percentage >= 75) {
      return 'Good';
    }

    if (percentage >= 50) {
      return 'Needs Improvement';
    }

    if (percentage > 0) {
      return 'At Risk';
    }

    return 'No Data';
  }

  Widget buildMetric(
    String title,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStudentCard(
    Map<String, dynamic> student,
  ) {
    final studentId =
        getStudentId(student);

    final name =
        getStudentName(student);

    final code =
        getStudentCode(student);

    final attendancePercentage =
        calculateAttendance(studentId);

    final assignmentPercentage =
        calculateAssignmentPerformance(
      studentId,
    );

    final examPercentage =
        calculateExamPerformance(studentId);

    final overallPercentage =
        calculateOverallPerformance(studentId);

    final performanceColor =
        getPerformanceColor(
      overallPercentage,
    );

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(code),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(20),
                    color:
                        performanceColor.withValues(
                      alpha: 0.12,
                    ),
                  ),
                  child: Text(
                    getPerformanceLabel(
                      overallPercentage,
                    ),
                    style: TextStyle(
                      color: performanceColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                buildMetric(
                  'Attendance',
                  '${attendancePercentage.toStringAsFixed(1)}%',
                  Icons.event_available,
                ),
                buildMetric(
                  'Assignments',
                  '${assignmentPercentage.toStringAsFixed(1)}%',
                  Icons.assignment,
                ),
                buildMetric(
                  'Exams',
                  '${examPercentage.toStringAsFixed(1)}%',
                  Icons.school,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (overallPercentage / 100)
                  .clamp(0.0, 1.0),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Overall Performance',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${overallPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: performanceColor,
                  ),
                ),
              ],
            ),
          ],
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
                  'Unable to load performance data.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: loadPerformance,
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
      onRefresh: loadPerformance,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 100),
          Icon(
            Icons.class_outlined,
            size: 70,
          ),
          SizedBox(height: 18),
          Text(
            'No class assigned',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This faculty member does not currently have an assigned class. Student performance cannot be displayed.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return buildLoading();
    }

    if (errorMessage != null) {
      return buildError();
    }

    if (facultyId == null) {
      return buildError();
    }

    final facultyClasses =
        getFacultyClasses();

    if (facultyClasses.isEmpty) {
      return buildNoClassState();
    }

    final filteredStudents =
        getFacultyStudents();

    if (filteredStudents.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadPerformance,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 100),
            Icon(
              Icons.analytics_outlined,
              size: 70,
            ),
            SizedBox(height: 18),
            Text(
              'No students found',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No students are currently assigned to your class.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadPerformance,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const CircleAvatar(
                    child: Icon(Icons.class_),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Assigned Class',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          facultyClasses
                              .map(
                                (classData) =>
                                    getStringValue(
                                  classData,
                                  [
                                    'class_name',
                                    'name',
                                    'class_code',
                                  ],
                                  defaultValue: 'Class',
                                ),
                              )
                              .join(', '),
                          style: const TextStyle(
                            fontSize: 17,
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
          const SizedBox(height: 16),
          const Text(
            'Student Performance',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${filteredStudents.length} student(s) available',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ...filteredStudents.map(
            buildStudentCard,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Performance',
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                isLoading ? null : loadPerformance,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: buildBody(),
    );
  }
}