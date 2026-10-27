import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class StudentAssignmentStatusScreen extends StatefulWidget {
  final int studentId;

  const StudentAssignmentStatusScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentAssignmentStatusScreen> createState() =>
      _StudentAssignmentStatusScreenState();
}

class _StudentAssignmentStatusScreenState
    extends State<StudentAssignmentStatusScreen> {
  List<dynamic> assignments = [];
  List<dynamic> submissions = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final results = await Future.wait([
        ApiService.getStudent(widget.studentId),
        ApiService.getClasses(),
        ApiService.getAssignments(),
        ApiService.getSubmissions(),
      ]);

      if (!mounted) return;

      if (results[0] is! Map) {
        throw Exception('Invalid student data.');
      }

      final student =
          Map<String, dynamic>.from(results[0] as Map);

      final classes =
          results[1] is List ? results[1] as List<dynamic> : <dynamic>[];

      final assignmentData =
          results[2] is List ? results[2] as List<dynamic> : <dynamic>[];

      final submissionData =
          results[3] is List ? results[3] as List<dynamic> : <dynamic>[];

      final courseId =
          student['course_id'] ?? student['courseId'];

      final semester =
          student['semester'];

      Map<String, dynamic>? studentClass;

      for (final item in classes) {
        if (item is! Map) {
          continue;
        }

        final classData =
            Map<String, dynamic>.from(item);

        final classCourseId =
            classData['course_id'] ??
                classData['courseId'];

        final classSemester =
            classData['semester'];

        if (classCourseId?.toString() ==
                courseId?.toString() &&
            classSemester?.toString() ==
                semester?.toString()) {
          studentClass = classData;
          break;
        }
      }

      final classId =
          studentClass?['class_id'] ??
              studentClass?['id'] ??
              studentClass?['classId'];

      final filteredAssignments =
          assignmentData.where((item) {
        if (item is! Map) {
          return false;
        }

        final assignment =
            Map<String, dynamic>.from(item);

        final assignmentClassId =
            assignment['class_id'] ??
                assignment['classId'];

        if (classId == null ||
            assignmentClassId == null) {
          return false;
        }

        return assignmentClassId.toString() ==
            classId.toString();
      }).toList();

      final filteredSubmissions =
          submissionData.where((item) {
        if (item is! Map) {
          return false;
        }

        final submission =
            Map<String, dynamic>.from(item);

        final submissionStudentId =
            submission['student_id'] ??
                submission['studentId'];

        return submissionStudentId?.toString() ==
            widget.studentId.toString();
      }).toList();

      setState(() {
        assignments = filteredAssignments;
        submissions = filteredSubmissions;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load assignment status.';
      });
    }
  }

  int? getAssignmentId(
    Map<String, dynamic> assignment,
  ) {
    final value =
        assignment['assignment_id'] ??
            assignment['id'] ??
            assignment['assignmentId'];

    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
  }

  String getAssignmentTitle(
    Map<String, dynamic> assignment,
  ) {
    return (assignment['title'] ??
            assignment['assignment_title'] ??
            assignment['name'] ??
            'Untitled Assignment')
        .toString();
  }

  String getSubjectName(
    Map<String, dynamic> assignment,
  ) {
    return (assignment['subject_name'] ??
            assignment['subject'] ??
            assignment['course_name'] ??
            '')
        .toString();
  }

  String getDueDate(
    Map<String, dynamic> assignment,
  ) {
    return (assignment['due_date'] ??
            assignment['deadline'] ??
            assignment['submission_date'] ??
            '')
        .toString();
  }

  Map<String, dynamic>? getSubmission(
    int assignmentId,
  ) {
    for (final item in submissions) {
      if (item is! Map) {
        continue;
      }

      final submission =
          Map<String, dynamic>.from(item);

      final submissionAssignmentId =
          submission['assignment_id'] ??
              submission['assignmentId'];

      if (submissionAssignmentId?.toString() ==
          assignmentId.toString()) {
        return submission;
      }
    }

    return null;
  }

  String getStatus(
    Map<String, dynamic> assignment,
  ) {
    final assignmentId =
        getAssignmentId(assignment);

    if (assignmentId == null) {
      return 'Pending';
    }

    final submission =
        getSubmission(assignmentId);

    if (submission == null) {
      return 'Pending';
    }

    final status =
        submission['status']?.toString().trim();

    if (submission['marks'] != null) {
      return 'Checked';
    }

    if (status == null || status.isEmpty) {
      return 'Submitted';
    }

    return status;
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;

      case 'submitted':
        return Colors.blue;

      case 'checked':
      case 'evaluated':
      case 'graded':
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;

      case 'submitted':
        return Icons.check_circle_outline;

      case 'checked':
      case 'evaluated':
      case 'graded':
        return Icons.verified;

      default:
        return Icons.info_outline;
    }
  }

  String formatDate(String date) {
    if (date.isEmpty) {
      return 'Not specified';
    }

    try {
      final parsedDate =
          DateTime.parse(date);

      return '${parsedDate.day.toString().padLeft(2, '0')}-'
          '${parsedDate.month.toString().padLeft(2, '0')}-'
          '${parsedDate.year}';
    } catch (_) {
      return date;
    }
  }

  Widget buildAssignmentCard(
    Map<String, dynamic> assignment,
  ) {
    final title =
        getAssignmentTitle(assignment);

    final subject =
        getSubjectName(assignment);

    final dueDate =
        getDueDate(assignment);

    final status =
        getStatus(assignment);

    final statusColor =
        getStatusColor(status);

    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding:
            const EdgeInsets.all(14),
        leading: CircleAvatar(
          child: Icon(
            getStatusIcon(status),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding:
              const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              if (subject.isNotEmpty)
                Text(
                  'Subject: $subject',
                ),
              const SizedBox(height: 4),
              Text(
                'Due: ${formatDate(dueDate)}',
              ),
            ],
          ),
        ),
        trailing: Text(
          status,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
      ),
    );
  }

  Widget buildSummary() {
    int pending = 0;
    int submitted = 0;
    int checked = 0;

    for (final item in assignments) {
      if (item is! Map) {
        continue;
      }

      final assignment =
          Map<String, dynamic>.from(item);

      final status =
          getStatus(assignment).toLowerCase();

      if (status == 'pending') {
        pending++;
      } else if (status == 'submitted') {
        submitted++;
      } else if (status == 'checked' ||
          status == 'evaluated' ||
          status == 'graded') {
        checked++;
      }
    }

    return Card(
      margin:
          const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceAround,
          children: [
            buildSummaryItem(
              'Total',
              assignments.length.toString(),
              Icons.assignment,
            ),
            buildSummaryItem(
              'Pending',
              pending.toString(),
              Icons.pending,
            ),
            buildSummaryItem(
              'Submitted',
              submitted.toString(),
              Icons.check_circle_outline,
            ),
            buildSummaryItem(
              'Checked',
              checked.toString(),
              Icons.verified,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSummaryItem(
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
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

                  loadData();
                },
                child:
                    const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (assignments.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 60,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No assignments available.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Assignment status will appear here.',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadData,
      child: ListView(
        padding:
            const EdgeInsets.all(16),
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          const Text(
            'Assignment Status',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          buildSummary(),
          ...assignments.map((item) {
            if (item is! Map) {
              return const SizedBox.shrink();
            }

            final assignment =
                Map<String, dynamic>.from(item);

            return buildAssignmentCard(
              assignment,
            );
          }),
        ],
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
            const Text('Assignment Status'),
      ),
      body: buildBody(),
    );
  }
}