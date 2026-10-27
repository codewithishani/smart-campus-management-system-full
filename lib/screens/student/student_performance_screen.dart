import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class StudentPerformanceScreen extends StatefulWidget {
  final int studentId;

  const StudentPerformanceScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentPerformanceScreen> createState() =>
      _StudentPerformanceScreenState();
}

class _StudentPerformanceScreenState
    extends State<StudentPerformanceScreen> {
  bool isLoading = true;
  String? errorMessage;

  double attendancePercentage = 0;
  double assignmentPercentage = 0;
  double examinationPercentage = 0;
  double overallPercentage = 0;

  int totalAttendanceRecords = 0;
  int presentAttendanceRecords = 0;

  int totalAssignments = 0;
  int submittedAssignments = 0;

  int totalResults = 0;

  @override
  void initState() {
    super.initState();
    loadPerformance();
  }

  Future<void> loadPerformance() async {
    try {
      final student =
          await ApiService.getStudent(widget.studentId);
      final attendanceData =
          await ApiService.getAttendance();
      final classesData =
          await ApiService.getClasses();
      final assignmentData =
          await ApiService.getAssignments();
      final submissionData =
          await ApiService.getSubmissions();
      final resultData =
          await ApiService.getResults();

      if (!mounted) return;

      final studentMap =
          Map<String, dynamic>.from(student);

      final courseId = _toInt(
        studentMap['course_id'] ??
            studentMap['courseId'],
      );

      final semester = _toInt(
        studentMap['semester'],
      );

      int? studentClassId;

      for (final item in classesData) {
        if (item is! Map) {
          continue;
        }

        final classData =
            Map<String, dynamic>.from(item);

        final classCourseId = _toInt(
          classData['course_id'] ??
              classData['courseId'],
        );

        final classSemester = _toInt(
          classData['semester'],
        );

        if (classCourseId == courseId &&
            classSemester == semester) {
          studentClassId = _toInt(
            classData['class_id'] ??
                classData['classId'],
          );
          break;
        }
      }

      final studentAttendance =
          attendanceData.where((item) {
        if (item is! Map) {
          return false;
        }

        final attendance =
            Map<String, dynamic>.from(item);

        final recordStudentId = _toInt(
          attendance['student_id'] ??
              attendance['studentId'],
        );

        return recordStudentId ==
            widget.studentId;
      }).toList();

      final studentAssignments =
          assignmentData.where((item) {
        if (item is! Map) {
          return false;
        }

        final assignment =
            Map<String, dynamic>.from(item);

        final assignmentClassId = _toInt(
          assignment['class_id'] ??
              assignment['classId'],
        );

        return studentClassId != null &&
            assignmentClassId ==
                studentClassId;
      }).toList();

      final studentSubmissions =
          submissionData.where((item) {
        if (item is! Map) {
          return false;
        }

        final submission =
            Map<String, dynamic>.from(item);

        final submissionStudentId = _toInt(
          submission['student_id'] ??
              submission['studentId'],
        );

        return submissionStudentId ==
            widget.studentId;
      }).toList();

      final studentResults =
          resultData.where((item) {
        if (item is! Map) {
          return false;
        }

        final result =
            Map<String, dynamic>.from(item);

        final resultStudentId = _toInt(
          result['student_id'] ??
              result['studentId'],
        );

        return resultStudentId ==
            widget.studentId;
      }).toList();

      final attendanceValue =
          calculateAttendancePercentage(
        studentAttendance,
      );

      final assignmentValue =
          calculateAssignmentPercentage(
        studentAssignments,
        studentSubmissions,
      );

      final examValue =
          calculateExamPercentage(
        studentResults,
      );

      final overallValue =
          calculateOverallPercentage(
        attendanceValue,
        assignmentValue,
        examValue,
      );

      if (!mounted) return;

      setState(() {
        attendancePercentage =
            attendanceValue;
        assignmentPercentage =
            assignmentValue;
        examinationPercentage =
            examValue;
        overallPercentage =
            overallValue;

        totalAttendanceRecords =
            studentAttendance.length;

        presentAttendanceRecords =
            countPresentAttendance(
          studentAttendance,
        );

        totalAssignments =
            studentAssignments.length;

        submittedAssignments =
            countSubmittedAssignments(
          studentAssignments,
          studentSubmissions,
        );

        totalResults =
            studentResults.length;

        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load performance insights.';
      });
    }
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
  }

  double calculateAttendancePercentage(
    List<dynamic> attendance,
  ) {
    if (attendance.isEmpty) {
      return 0;
    }

    final present =
        countPresentAttendance(attendance);

    return (present / attendance.length) * 100;
  }

  int countPresentAttendance(
    List<dynamic> attendance,
  ) {
    int present = 0;

    for (final item in attendance) {
      if (item is! Map) {
        continue;
      }

      final record =
          Map<String, dynamic>.from(item);

      final status =
          (record['status'] ?? '')
              .toString()
              .toLowerCase();

      final isPresent =
          record['is_present'] == true ||
          record['present'] == true ||
          status == 'present' ||
          status == 'p' ||
          status == 'attended';

      if (isPresent) {
        present++;
      }
    }

    return present;
  }

  double calculateAssignmentPercentage(
    List<dynamic> assignments,
    List<dynamic> submissions,
  ) {
    if (assignments.isEmpty) {
      return 0;
    }

    final submitted =
        countSubmittedAssignments(
      assignments,
      submissions,
    );

    return ((submitted / assignments.length) * 100)
        .clamp(0, 100)
        .toDouble();
  }

  int countSubmittedAssignments(
    List<dynamic> assignments,
    List<dynamic> submissions,
  ) {
    final submittedAssignmentIds =
        <int>{};

    for (final item in submissions) {
      if (item is! Map) {
        continue;
      }

      final submission =
          Map<String, dynamic>.from(item);

      final assignmentId = _toInt(
        submission['assignment_id'] ??
            submission['assignmentId'],
      );

      if (assignmentId != null) {
        submittedAssignmentIds.add(
          assignmentId,
        );
      }
    }

    int count = 0;

    for (final item in assignments) {
      if (item is! Map) {
        continue;
      }

      final assignment =
          Map<String, dynamic>.from(item);

      final assignmentId = _toInt(
        assignment['assignment_id'] ??
            assignment['assignmentId'],
      );

      if (assignmentId != null &&
          submittedAssignmentIds.contains(
            assignmentId,
          )) {
        count++;
      }
    }

    return count;
  }

  double calculateExamPercentage(
    List<dynamic> results,
  ) {
    if (results.isEmpty) {
      return 0;
    }

    double obtained = 0;
    double total = 0;

    for (final item in results) {
      if (item is! Map) {
        continue;
      }

      final result =
          Map<String, dynamic>.from(item);

      final marksValue =
          result['marks_obtained'] ??
              result['marksObtained'] ??
              result['marks'];

      final totalValue =
          result['total_marks'] ??
              result['totalMarks'] ??
              result['max_marks'] ??
              result['maximum_marks'];

      final marks =
          double.tryParse(
                marksValue?.toString() ?? '',
              ) ??
              0;

      final totalMarks =
          double.tryParse(
                totalValue?.toString() ?? '',
              ) ??
              0;

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

  double calculateOverallPercentage(
    double attendance,
    double assignments,
    double examinations,
  ) {
    final availableValues =
        <double>[];

    if (attendance > 0) {
      availableValues.add(attendance);
    }

    if (assignments > 0) {
      availableValues.add(assignments);
    }

    if (examinations > 0) {
      availableValues.add(examinations);
    }

    if (availableValues.isEmpty) {
      return 0;
    }

    double total = 0;

    for (final value in availableValues) {
      total += value;
    }

    return total / availableValues.length;
  }

  String getPerformanceMessage() {
    if (overallPercentage >= 85) {
      return 'Your overall academic performance is strong. Continue maintaining your current study habits.';
    }

    if (overallPercentage >= 70) {
      return 'Your academic performance is good. Continue focusing on regular attendance and assignments.';
    }

    if (overallPercentage >= 50) {
      return 'Your performance has room for improvement. Focus on attendance, assignments, and exam preparation.';
    }

    return 'Keep working consistently on your studies, attendance, assignments, and examination preparation.';
  }

  String formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  Widget buildOverallCard() {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Overall Performance',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              formatPercentage(
                overallPercentage,
              ),
              style: const TextStyle(
                fontSize: 34,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value:
                  overallPercentage / 100,
              minHeight: 10,
            ),
            const SizedBox(height: 8),
            Text(
              '${formatPercentage(overallPercentage)} '
              'Academic Performance',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPerformanceCard(
    String title,
    String value,
    IconData icon,
    double progress,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              child: Icon(icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  LinearProgressIndicator(
                    value:
                        progress / 100,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatisticsCard() {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding:
                  EdgeInsets.zero,
              leading:
                  const Icon(Icons.fact_check),
              title:
                  const Text('Attendance Records'),
              trailing: Text(
                '$presentAttendanceRecords / '
                '$totalAttendanceRecords',
                style: const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              contentPadding:
                  EdgeInsets.zero,
              leading:
                  const Icon(Icons.assignment),
              title:
                  const Text('Assignments Submitted'),
              trailing: Text(
                '$submittedAssignments / '
                '$totalAssignments',
                style: const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              contentPadding:
                  EdgeInsets.zero,
              leading:
                  const Icon(Icons.school),
              title:
                  const Text('Exam Results'),
              trailing: Text(
                totalResults.toString(),
                style: const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInsightCard() {
    return Card(
      child: ListTile(
        leading:
            const Icon(Icons.lightbulb),
        title: const Text(
          'Performance Insight',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding:
              const EdgeInsets.only(top: 6),
          child: Text(
            getPerformanceMessage(),
          ),
        ),
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.all(24),
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
                textAlign:
                    TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });

                  loadPerformance();
                },
                child:
                    const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadPerformance,
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            buildOverallCard(),

            const SizedBox(height: 14),

            buildPerformanceCard(
              'Attendance',
              formatPercentage(
                attendancePercentage,
              ),
              Icons.calendar_month,
              attendancePercentage,
            ),

            buildPerformanceCard(
              'Assignments',
              formatPercentage(
                assignmentPercentage,
              ),
              Icons.assignment,
              assignmentPercentage,
            ),

            buildPerformanceCard(
              'Examinations',
              formatPercentage(
                examinationPercentage,
              ),
              Icons.school,
              examinationPercentage,
            ),

            buildStatisticsCard(),

            const SizedBox(height: 4),

            buildInsightCard(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Performance Insights'),
      ),
      body: buildBody(),
    );
  }
}