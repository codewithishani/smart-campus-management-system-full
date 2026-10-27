import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ParentAcademicPerformanceScreen extends StatefulWidget {
  final int parentId;

  const ParentAcademicPerformanceScreen(
    this.parentId, {
    super.key,
  });

  @override
  State<ParentAcademicPerformanceScreen> createState() =>
      _ParentAcademicPerformanceScreenState();
}

class _ParentAcademicPerformanceScreenState
    extends State<ParentAcademicPerformanceScreen> {
  List<dynamic> attendance = [];
  List<dynamic> results = [];
  List<dynamic> assignments = [];
  List<dynamic> submissions = [];
  List<dynamic> students = [];
  List<dynamic> linkedStudents = [];
  List<dynamic> classes = [];

  int selectedStudentId = 0;
  int linkedClassId = 0;
  int linkedCourseId = 0;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadAcademicPerformance();
  }

  Future<void> loadAcademicPerformance() async {
    try {
      final data = await Future.wait([
        ApiService.getParentStudentLinks(),
        ApiService.getStudents(),
        ApiService.getClasses(),
        ApiService.getAttendance(),
        ApiService.getResults(),
        ApiService.getAssignments(),
        ApiService.getSubmissions(),
      ]);

      final links = data[0];
      final studentData = data[1];
      final classData = data[2];
      final attendanceData = data[3];
      final resultsData = data[4];
      final assignmentData = data[5];
      final submissionData = data[6];

      final studentIds = <int>[];

      for (final item in links) {
        if (item is! Map) continue;

        final link = Map<String, dynamic>.from(item);

        final currentParentId = getIntValue(
          link,
          ['parent_id'],
        );

        if (currentParentId != widget.parentId) {
          continue;
        }

        final studentId = getIntValue(
          link,
          ['student_id'],
        );

        if (studentId != 0 && !studentIds.contains(studentId)) {
          studentIds.add(studentId);
        }
      }

      final resolvedStudents = <Map<String, dynamic>>[];

      for (final studentId in studentIds) {
        for (final item in studentData) {
          if (item is! Map) continue;

          final student = Map<String, dynamic>.from(item);

          final currentStudentId = getIntValue(
            student,
            ['student_id', 'id'],
          );

          if (currentStudentId == studentId) {
            resolvedStudents.add(student);
            break;
          }
        }
      }

      int initialStudentId = 0;

      if (resolvedStudents.isNotEmpty) {
        initialStudentId = getIntValue(
          resolvedStudents.first,
          ['student_id', 'id'],
        );
      }

      if (!mounted) return;

      setState(() {
        students = studentData;
        classes = classData;
        linkedStudents = resolvedStudents;

        attendance = attendanceData;
        results = resultsData;
        assignments = assignmentData;
        submissions = submissionData;

        selectedStudentId = initialStudentId;

        isLoading = false;
        errorMessage = null;
      });

      updateSelectedStudent(initialStudentId);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load academic performance.';
      });
    }
  }

  void updateSelectedStudent(int studentId) {
    int classId = 0;
    int courseId = 0;

    for (final item in students) {
      if (item is! Map) continue;

      final student = Map<String, dynamic>.from(item);

      final currentStudentId = getIntValue(
        student,
        ['student_id', 'id'],
      );

      if (currentStudentId == studentId) {
        classId = getIntValue(
          student,
          ['class_id'],
        );

        courseId = getIntValue(
          student,
          ['course_id'],
        );

        break;
      }
    }

    if (classId == 0 && courseId != 0) {
      for (final item in classes) {
        if (item is! Map) continue;

        final classItem = Map<String, dynamic>.from(item);

        final currentCourseId = getIntValue(
          classItem,
          ['course_id'],
        );

        if (currentCourseId == courseId) {
          classId = getIntValue(
            classItem,
            ['class_id', 'id'],
          );
          break;
        }
      }
    }

    if (!mounted) return;

    setState(() {
      selectedStudentId = studentId;
      linkedClassId = classId;
      linkedCourseId = courseId;
    });
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

  double? getDoubleValue(
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

    return null;
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

  String getStudentName(int studentId) {
    for (final item in linkedStudents) {
      if (item is! Map) continue;

      final student = Map<String, dynamic>.from(item);

      final currentStudentId = getIntValue(
        student,
        ['student_id', 'id'],
      );

      if (currentStudentId == studentId) {
        return getStringValue(
          student,
          ['name', 'student_name'],
          defaultValue: 'Student',
        );
      }
    }

    return 'Student';
  }

  Widget buildStudentSelector() {
    if (linkedStudents.length <= 1) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: DropdownButtonFormField<int>(
          initialValue: selectedStudentId == 0
              ? null
              : selectedStudentId,
          decoration: const InputDecoration(
            labelText: 'Select Student',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          items: linkedStudents.map<DropdownMenuItem<int>>((item) {
            final student = Map<String, dynamic>.from(item);

            final studentId = getIntValue(
              student,
              ['student_id', 'id'],
            );

            final studentName = getStringValue(
              student,
              ['name', 'student_name'],
              defaultValue: 'Student',
            );

            return DropdownMenuItem<int>(
              value: studentId,
              child: Text(studentName),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              updateSelectedStudent(value);
            }
          },
        ),
      ),
    );
  }

  double? calculateAttendancePercentage() {
    int present = 0;
    int total = 0;

    for (final item in attendance) {
      if (item is! Map) continue;

      final record = Map<String, dynamic>.from(item);

      final studentId = getIntValue(
        record,
        ['student_id'],
      );

      if (studentId != selectedStudentId) {
        continue;
      }

      final status = getStringValue(
        record,
        ['status', 'attendance_status'],
      ).trim().toLowerCase();

      if (status == 'present' ||
          status == 'p' ||
          status == 'absent' ||
          status == 'a' ||
          status == 'late' ||
          status == 'l') {
        total++;

        if (status == 'present' ||
            status == 'p' ||
            status == 'late' ||
            status == 'l') {
          present++;
        }

        continue;
      }

      final presentValue = record['is_present'];

      if (presentValue is bool) {
        total++;

        if (presentValue) {
          present++;
        }

        continue;
      }

      final presentNumber = getIntValue(
        record,
        ['present'],
      );

      if (presentNumber == 1) {
        total++;
        present++;
      }
    }

    if (total == 0) {
      return null;
    }

    return (present / total) * 100;
  }

  double? calculateResultPercentage() {
    double obtained = 0;
    double total = 0;

    for (final item in results) {
      if (item is! Map) continue;

      final result = Map<String, dynamic>.from(item);

      final studentId = getIntValue(
        result,
        ['student_id'],
      );

      if (studentId != selectedStudentId) {
        continue;
      }

      final marksObtained = getDoubleValue(
        result,
        [
          'marks_obtained',
          'marks',
          'obtained_marks',
        ],
      );

      final totalMarks = getDoubleValue(
        result,
        [
          'total_marks',
          'max_marks',
          'maximum_marks',
        ],
      );

      if (marksObtained != null &&
          totalMarks != null &&
          totalMarks > 0) {
        obtained += marksObtained;
        total += totalMarks;
      }
    }

    if (total == 0) {
      return null;
    }

    return (obtained / total) * 100;
  }

  List<Map<String, dynamic>> getStudentAssignments() {
    final result = <Map<String, dynamic>>[];

    for (final item in assignments) {
      if (item is! Map) continue;

      final assignment = Map<String, dynamic>.from(item);

      final assignmentStudentId = getIntValue(
        assignment,
        ['student_id'],
      );

      final assignmentClassId = getIntValue(
        assignment,
        ['class_id'],
      );

      final assignmentCourseId = getIntValue(
        assignment,
        ['course_id'],
      );

      bool belongsToStudent = false;

      if (assignmentStudentId != 0) {
        belongsToStudent =
            assignmentStudentId == selectedStudentId;
      } else {
        if (linkedClassId != 0 &&
            assignmentClassId != 0 &&
            assignmentClassId == linkedClassId) {
          belongsToStudent = true;
        }

        if (!belongsToStudent &&
            linkedCourseId != 0 &&
            assignmentCourseId != 0 &&
            assignmentCourseId == linkedCourseId) {
          belongsToStudent = true;
        }

        if (!belongsToStudent &&
            assignmentClassId == 0 &&
            assignmentCourseId == 0) {
          belongsToStudent = true;
        }
      }

      if (belongsToStudent) {
        result.add(assignment);
      }
    }

    return result;
  }

  int getSubmittedAssignmentCount(
    List<Map<String, dynamic>> studentAssignments,
  ) {
    final assignmentIds = <int>{};

    for (final assignment in studentAssignments) {
      final assignmentId = getIntValue(
        assignment,
        ['assignment_id', 'id'],
      );

      if (assignmentId != 0) {
        assignmentIds.add(assignmentId);
      }
    }

    int submitted = 0;

    for (final item in submissions) {
      if (item is! Map) continue;

      final submission = Map<String, dynamic>.from(item);

      final studentId = getIntValue(
        submission,
        ['student_id'],
      );

      if (studentId != selectedStudentId) {
        continue;
      }

      final assignmentId = getIntValue(
        submission,
        ['assignment_id'],
      );

      if (assignmentIds.contains(assignmentId)) {
        submitted++;
      }
    }

    return submitted;
  }

  int getStudentResultCount() {
    int count = 0;

    for (final item in results) {
      if (item is! Map) continue;

      final result = Map<String, dynamic>.from(item);

      if (getIntValue(
            result,
            ['student_id'],
          ) ==
          selectedStudentId) {
        count++;
      }
    }

    return count;
  }

  String getPerformanceLabel(
    double? resultPercentage,
  ) {
    if (resultPercentage == null) {
      return 'No result data';
    }

    if (resultPercentage >= 75) {
      return 'Very Good';
    }

    if (resultPercentage >= 60) {
      return 'Good';
    }

    if (resultPercentage >= 50) {
      return 'Satisfactory';
    }

    return 'Needs Improvement';
  }

  String getTrendLabel(
    double? resultPercentage,
  ) {
    if (resultPercentage == null) {
      return 'Not Available';
    }

    if (resultPercentage >= 75) {
      return 'Strong Academic Performance';
    }

    if (resultPercentage >= 60) {
      return 'Steady Performance';
    }

    return 'Requires Attention';
  }

  Widget buildPerformanceCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 55,
            ),
            const SizedBox(height: 14),
            Text(
              errorMessage ??
                  'Unable to load academic performance.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });

                loadAcademicPerformance();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
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

    if (linkedStudents.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadAcademicPerformance,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 100),
            Icon(
              Icons.link_off,
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
          ],
        ),
      );
    }

    final attendancePercentage =
        calculateAttendancePercentage();

    final resultPercentage =
        calculateResultPercentage();

    final performanceLabel =
        getPerformanceLabel(resultPercentage);

    final trendLabel =
        getTrendLabel(resultPercentage);

    final studentAssignments =
        getStudentAssignments();

    final submittedAssignments =
        getSubmittedAssignmentCount(
      studentAssignments,
    );

    final assignmentText =
        '$submittedAssignments / ${studentAssignments.length} Submitted';

    final studentResultCount =
        getStudentResultCount();

    return RefreshIndicator(
      onRefresh: loadAcademicPerformance,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          buildStudentSelector(),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    child: Icon(
                      Icons.analytics,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Academic Overview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          getStudentName(selectedStudentId),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          buildPerformanceCard(
            'Overall Performance',
            performanceLabel,
            Icons.trending_up,
          ),
          buildPerformanceCard(
            'Attendance',
            attendancePercentage == null
                ? 'N/A'
                : '${attendancePercentage.toStringAsFixed(1)}%',
            Icons.fact_check,
          ),
          buildPerformanceCard(
            'Exam / Result Percentage',
            resultPercentage == null
                ? 'N/A'
                : '${resultPercentage.toStringAsFixed(1)}%',
            Icons.grade,
          ),
          buildPerformanceCard(
            'Assignments',
            assignmentText,
            Icons.assignment,
          ),
          buildPerformanceCard(
            'Academic Trend',
            trendLabel,
            Icons.show_chart,
          ),
          buildPerformanceCard(
            'Result Records',
            '$studentResultCount result records',
            Icons.assessment,
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
        title: const Text('Academic Performance'),
      ),
      body: buildBody(),
    );
  }
}