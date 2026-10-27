import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'faculty_dashboard.dart';

class FacultySubmissionReviewScreen extends StatefulWidget {
  const FacultySubmissionReviewScreen({super.key});

  @override
  State<FacultySubmissionReviewScreen> createState() =>
      _FacultySubmissionReviewScreenState();
}

class _FacultySubmissionReviewScreenState
    extends State<FacultySubmissionReviewScreen> {
  List<dynamic> submissions = [];
  List<dynamic> assignments = [];
  List<dynamic> students = [];
  List<dynamic> subjects = [];
  List<dynamic> classes = [];

 void openSubmissionFile(Map<String, dynamic> submission) {
  final fileUrl = getStringValue(
    submission['file_url'],
  ).trim();

  if (fileUrl.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No file was attached to this submission.'),
      ),
    );
    return;
  }

  final submissionId = getNullableIntValue(
    submission['submission_id'],
  );

  if (submissionId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Submission ID is missing.'),
      ),
    );
    return;
  }

  final url =
      '${ApiService.baseUrl}/submissions/$submissionId/file';

  html.window.open(url, '_blank');
}

  List<Map<String, dynamic>> facultyClasses = [];
  List<Map<String, dynamic>> facultyAssignments = [];
  List<Map<String, dynamic>> facultySubjects = [];

  bool isLoading = true;
  String? errorMessage;

  int? get facultyId => FacultyDashboard.currentFacultyId;

  @override
  void initState() {
    super.initState();
    loadSubmissionData();
  }

  Future<void> loadSubmissionData() async {
    if (facultyId == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'Faculty session not found.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getSubmissions(),
        ApiService.getAssignments(),
        ApiService.getStudents(),
        ApiService.getSubjects(),
        ApiService.getClasses(),
      ]);

      if (!mounted) {
        return;
      }

      submissions = List<dynamic>.from(results[0]);
      assignments = List<dynamic>.from(results[1]);
      students = List<dynamic>.from(results[2]);
      subjects = List<dynamic>.from(results[3]);
      classes = List<dynamic>.from(results[4]);

      buildFacultyData();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load submissions: $e';
      });
    }
  }

  void buildFacultyData() {
    final currentId = facultyId;

    if (currentId == null) {
      facultyClasses = [];
      facultyAssignments = [];
      facultySubjects = [];
      return;
    }

    final classList = <Map<String, dynamic>>[];
    final assignmentList = <Map<String, dynamic>>[];
    final subjectList = <Map<String, dynamic>>[];

    for (final item in classes) {
      final classData = Map<String, dynamic>.from(item as Map);

      final teacherId = getNullableIntValue(
        classData['class_teacher_id'] ?? classData['teacher_id'],
      );

      if (teacherId == currentId) {
        classList.add(classData);
      }
    }

    for (final item in assignments) {
      final assignmentData = Map<String, dynamic>.from(item as Map);

      final assignmentFacultyId = getNullableIntValue(
        assignmentData['faculty_id'],
      );

      if (assignmentFacultyId == currentId) {
        assignmentList.add(assignmentData);
      }
    }

    final facultyClassIds = <int>{};

    for (final item in classList) {
      final classId = getNullableIntValue(item['class_id']);

      if (classId != null) {
        facultyClassIds.add(classId);
      }
    }

    for (final item in assignmentList) {
      final classId = getNullableIntValue(item['class_id']);

      if (classId != null) {
        facultyClassIds.add(classId);
      }
    }

    for (final item in assignments) {
      final assignmentData = Map<String, dynamic>.from(item as Map);

      final assignmentFacultyId = getNullableIntValue(
        assignmentData['faculty_id'],
      );

      if (assignmentFacultyId != currentId) {
        continue;
      }

      final subjectId = getNullableIntValue(
        assignmentData['subject_id'],
      );

      if (subjectId == null) {
        continue;
      }

      final alreadyAdded = subjectList.any(
        (subject) => getNullableIntValue(subject['subject_id']) == subjectId,
      );

      if (alreadyAdded) {
        continue;
      }

      for (final subjectItem in subjects) {
        final subjectData = Map<String, dynamic>.from(subjectItem as Map);
        final currentSubjectId = getNullableIntValue(
          subjectData['subject_id'],
        );

        if (currentSubjectId == subjectId) {
          subjectList.add(subjectData);
          break;
        }
      }
    }

    if (subjectList.isEmpty) {
      for (final item in subjects) {
        final subjectData = Map<String, dynamic>.from(item as Map);
        final classId = getNullableIntValue(subjectData['class_id']);

        if (classId != null && facultyClassIds.contains(classId)) {
          subjectList.add(subjectData);
        }
      }
    }

    facultyClasses = classList;
    facultyAssignments = assignmentList;
    facultySubjects = subjectList;
  }

  int? getIntValue(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }

  int? getNullableIntValue(dynamic value) {
    return getIntValue(value);
  }

  double? getDoubleValue(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value);
    }

    return null;
  }

  String getStringValue(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  int? getClassId(Map<String, dynamic> data) {
    return getNullableIntValue(data['class_id']);
  }

  int? getCourseId(Map<String, dynamic> data) {
    return getNullableIntValue(data['course_id']);
  }

  Map<String, dynamic>? getAssignmentById(int? assignmentId) {
    if (assignmentId == null) {
      return null;
    }

    for (final item in assignments) {
      final assignment = Map<String, dynamic>.from(item as Map);

      if (getNullableIntValue(assignment['assignment_id']) ==
          assignmentId) {
        return assignment;
      }
    }

    return null;
  }

  Map<String, dynamic>? getStudentById(int? studentId) {
    if (studentId == null) {
      return null;
    }

    for (final item in students) {
      final student = Map<String, dynamic>.from(item as Map);

      if (getNullableIntValue(student['student_id']) == studentId) {
        return student;
      }
    }

    return null;
  }

  String getStudentNameById(int? studentId) {
    final student = getStudentById(studentId);

    if (student == null) {
      return 'Unknown Student';
    }

    final firstName = getStringValue(
      student['first_name'] ?? student['firstname'],
    ).trim();

    final lastName = getStringValue(
      student['last_name'] ?? student['lastname'],
    ).trim();

    final fullName = '$firstName $lastName'.trim();

    if (fullName.isNotEmpty) {
      return fullName;
    }

    return getStringValue(
      student['name'] ?? student['student_name'],
    ).trim().isNotEmpty
        ? getStringValue(
            student['name'] ?? student['student_name'],
          )
        : 'Unknown Student';
  }

  String getStudentCodeById(int? studentId) {
    final student = getStudentById(studentId);

    if (student == null) {
      return '-';
    }

    return getStringValue(
      student['student_code'] ??
          student['roll_no'] ??
          student['roll_number'] ??
          student['enrollment_no'],
    );
  }

  String getAssignmentTitleById(int? assignmentId) {
    final assignment = getAssignmentById(assignmentId);

    if (assignment == null) {
      return 'Unknown Assignment';
    }

    return getStringValue(
      assignment['title'],
    ).isNotEmpty
        ? getStringValue(assignment['title'])
        : 'Untitled Assignment';
  }

  int? getAssignmentSubjectId(int? assignmentId) {
    final assignment = getAssignmentById(assignmentId);

    if (assignment == null) {
      return null;
    }

    return getNullableIntValue(
      assignment['subject_id'],
    );
  }

  String getSubjectNameById(int? subjectId) {
    if (subjectId == null) {
      return '-';
    }

    for (final item in subjects) {
      final subject = Map<String, dynamic>.from(item as Map);

      if (getNullableIntValue(subject['subject_id']) == subjectId) {
        final name = getStringValue(
          subject['subject_name'] ?? subject['name'],
        );

        if (name.isNotEmpty) {
          return name;
        }
      }
    }

    return '-';
  }

  bool isAssignmentForFaculty(Map<String, dynamic> assignment) {
    final currentId = facultyId;

    if (currentId == null) {
      return false;
    }

    final assignmentFacultyId = getNullableIntValue(
      assignment['faculty_id'],
    );

    return assignmentFacultyId == currentId;
  }

  bool isStudentInFacultyClass(Map<String, dynamic> student) {
    final studentClassId = getNullableIntValue(
      student['class_id'],
    );

    if (studentClassId == null) {
      return false;
    }

    return facultyClasses.any(
      (facultyClass) =>
          getClassId(facultyClass) == studentClassId,
    );
  }

  bool isSubmissionForFaculty(Map<String, dynamic> submission) {
    final assignmentId = getNullableIntValue(
      submission['assignment_id'],
    );

    final studentId = getNullableIntValue(
      submission['student_id'],
    );

    final assignment = getAssignmentById(assignmentId);

    if (assignment != null && isAssignmentForFaculty(assignment)) {
      return true;
    }

    final student = getStudentById(studentId);

    if (student != null && isStudentInFacultyClass(student)) {
      final assignmentForStudent = getAssignmentById(assignmentId);

      if (assignmentForStudent != null) {
        final assignmentClassId = getNullableIntValue(
          assignmentForStudent['class_id'],
        );

        final studentClassId = getNullableIntValue(
          student['class_id'],
        );

        if (assignmentClassId != null &&
            studentClassId != null &&
            assignmentClassId == studentClassId) {
          return true;
        }
      }
    }

    return false;
  }

  List<Map<String, dynamic>> getFilteredSubmissions() {
    final result = <Map<String, dynamic>>[];

    for (final item in submissions) {
      final submission = Map<String, dynamic>.from(item as Map);

      if (isSubmissionForFaculty(submission)) {
        result.add(submission);
      }
    }

    return result;
  }

  String getSubmissionStatus(Map<String, dynamic> submission) {
    final status = getStringValue(
      submission['status'],
    ).trim();

    if (status.isEmpty) {
      return 'Submitted';
    }

    return status;
  }

  DateTime? getSubmissionDate(Map<String, dynamic> submission) {
    final rawDate = submission['submission_date'];

    if (rawDate is DateTime) {
      return rawDate;
    }

    if (rawDate == null) {
      return null;
    }

    return DateTime.tryParse(rawDate.toString());
  }

  String formatSubmissionDate(Map<String, dynamic> submission) {
    final date = getSubmissionDate(submission);

    if (date == null) {
      return '-';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'approved':
      case 'reviewed':
        return Colors.green;

      case 'rejected':
        return Colors.red;

      case 'submitted':
      case 'pending':
        return Colors.orange;

      default:
        return Colors.blueGrey;
    }
  }

  int getPendingCount(List<Map<String, dynamic>> data) {
    return data.where((submission) {
      final status = getSubmissionStatus(submission).toLowerCase();

      return status == 'submitted' || status == 'pending';
    }).length;
  }

  int getReviewedCount(List<Map<String, dynamic>> data) {
    return data.where((submission) {
      final status = getSubmissionStatus(submission).toLowerCase();

      return status == 'accepted' ||
          status == 'rejected' ||
          status == 'reviewed' ||
          status == 'approved';
    }).length;
  }

  Future<void> showSubmissionDetails(
    Map<String, dynamic> submission,
  ) async {
    final assignmentId = getNullableIntValue(
      submission['assignment_id'],
    );

    final studentId = getNullableIntValue(
      submission['student_id'],
    );

    final assignment = getAssignmentById(assignmentId);
    final subjectId = getAssignmentSubjectId(assignmentId);

    final marks = getDoubleValue(
      submission['marks'],
    );

    final feedback = getStringValue(
      submission['feedback'],
    );

    final currentStatus = getSubmissionStatus(
      submission,
    );

    final marksController = TextEditingController(
      text: marks == null ? '' : marks.toString(),
    );

    final feedbackController = TextEditingController(
      text: feedback,
    );

    String selectedStatus = currentStatus;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> saveReview() async {
              if (isSaving) {
                return;
              }

              final parsedMarks = double.tryParse(
                marksController.text.trim(),
              );

              if (marksController.text.trim().isNotEmpty &&
                  parsedMarks == null) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter valid marks.'),
                  ),
                );
                return;
              }

              if (assignmentId == null || studentId == null) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Assignment or student information is missing.',
                    ),
                  ),
                );
                return;
              }

              final submissionId = getNullableIntValue(
                submission['submission_id'],
              );

              if (submissionId == null) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Submission ID is missing.',
                    ),
                  ),
                );
                return;
              }

              final submissionDate =
                  getSubmissionDate(submission);

              if (submissionDate == null) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Submission date is missing or invalid.',
                    ),
                  ),
                );
                return;
              }

              final confirmed = await showDialog<bool>(
                context: dialogContext,
                builder: (confirmContext) {
                  return AlertDialog(
                    title: const Text('Confirm Review'),
                    content: Text(
                      'Are you sure you want to mark this submission as "$selectedStatus"?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(confirmContext).pop(false);
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(confirmContext).pop(true);
                        },
                        child: const Text('Confirm'),
                      ),
                    ],
                  );
                },
              );

              if (confirmed != true) {
                return;
              }

              setDialogState(() {
                isSaving = true;
              });

              try {
                await ApiService.updateSubmission(
                  submissionId: submissionId,
                  assignmentId: assignmentId,
                  studentId: studentId,
                  fileUrl: getStringValue(
                    submission['file_url'],
                  ).isEmpty
                      ? null
                      : getStringValue(
                          submission['file_url'],
                        ),
                  submissionDate: submissionDate,
                  status: selectedStatus,
                  marks: parsedMarks,
                  feedback:
                      feedbackController.text.trim().isEmpty
                          ? null
                          : feedbackController.text.trim(),
                );

                if (!dialogContext.mounted) {
                  return;
                }

                Navigator.of(dialogContext).pop(true);
              } catch (e) {
                if (!dialogContext.mounted) {
                  return;
                }

                setDialogState(() {
                  isSaving = false;
                });

                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to save review: $e',
                    ),
                  ),
                );
              }
            }

            return AlertDialog(
              title: const Text('Review Submission'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow(
                        'Student',
                        getStudentNameById(studentId),
                      ),
                      _detailRow(
                        'Roll No.',
                        getStudentCodeById(studentId),
                      ),
                      _detailRow(
                        'Assignment',
                        getAssignmentTitleById(assignmentId),
                      ),
                      _detailRow(
                        'Subject',
                        getSubjectNameById(subjectId),
                      ),
                      _detailRow(
                        'Submitted',
                        formatSubmissionDate(submission),
                      ),
                      if (assignment != null)
                        _detailRow(
                          'Due Date',
                          getStringValue(
                            assignment['due_date'],
                          ),
                        ),
                      const SizedBox(height: 20),
                      const Text(
                        'Review Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: selectedStatus,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Status',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Submitted',
                            child: Text('Submitted'),
                          ),
                          DropdownMenuItem(
                            value: 'Accepted',
                            child: Text('Accepted'),
                          ),
                          DropdownMenuItem(
                            value: 'Rejected',
                            child: Text('Rejected'),
                          ),
                          DropdownMenuItem(
                            value: 'Reviewed',
                            child: Text('Reviewed'),
                          ),
                        ],
                        onChanged: isSaving
                            ? null
                            : (value) {
                                if (value == null) {
                                  return;
                                }

                                setDialogState(() {
                                  selectedStatus = value;
                                });
                              },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: marksController,
                        enabled: !isSaving,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Marks',
                          hintText: 'Enter marks',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: feedbackController,
                        enabled: !isSaving,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Feedback',
                          hintText: 'Enter feedback for the student',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop(false);
                        },
                  child: const Text('Cancel'),
                ),
                if (!isSaving)
                  TextButton(
                    onPressed: () {
                      setDialogState(() {
                        selectedStatus = 'Rejected';
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Reject'),
                  ),
                if (!isSaving)
                  ElevatedButton(
                    onPressed: () {
                      setDialogState(() {
                        selectedStatus = 'Accepted';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accept'),
                  ),
                ElevatedButton(
                  onPressed: isSaving ? null : saveReview,
                  child: isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Review'),
                ),
              ],
            );
          },
        );
      },
    );

    marksController.dispose();
    feedbackController.dispose();

    if (result == true && mounted) {
      await loadSubmissionData();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Submission review saved successfully.',
          ),
        ),
      );
    }
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 22,
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
    );
  }

  Widget buildSubmissionCard(
    Map<String, dynamic> submission,
  ) {
    final studentId = getNullableIntValue(
      submission['student_id'],
    );

    final assignmentId = getNullableIntValue(
      submission['assignment_id'],
    );

    final status = getSubmissionStatus(
      submission,
    );

    final marks = getDoubleValue(
      submission['marks'],
    );

    final feedback = getStringValue(
      submission['feedback'],
    );

    final statusColor = getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  child: Icon(Icons.assignment_turned_in),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        getStudentNameById(studentId),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        getAssignmentTitleById(assignmentId),
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 18,
              runSpacing: 8,
              children: [
                _infoItem(
                  Icons.badge_outlined,
                  'Roll No.',
                  getStudentCodeById(studentId),
                ),
                _infoItem(
                  Icons.menu_book_outlined,
                  'Subject',
                  getSubjectNameById(
                    getAssignmentSubjectId(assignmentId),
                  ),
                ),
                _infoItem(
                  Icons.calendar_today_outlined,
                  'Submitted',
                  formatSubmissionDate(submission),
                ),
                _infoItem(
                  Icons.grade_outlined,
                  'Marks',
                  marks == null ? '-' : marks.toString(),
                ),
              ],
            ),
            if (feedback.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Feedback: $feedback',
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
  alignment: WrapAlignment.end,
  spacing: 10,
  runSpacing: 8,
  children: [
    OutlinedButton.icon(
      onPressed:
          getStringValue(submission['file_url']).trim().isEmpty
              ? null
              : () => openSubmissionFile(submission),
      icon: const Icon(Icons.download_outlined),
      label: const Text('View / Download File'),
    ),
    ElevatedButton.icon(
      onPressed: () {
        showSubmissionDetails(submission);
      },
      icon: const Icon(Icons.rate_review_outlined),
      label: const Text('Review'),
    ),
  ],
),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 5),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredSubmissions = getFilteredSubmissions();
    final pendingCount = getPendingCount(
      filteredSubmissions,
    );
    final reviewedCount = getReviewedCount(
      filteredSubmissions,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submission Review'),
        actions: [
          IconButton(
            onPressed: isLoading
                ? null
                : loadSubmissionData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 52,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: loadSubmissionData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : facultyId == null
                  ? const Center(
                      child: Text(
                        'Faculty session not found.',
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: loadSubmissionData,
                      child: filteredSubmissions.isEmpty
                          ? ListView(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(24),
                              children: const [
                                SizedBox(height: 120),
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Center(
                                  child: Text(
                                    'No submissions found.',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    'Student submissions for your assignments will appear here.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            )
                          : ListView(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              children: [
                                Row(
                                  children: [
                                    buildStatCard(
                                      title: 'Total',
                                      value:
                                          filteredSubmissions.length
                                              .toString(),
                                      icon:
                                          Icons.assignment_outlined,
                                    ),
                                    const SizedBox(width: 10),
                                    buildStatCard(
                                      title: 'Pending',
                                      value:
                                          pendingCount.toString(),
                                      icon:
                                          Icons.pending_actions,
                                    ),
                                    const SizedBox(width: 10),
                                    buildStatCard(
                                      title: 'Reviewed',
                                      value:
                                          reviewedCount.toString(),
                                      icon:
                                          Icons.check_circle_outline,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ...filteredSubmissions.map(
                                  buildSubmissionCard,
                                ),
                              ],
                            ),
                    ),
    );
  }
}