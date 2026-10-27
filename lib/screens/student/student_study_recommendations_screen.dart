import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StudentStudyRecommendationsScreen extends StatefulWidget {
  final int studentId;

  const StudentStudyRecommendationsScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentStudyRecommendationsScreen> createState() =>
      _StudentStudyRecommendationsScreenState();
}

class _StudentStudyRecommendationsScreenState
    extends State<StudentStudyRecommendationsScreen> {
  bool isLoading = true;
  String? errorMessage;

  double attendancePercentage = 0;
  double assignmentPercentage = 0;
  double examinationPercentage = 0;

  int totalAssignments = 0;
  int submittedAssignments = 0;
  int totalResults = 0;

  final List<Map<String, dynamic>> recommendations = [];

  @override
  void initState() {
    super.initState();
    loadRecommendations();
  }

  Future<void> loadRecommendations() async {
    try {
      final results = await Future.wait([
        ApiService.getStudent(widget.studentId),
        ApiService.getClasses(),
        ApiService.getAttendance(),
        ApiService.getAssignments(),
        ApiService.getSubmissions(),
        ApiService.getResults(),
      ]);

      if (!mounted) return;

      if (results[0] is! Map) {
        throw Exception('Invalid student data');
      }

      final student = Map<String, dynamic>.from(results[0] as Map);

      final classData = results[1] is List ? results[1] as List : [];
      final attendanceData = results[2] is List ? results[2] as List : [];
      final assignmentData = results[3] is List ? results[3] as List : [];
      final submissionData = results[4] is List ? results[4] as List : [];
      final resultData = results[5] is List ? results[5] as List : [];

      final courseId = student['course_id'] ?? student['courseId'];
      final semester = student['semester'];

      Map<String, dynamic>? studentClass;

      for (final item in classData) {
        if (item is! Map) continue;

        final classRecord = Map<String, dynamic>.from(item);

        final classCourseId =
            classRecord['course_id'] ?? classRecord['courseId'];

        final classSemester = classRecord['semester'];

        if (classCourseId?.toString() == courseId?.toString() &&
            classSemester?.toString() == semester?.toString()) {
          studentClass = classRecord;
          break;
        }
      }

      final classId =
          studentClass?['class_id'] ?? studentClass?['classId'];

      final studentAttendance = attendanceData.where((item) {
        if (item is! Map) return false;

        final attendance = Map<String, dynamic>.from(item);

        final attendanceStudentId =
            attendance['student_id'] ?? attendance['studentId'];

        return attendanceStudentId?.toString() ==
            widget.studentId.toString();
      }).toList();

      final studentAssignments = assignmentData.where((item) {
        if (item is! Map) return false;

        final assignment = Map<String, dynamic>.from(item);

        final assignmentClassId =
            assignment['class_id'] ?? assignment['classId'];

        return classId != null &&
            assignmentClassId?.toString() == classId.toString();
      }).toList();

      final studentSubmissions = submissionData.where((item) {
        if (item is! Map) return false;

        final submission = Map<String, dynamic>.from(item);

        final submissionStudentId =
            submission['student_id'] ?? submission['studentId'];

        return submissionStudentId?.toString() ==
            widget.studentId.toString();
      }).toList();

      final studentResults = resultData.where((item) {
        if (item is! Map) return false;

        final result = Map<String, dynamic>.from(item);

        final resultStudentId =
            result['student_id'] ?? result['studentId'];

        return resultStudentId?.toString() ==
            widget.studentId.toString();
      }).toList();

      final attendance = calculateAttendance(studentAttendance);

      final assignments = calculateAssignments(
        studentAssignments,
        studentSubmissions,
      );

      final examinations = calculateExaminations(studentResults);

      setState(() {
        attendancePercentage = attendance;
        assignmentPercentage = assignments;
        examinationPercentage = examinations;

        totalAssignments = studentAssignments.length;

        submittedAssignments =
            countStudentAssignmentSubmissions(
          studentAssignments,
          studentSubmissions,
        );

        totalResults = studentResults.length;

        buildRecommendations();

        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load study recommendations.';
      });
    }
  }

  double calculateAttendance(List<dynamic> attendance) {
    if (attendance.isEmpty) {
      return 0;
    }

    int present = 0;

    for (final item in attendance) {
      if (item is! Map) continue;

      final record = Map<String, dynamic>.from(item);

      final status = (record['status'] ?? '')
          .toString()
          .trim()
          .toLowerCase();

      if (record['is_present'] == true ||
          record['present'] == true ||
          status == 'present' ||
          status == 'p' ||
          status == 'attended') {
        present++;
      }
    }

    return (present / attendance.length) * 100;
  }

  double calculateAssignments(
    List<dynamic> assignments,
    List<dynamic> submissions,
  ) {
    if (assignments.isEmpty) {
      return 0;
    }

    final submittedCount =
        countStudentAssignmentSubmissions(
      assignments,
      submissions,
    );

    return ((submittedCount / assignments.length) * 100)
        .clamp(0, 100)
        .toDouble();
  }

  int countStudentAssignmentSubmissions(
    List<dynamic> assignments,
    List<dynamic> submissions,
  ) {
    final assignmentIds = <String>{};

    for (final item in assignments) {
      if (item is! Map) continue;

      final assignment = Map<String, dynamic>.from(item);

      final assignmentId =
          assignment['assignment_id'] ??
          assignment['assignmentId'];

      if (assignmentId != null) {
        assignmentIds.add(assignmentId.toString());
      }
    }

    if (assignmentIds.isEmpty) {
      return 0;
    }

    final submittedAssignmentIds = <String>{};

    for (final item in submissions) {
      if (item is! Map) continue;

      final submission = Map<String, dynamic>.from(item);

      final submissionAssignmentId =
          submission['assignment_id'] ??
          submission['assignmentId'];

      final submissionStudentId =
          submission['student_id'] ??
          submission['studentId'];

      if (submissionStudentId?.toString() !=
          widget.studentId.toString()) {
        continue;
      }

      if (submissionAssignmentId != null &&
          assignmentIds.contains(
            submissionAssignmentId.toString(),
          )) {
        submittedAssignmentIds.add(
          submissionAssignmentId.toString(),
        );
      }
    }

    return submittedAssignmentIds.length;
  }

  double calculateExaminations(List<dynamic> results) {
    if (results.isEmpty) {
      return 0;
    }

    double obtained = 0;
    double total = 0;

    for (final item in results) {
      if (item is! Map) continue;

      final result = Map<String, dynamic>.from(item);

      final marksValue =
          result['marks_obtained'] ??
          result['marksObtained'] ??
          result['marks'];

      final totalValue =
          result['total_marks'] ??
          result['totalMarks'] ??
          result['max_marks'] ??
          result['maximum_marks'];

      double marks = 0;
      double totalMarks = 0;

      if (marksValue is num) {
        marks = marksValue.toDouble();
      } else {
        marks = double.tryParse(
              marksValue?.toString() ?? '',
            ) ??
            0;
      }

      if (totalValue is num) {
        totalMarks = totalValue.toDouble();
      } else {
        totalMarks = double.tryParse(
              totalValue?.toString() ?? '',
            ) ??
            0;
      }

      obtained += marks;
      total += totalMarks;
    }

    if (total == 0) {
      return 0;
    }

    return ((obtained / total) * 100)
        .clamp(0, 100)
        .toDouble();
  }

  void buildRecommendations() {
    recommendations.clear();

    if (attendancePercentage < 75) {
      recommendations.add({
        'title': 'Improve Attendance',
        'description':
            'Your attendance is below 75%. Try to attend classes regularly and monitor your attendance to avoid shortage.',
        'icon': Icons.calendar_month,
      });
    } else {
      recommendations.add({
        'title': 'Maintain Attendance',
        'description':
            'Your attendance is currently satisfactory. Continue attending classes regularly.',
        'icon': Icons.calendar_month,
      });
    }

    if (assignmentPercentage < 75) {
      recommendations.add({
        'title': 'Complete Pending Assignments',
        'description':
            'Your assignment submission rate can be improved. Complete pending assignments before their deadlines.',
        'icon': Icons.assignment,
      });
    } else {
      recommendations.add({
        'title': 'Stay Consistent With Assignments',
        'description':
            'You are submitting assignments consistently. Continue completing your work before deadlines.',
        'icon': Icons.assignment_turned_in,
      });
    }

    if (examinationPercentage > 0 &&
        examinationPercentage < 60) {
      recommendations.add({
        'title': 'Focus on Exam Preparation',
        'description':
            'Your current examination performance indicates that additional revision and practice may be useful.',
        'icon': Icons.school,
      });
    } else if (examinationPercentage >= 60) {
      recommendations.add({
        'title': 'Continue Exam Preparation',
        'description':
            'Your examination performance is progressing well. Continue regular revision and practice.',
        'icon': Icons.school,
      });
    } else {
      recommendations.add({
        'title': 'Start Exam Preparation',
        'description':
            'No examination results are currently available. Start preparing early using your notes and study resources.',
        'icon': Icons.school,
      });
    }

    recommendations.add({
      'title': 'Practice Programming',
      'description':
          'Practice coding problems regularly to strengthen programming and problem-solving skills.',
      'icon': Icons.code,
    });

    recommendations.add({
      'title': 'Review Study Materials',
      'description':
          'Use the Notes & Resources section regularly to revise important concepts and prepare for examinations.',
      'icon': Icons.menu_book,
    });

    if (totalResults > 0) {
      recommendations.add({
        'title': 'Review Your Results',
        'description':
            'Review your subject-wise marks and identify topics where additional preparation may be useful.',
        'icon': Icons.analytics,
      });
    }
  }

  Widget buildRecommendationCard(
    Map<String, dynamic> recommendation,
  ) {
    final icon = recommendation['icon'];

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              child: Icon(
                icon is IconData
                    ? icon
                    : Icons.lightbulb_outline,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation['title'].toString(),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    recommendation['description']
                        .toString(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPerformanceSummary() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Current Performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Attendance: '
              '${attendancePercentage.toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 6),
            Text(
              'Assignments: '
              '${assignmentPercentage.toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 6),
            Text(
              'Examinations: '
              '${examinationPercentage.toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 6),
            Text(
              'Assignments Submitted: '
              '$submittedAssignments / $totalAssignments',
            ),
            const SizedBox(height: 6),
            Text(
              'Exam Results Available: $totalResults',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 50,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });

                  loadRecommendations();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadRecommendations,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Personalized Study Recommendations',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'These recommendations are generated from the academic data available for Student ${widget.studentId}.',
          ),
          const SizedBox(height: 18),
          buildPerformanceSummary(),
          ...recommendations.map(
            buildRecommendationCard,
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
          'Study Recommendations',
        ),
      ),
      body: buildBody(),
    );
  }
}