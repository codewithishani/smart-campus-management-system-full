import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StudentAssignmentsScreen extends StatefulWidget {
  final int studentId;

  const StudentAssignmentsScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentAssignmentsScreen> createState() =>
      _StudentAssignmentsScreenState();
}

class _StudentAssignmentsScreenState
    extends State<StudentAssignmentsScreen> {
  List<dynamic> assignments = [];
  List<dynamic> submissions = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadAssignments();
  }

  Future<void> loadAssignments() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getStudent(widget.studentId),
        ApiService.getClasses(),
        ApiService.getAssignments(),
        ApiService.getSubmissions(),
      ]);

      final student = results[0] as Map<String, dynamic>;
      final allClasses = results[1] as List<dynamic>;
      final allAssignments = results[2] as List<dynamic>;
      final allSubmissions = results[3] as List<dynamic>;

      final studentCourseId = student['course_id'];
      final studentSemester = student['semester'];

      // Find the class belonging to this student's course and semester.
      Map<String, dynamic>? studentClass;

      for (final item in allClasses) {
        if (item is! Map) {
          continue;
        }

        final classData = Map<String, dynamic>.from(item);

        final classCourseId = classData['course_id'];
        final classSemester = classData['semester'];

        final courseMatches =
            classCourseId?.toString() ==
                studentCourseId?.toString();

        final semesterMatches =
            classSemester == null ||
            classSemester.toString().isEmpty ||
            classSemester.toString() ==
                studentSemester?.toString();

        if (courseMatches && semesterMatches) {
          studentClass = classData;
          break;
        }
      }

      if (studentClass == null) {
        throw Exception('Student class not found.');
      }

      final classId =
          studentClass['class_id'] ??
          studentClass['id'];

      if (classId == null) {
        throw Exception('Class ID not found.');
      }

      // Only assignments belonging to the student's class.
      final filteredAssignments = allAssignments.where((item) {
        if (item is! Map) {
          return false;
        }

        final assignment =
            Map<String, dynamic>.from(item);

        final assignmentClassId =
            assignment['class_id'] ??
            assignment['classId'];

        return assignmentClassId?.toString() ==
            classId.toString();
      }).toList();

      // Only submissions belonging to the logged-in student.
      final filteredSubmissions = allSubmissions.where((item) {
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

      if (!mounted) {
        return;
      }

      setState(() {
        assignments = filteredAssignments;
        submissions = filteredSubmissions;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load assignments.';
      });
    }
  }

  String getAssignmentTitle(Map<String, dynamic> assignment) {
    return (assignment['title'] ??
            assignment['assignment_title'] ??
            assignment['name'] ??
            'Untitled Assignment')
        .toString();
  }

  String getDescription(Map<String, dynamic> assignment) {
    return (assignment['description'] ??
            assignment['details'] ??
            assignment['instructions'] ??
            '')
        .toString();
  }

  String getDueDate(Map<String, dynamic> assignment) {
    return (assignment['due_date'] ??
            assignment['deadline'] ??
            assignment['submission_date'] ??
            '')
        .toString();
  }

  String getSubjectName(Map<String, dynamic> assignment) {
    return (assignment['subject_name'] ??
            assignment['subject'] ??
            assignment['course_name'] ??
            '')
        .toString();
  }

  dynamic getAssignmentId(
    Map<String, dynamic> assignment,
  ) {
    return assignment['assignment_id'] ??
        assignment['id'] ??
        assignment['assignmentId'];
  }

  bool isSubmitted(
    Map<String, dynamic> assignment,
  ) {
    final assignmentId = getAssignmentId(assignment);

    if (assignmentId == null) {
      return false;
    }

    return submissions.any((submissionItem) {
      if (submissionItem is! Map) {
        return false;
      }

      final submission =
          Map<String, dynamic>.from(submissionItem);

      final submissionAssignmentId =
          submission['assignment_id'] ??
          submission['assignmentId'];

      return submissionAssignmentId?.toString() ==
          assignmentId.toString();
    });
  }

  String formatDate(String date) {
    if (date.isEmpty) {
      return 'Not specified';
    }

    try {
      final parsedDate = DateTime.parse(date);

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
    final title = getAssignmentTitle(assignment);
    final description = getDescription(assignment);
    final dueDate = getDueDate(assignment);
    final subjectName = getSubjectName(assignment);
    final submitted = isSubmitted(assignment);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subjectName.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                subjectName,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(description),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Due Date: ${formatDate(dueDate)}',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Chip(
              label: Text(
                submitted ? 'Submitted' : 'Pending',
              ),
              avatar: Icon(
                submitted
                    ? Icons.check
                    : Icons.pending,
                size: 18,
              ),
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
                onPressed: loadAssignments,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (assignments.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadAssignments,
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
                    'Assignments will appear here when available.',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadAssignments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics:
            const AlwaysScrollableScrollPhysics(),
        itemCount: assignments.length,
        itemBuilder: (context, index) {
          final assignment =
              Map<String, dynamic>.from(
            assignments[index] as Map,
          );

          return buildAssignmentCard(
            assignment,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
      ),
      body: buildBody(),
    );
  }
}