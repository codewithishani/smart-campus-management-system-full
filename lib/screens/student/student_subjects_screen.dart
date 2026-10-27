import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StudentSubjectsScreen extends StatefulWidget {
  final int studentId;

  const StudentSubjectsScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentSubjectsScreen> createState() =>
      _StudentSubjectsScreenState();
}

class _StudentSubjectsScreenState extends State<StudentSubjectsScreen> {
  List<dynamic> subjects = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadSubjects();
  }

  Future<void> loadSubjects() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getStudent(widget.studentId),
        ApiService.getSubjects(),
      ]);

      final student = results[0] as Map<String, dynamic>;
      final allSubjects = results[1] as List<dynamic>;

      final studentCourseId = student['course_id'];
      final studentSemester = student['semester'];

      final filteredSubjects = allSubjects.where((subject) {
        final subjectCourseId = subject['course_id'];
        final subjectSemester = subject['semester'];

        final courseMatches =
            subjectCourseId?.toString() == studentCourseId?.toString();

        // If the subject has a semester, match it with the student's semester.
        // If semester is null/missing, keep it based on course.
        final semesterMatches =
            subjectSemester == null ||
            subjectSemester.toString().isEmpty ||
            subjectSemester.toString() == studentSemester?.toString();

        return courseMatches && semesterMatches;
      }).toList();

      if (!mounted) {
        return;
      }

      setState(() {
        subjects = filteredSubjects;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage = 'Unable to load subjects.';
        isLoading = false;
      });
    }
  }

  Future<void> refreshSubjects() async {
    await loadSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: loadSubjects,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (subjects.isEmpty) {
      return RefreshIndicator(
        onRefresh: refreshSubjects,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 220),
            Center(
              child: Text(
                'No subjects found.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refreshSubjects,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];

          final subjectName =
              subject['subject_name']?.toString() ?? 'Unknown Subject';

          final subjectCode =
              subject['subject_code']?.toString() ?? 'N/A';

          final credits =
              subject['credits']?.toString() ?? 'N/A';

          final semester =
              subject['semester']?.toString() ?? 'N/A';

          final description =
              subject['description']?.toString() ?? '';

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.code,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Code: $subjectCode',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.school,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Credits: $credits',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.menu_book,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Semester: $semester',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}