import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StudentSubmissionScreen extends StatefulWidget {
  final int studentId;

  const StudentSubmissionScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentSubmissionScreen> createState() =>
      _StudentSubmissionScreenState();
}

class _StudentSubmissionScreenState
    extends State<StudentSubmissionScreen> {
  List<dynamic> assignments = [];
  List<dynamic> submissions = [];

  int? selectedAssignmentId;
  String? selectedFileName;
  PlatformFile? selectedFile;

  bool isLoading = true;
  bool isSubmitting = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
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
      final classes = results[1] as List<dynamic>;
      final allAssignments = results[2] as List<dynamic>;
      final allSubmissions = results[3] as List<dynamic>;

      final studentCourseId = student['course_id'];
      final studentSemester = student['semester'];

      Map<String, dynamic>? studentClass;

      for (final item in classes) {
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
        throw Exception('Student class ID not found.');
      }

      final studentAssignments =
          allAssignments.where((item) {
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

      final studentSubmissions =
          allSubmissions.where((item) {
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

      int? firstAssignmentId;

      if (studentAssignments.isNotEmpty &&
          studentAssignments.first is Map) {
        final firstAssignment =
            Map<String, dynamic>.from(
          studentAssignments.first as Map,
        );

        firstAssignmentId =
            getAssignmentId(firstAssignment);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        assignments = studentAssignments;
        submissions = studentSubmissions;
        selectedAssignmentId = firstAssignmentId;
        selectedFileName = null;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load assignments.';
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
    return (
      assignment['title'] ??
      assignment['assignment_title'] ??
      assignment['name'] ??
      'Untitled Assignment'
    ).toString();
  }

  String getSubjectName(
    Map<String, dynamic> assignment,
  ) {
    return (
      assignment['subject_name'] ??
      assignment['subject'] ??
      assignment['course_name'] ??
      ''
    ).toString();
  }

  String getDueDate(
    Map<String, dynamic> assignment,
  ) {
    return (
      assignment['due_date'] ??
      assignment['deadline'] ??
      assignment['submission_date'] ??
      ''
    ).toString();
  }

  Map<String, dynamic>? getSelectedAssignment() {
    for (final item in assignments) {
      if (item is! Map) {
        continue;
      }

      final assignment =
          Map<String, dynamic>.from(item);

      if (getAssignmentId(assignment) ==
          selectedAssignmentId) {
        return assignment;
      }
    }

    return null;
  }

  bool isAlreadySubmitted(
    int assignmentId,
  ) {
    return submissions.any((item) {
      if (item is! Map) {
        return false;
      }

      final submission =
          Map<String, dynamic>.from(item);

      final submissionAssignmentId =
          submission['assignment_id'] ??
          submission['assignmentId'];

      return submissionAssignmentId?.toString() ==
          assignmentId.toString();
    });
  }

 Future<void> chooseFile() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: true,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'ppt',
        'pptx',
        'xls',
        'xlsx',
        'zip',
        'txt',
      ],
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.first;

    if (file.bytes == null || file.bytes!.isEmpty) {
      if (!mounted) return;
      showMessage('Could not read the file. Please select it again.');
      return;
    }

    if (!mounted) return;

    setState(() {
      selectedFile = file;
      selectedFileName = file.name;
    });

    showMessage('File selected: ${file.name}');
  } catch (e) {
    if (!mounted) return;
    showMessage('Unable to select the file.');
  }
}

  Future<void> submitAssignment() async {
if (selectedAssignmentId == null) {
showMessage('Please select an assignment.');
return;
}

if (isAlreadySubmitted(selectedAssignmentId!)) {
showMessage('This assignment has already been submitted.');
return;
}

final file = selectedFile;

if (file == null || file.bytes == null || file.bytes!.isEmpty) {
showMessage('Please select the file again.');
return;
}

setState(() {
isSubmitting = true;
});

try {
await ApiService.uploadSubmission(
assignmentId: selectedAssignmentId!,
studentId: widget.studentId,
file: file,
);

final updatedSubmissions = await ApiService.getSubmissions();

final filteredSubmissions = updatedSubmissions.where((item) {
  if (item is! Map) return false;

  final submission = Map<String, dynamic>.from(item);
  final submissionStudentId =
      submission['student_id'] ?? submission['studentId'];

  return submissionStudentId?.toString() ==
      widget.studentId.toString();
}).toList();

if (!mounted) return;

setState(() {
  submissions = filteredSubmissions;
  isSubmitting = false;
  selectedFileName = null;
  selectedFile = null;
});

showMessage('Assignment submitted successfully.');

} catch (e) {
if (!mounted) return;

setState(() {
  isSubmitting = false;
});

showMessage('Failed to submit assignment: $e');

}
}

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
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

  Widget buildAssignmentDropdown() {
    if (assignments.isEmpty) {
      return const Text(
        'No assignments available.',
      );
    }

    return DropdownButtonFormField<int>(
      initialValue: selectedAssignmentId,
      decoration: const InputDecoration(
        labelText: 'Select Assignment',
        border: OutlineInputBorder(),
      ),
      items: assignments
          .whereType<Map>()
          .map((item) {
        final assignment =
            Map<String, dynamic>.from(item);

        final id =
            getAssignmentId(assignment);

        if (id == null) {
          return null;
        }

        return DropdownMenuItem<int>(
          value: id,
          child: Text(
            getAssignmentTitle(
              assignment,
            ),
          ),
        );
      })
          .whereType<DropdownMenuItem<int>>()
          .toList(),
      onChanged: isSubmitting
          ? null
          : (value) {
              setState(() {
  selectedAssignmentId = value;
  selectedFileName = null;
  selectedFile = null;
});
            },
    );
  }

  Widget buildSelectedAssignmentInfo() {
    final assignment =
        getSelectedAssignment();

    if (assignment == null) {
      return const SizedBox.shrink();
    }

    final assignmentId =
        getAssignmentId(assignment);

    final submitted =
        assignmentId != null &&
        isAlreadySubmitted(
          assignmentId,
        );

    final subject =
        getSubjectName(assignment);

    final dueDate =
        getDueDate(assignment);

    return Card(
      margin: const EdgeInsets.only(
        top: 16,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              getAssignmentTitle(
                assignment,
              ),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subject.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Subject: $subject',
              ),
            ],
            if (dueDate.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Due Date: ${formatDate(dueDate)}',
              ),
            ],
            const SizedBox(height: 10),
            Chip(
              avatar: Icon(
                submitted
                    ? Icons.check_circle
                    : Icons.pending,
                size: 18,
              ),
              label: Text(
                submitted
                    ? 'Already Submitted'
                    : 'Not Submitted',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFileCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_upload,
              size: 55,
            ),
            const SizedBox(height: 12),
            const Text(
              'Assignment File',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose the assignment file '
              'from your device.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (selectedFileName != null) ...[
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(8),
                  border: Border.all(),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.insert_drive_file,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        selectedFileName!,
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed:
                  isSubmitting
                      ? null
                      : chooseFile,
              icon: const Icon(
                Icons.attach_file,
              ),
              label: Text(
                selectedFileName == null
                    ? 'Choose File'
                    : 'Change File',
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
                onPressed: loadData,
                child:
                    const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (assignments.isEmpty) {
      return const Center(
        child: Padding(
          padding:
              EdgeInsets.all(24),
          child: Text(
            'No assignments are available for submission.',
            textAlign:
                TextAlign.center,
          ),
        ),
      );
    }

    final alreadySubmitted =
        selectedAssignmentId != null &&
        isAlreadySubmitted(
          selectedAssignmentId!,
        );

    return RefreshIndicator(
      onRefresh: loadData,
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit Assignment',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            buildAssignmentDropdown(),
            buildSelectedAssignmentInfo(),
            const SizedBox(height: 20),
            buildFileCard(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child:
                  ElevatedButton.icon(
                onPressed:
                    isSubmitting ||
                            alreadySubmitted
                        ? null
                        : submitAssignment,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.send,
                      ),
                label: Text(
                  isSubmitting
                      ? 'Submitting...'
                      : alreadySubmitted
                          ? 'Already Submitted'
                          : 'Submit Assignment',
                ),
              ),
            ),
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
        title: const Text(
          'Assignment Submission',
        ),
      ),
      body: buildBody(),
    );
  }
}