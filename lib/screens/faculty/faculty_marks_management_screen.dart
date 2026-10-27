import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'faculty_dashboard.dart';

class FacultyMarksManagementScreen extends StatefulWidget {
  const FacultyMarksManagementScreen({super.key});

  @override
  State<FacultyMarksManagementScreen> createState() =>
      _FacultyMarksManagementScreenState();
}

class _FacultyMarksManagementScreenState
    extends State<FacultyMarksManagementScreen> {
  List<dynamic> students = [];
  List<dynamic> results = [];
  List<dynamic> subjects = [];
  List<dynamic> exams = [];
  List<dynamic> classes = [];
  List<dynamic> assignments = [];

  List<Map<String, dynamic>> facultyClasses = [];
  List<Map<String, dynamic>> facultySubjects = [];
  List<Map<String, dynamic>> facultyStudents = [];
  List<Map<String, dynamic>> facultyExams = [];

  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  int? selectedSubjectId;
  int? selectedExamId;

  final Map<int, TextEditingController> markControllers = {};

  int? get facultyId => FacultyDashboard.currentFacultyId;

  @override
  void initState() {
    super.initState();
    loadMarksData();
  }

  @override
  void dispose() {
    for (final controller in markControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> loadMarksData() async {
    try {
      final data = await Future.wait([
        ApiService.getStudents(),
        ApiService.getResults(),
        ApiService.getSubjects(),
        ApiService.getExams(),
        ApiService.getClasses(),
        ApiService.getAssignments(),
      ]);

      final studentData = data[0];
      final resultData = data[1];
      final subjectData = data[2];
      final examData = data[3];
      final classData = data[4];
      final assignmentData = data[5];

      if (!mounted) return;

      if (facultyId == null) {
        setState(() {
          students = studentData;
          results = resultData;
          subjects = subjectData;
          exams = examData;
          classes = classData;
          assignments = assignmentData;
          facultyClasses = [];
          facultySubjects = [];
          facultyStudents = [];
          facultyExams = [];
          isLoading = false;
          errorMessage = null;
        });
        return;
      }

      final loadedFacultyClasses = <Map<String, dynamic>>[];

      // Class-teacher relationship.
      for (final item in classData) {
        if (item is! Map) continue;

        final classItem = Map<String, dynamic>.from(item);

        if (getClassTeacherId(classItem) == facultyId) {
          loadedFacultyClasses.add(classItem);
        }
      }

      // Faculty assignment relationship.
      //
      // A faculty member can teach a subject in a class without
      // being the class teacher. Therefore assignments are also
      // used to determine the faculty's classes and subjects.
      for (final item in assignmentData) {
        if (item is! Map) continue;

        final assignment = Map<String, dynamic>.from(item);

        final assignmentFacultyId = getNullableIntValue(
          assignment,
          [
            'faculty_id',
            'teacher_id',
            'assigned_faculty_id',
          ],
        );

        if (assignmentFacultyId != facultyId) {
          continue;
        }

        final assignmentClassId = getNullableIntValue(
          assignment,
          ['class_id'],
        );

        if (assignmentClassId == null) {
          continue;
        }

        for (final classItem in classData) {
          if (classItem is! Map) continue;

          final classMap = Map<String, dynamic>.from(classItem);

          if (getClassId(classMap) == assignmentClassId) {
            final alreadyExists = loadedFacultyClasses.any(
              (existing) =>
                  getClassId(existing) == getClassId(classMap),
            );

            if (!alreadyExists) {
              loadedFacultyClasses.add(classMap);
            }
          }
        }
      }

      final facultyClassIds = loadedFacultyClasses
          .map(getClassId)
          .where((id) => id > 0)
          .toSet();

      final facultyCourseIds = loadedFacultyClasses
          .map(getCourseId)
          .whereType<int>()
          .where((id) => id > 0)
          .toSet();

      final facultyAssignmentSubjectIds = <int>{};

      for (final item in assignmentData) {
        if (item is! Map) continue;

        final assignment = Map<String, dynamic>.from(item);

        final assignmentFacultyId = getNullableIntValue(
          assignment,
          [
            'faculty_id',
            'teacher_id',
            'assigned_faculty_id',
          ],
        );

        if (assignmentFacultyId != facultyId) {
          continue;
        }

        final subjectId = getNullableIntValue(
          assignment,
          ['subject_id'],
        );

        if (subjectId != null && subjectId > 0) {
          facultyAssignmentSubjectIds.add(subjectId);
        }
      }

      final loadedFacultySubjects = <Map<String, dynamic>>[];

      for (final item in subjectData) {
        if (item is! Map) continue;

        final subject = Map<String, dynamic>.from(item);

        final subjectId = getIntValue(
          subject,
          ['subject_id', 'id'],
        );

        final subjectClassId = getSubjectClassId(subject);

        final subjectCourseId = getSubjectCourseId(subject);

        final matchesAssignment =
            facultyAssignmentSubjectIds.contains(subjectId);

        final matchesClass = subjectClassId != null &&
            facultyClassIds.contains(subjectClassId);

        final matchesCourse = subjectCourseId != null &&
            facultyCourseIds.contains(subjectCourseId);

        if (matchesAssignment || matchesClass || matchesCourse) {
          loadedFacultySubjects.add(subject);
        }
      }

      final facultySubjectIds = loadedFacultySubjects
          .map(
            (subject) => getIntValue(
              subject,
              ['subject_id', 'id'],
            ),
          )
          .where((id) => id > 0)
          .toSet();

      final loadedFacultyStudents = <Map<String, dynamic>>[];

      for (final item in studentData) {
        if (item is! Map) continue;

        final student = Map<String, dynamic>.from(item);

        final studentClassId = getStudentClassId(student);

        final studentCourseId = getStudentCourseId(student);

        final matchesClass = studentClassId != null &&
            facultyClassIds.contains(studentClassId);

        final matchesCourse = studentCourseId != null &&
            facultyCourseIds.contains(studentCourseId);

        if (matchesClass || matchesCourse) {
          loadedFacultyStudents.add(student);
        }
      }

      final loadedFacultyExams = <Map<String, dynamic>>[];

      for (final item in examData) {
        if (item is! Map) continue;

        final exam = Map<String, dynamic>.from(item);

        final examId = getExamId(exam);
        final examSubjectId = getExamSubjectId(exam);
        final examClassId = getExamClassId(exam);
        final examCourseId = getExamCourseId(exam);

        if (examId <= 0) {
          continue;
        }

        final matchesSubject = examSubjectId != null &&
            facultySubjectIds.contains(examSubjectId);

        final matchesClass = examClassId != null &&
            facultyClassIds.contains(examClassId);

        final matchesCourse = examCourseId != null &&
            facultyCourseIds.contains(examCourseId);

        if (matchesSubject || matchesClass || matchesCourse) {
          loadedFacultyExams.add(exam);
        }
      }

      if (!mounted) return;

      setState(() {
        students = studentData;
        results = resultData;
        subjects = subjectData;
        exams = examData;
        classes = classData;
        assignments = assignmentData;

        facultyClasses = loadedFacultyClasses;
        facultySubjects = loadedFacultySubjects;
        facultyStudents = loadedFacultyStudents;
        facultyExams = loadedFacultyExams;

        isLoading = false;
        errorMessage = null;

        _initializeSelection();
        _initializeMarkControllers();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load marks data.';
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
        value?.toString().trim() ?? '',
      );

      if (parsed != null) {
        return parsed;
      }
    }

    return 0;
  }

  int? getNullableIntValue(
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

      if (value != null) {
        final parsed = int.tryParse(
          value.toString().trim(),
        );

        if (parsed != null) {
          return parsed;
        }
      }
    }

    return null;
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

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return defaultValue;
  }

  int getClassId(
    Map<String, dynamic> data,
  ) {
    return getIntValue(
      data,
      ['class_id', 'id'],
    );
  }

  int? getClassTeacherId(
    Map<String, dynamic> data,
  ) {
    return getNullableIntValue(
      data,
      [
        'class_teacher_id',
        'faculty_id',
        'teacher_id',
        'assigned_faculty_id',
      ],
    );
  }

  int? getCourseId(
    Map<String, dynamic> data,
  ) {
    return getNullableIntValue(
      data,
      ['course_id'],
    );
  }

  int? getSubjectClassId(
    Map<String, dynamic> data,
  ) {
    return getNullableIntValue(
      data,
      ['class_id'],
    );
  }

  int? getSubjectCourseId(
    Map<String, dynamic> data,
  ) {
    return getNullableIntValue(
      data,
      ['course_id'],
    );
  }

  int getStudentId(
    Map<String, dynamic> student,
  ) {
    return getIntValue(
      student,
      ['student_id', 'id'],
    );
  }

  int? getStudentClassId(
    Map<String, dynamic> student,
  ) {
    return getNullableIntValue(
      student,
      ['class_id', 'classId'],
    );
  }

  int? getStudentCourseId(
    Map<String, dynamic> student,
  ) {
    return getNullableIntValue(
      student,
      ['course_id', 'courseId'],
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
    );
  }

  String getSubjectName(
    Map<String, dynamic> subject,
  ) {
    return getStringValue(
      subject,
      [
        'subject_name',
        'name',
        'subject_code',
      ],
      defaultValue: 'Subject',
    );
  }

  String getSubjectCode(
    Map<String, dynamic> subject,
  ) {
    return getStringValue(
      subject,
      ['subject_code'],
    );
  }

  String getExamName(
    Map<String, dynamic> exam,
  ) {
    return getStringValue(
      exam,
      [
        'exam_name',
        'name',
        'title',
      ],
      defaultValue: 'Exam',
    );
  }

  int getExamId(
    Map<String, dynamic> exam,
  ) {
    return getIntValue(
      exam,
      ['exam_id', 'id'],
    );
  }

  int? getExamSubjectId(
    Map<String, dynamic> exam,
  ) {
    return getNullableIntValue(
      exam,
      ['subject_id'],
    );
  }

  int? getExamClassId(
    Map<String, dynamic> exam,
  ) {
    return getNullableIntValue(
      exam,
      ['class_id'],
    );
  }

  int? getExamCourseId(
    Map<String, dynamic> exam,
  ) {
    return getNullableIntValue(
      exam,
      ['course_id'],
    );
  }

  int getResultId(
    Map<String, dynamic> result,
  ) {
    return getIntValue(
      result,
      ['result_id', 'id'],
    );
  }

  int getResultStudentId(
    Map<String, dynamic> result,
  ) {
    return getIntValue(
      result,
      ['student_id'],
    );
  }

  int getResultSubjectId(
    Map<String, dynamic> result,
  ) {
    return getIntValue(
      result,
      ['subject_id'],
    );
  }

  int getResultExamId(
    Map<String, dynamic> result,
  ) {
    return getIntValue(
      result,
      ['exam_id'],
    );
  }

  Map<String, dynamic>? findResultForStudent(
    int studentId,
  ) {
    if (selectedSubjectId == null || selectedExamId == null) {
      return null;
    }

    for (final item in results) {
      if (item is! Map) continue;

      final result = Map<String, dynamic>.from(item);

      if (getResultStudentId(result) != studentId) {
        continue;
      }

      if (getResultSubjectId(result) != selectedSubjectId) {
        continue;
      }

      if (getResultExamId(result) != selectedExamId) {
        continue;
      }

      return result;
    }

    return null;
  }

  void _initializeSelection() {
    if (facultySubjects.isNotEmpty) {
      final subjectIds = facultySubjects
          .map(
            (subject) => getIntValue(
              subject,
              ['subject_id', 'id'],
            ),
          )
          .where((id) => id > 0)
          .toSet();

      if (selectedSubjectId == null ||
          !subjectIds.contains(selectedSubjectId)) {
        selectedSubjectId = getIntValue(
          facultySubjects.first,
          ['subject_id', 'id'],
        );
      }
    } else {
      selectedSubjectId = null;
    }

    _ensureExamMatchesSubject();
  }

  void _ensureExamMatchesSubject() {
    if (selectedSubjectId == null) {
      selectedExamId = null;
      return;
    }

    final matchingExams = facultyExams.where(
      (exam) {
        final examSubjectId = getExamSubjectId(exam);

        if (examSubjectId == null) {
          return false;
        }

        return examSubjectId == selectedSubjectId;
      },
    ).toList();

    if (matchingExams.isEmpty) {
      selectedExamId = null;
      return;
    }

    final matchingExamIds = matchingExams
        .map(getExamId)
        .where((id) => id > 0)
        .toSet();

    if (selectedExamId == null ||
        !matchingExamIds.contains(selectedExamId)) {
      selectedExamId = getExamId(matchingExams.first);
    }
  }

  void _initializeMarkControllers() {
    for (final student in facultyStudents) {
      final studentId = getStudentId(student);

      if (studentId <= 0) {
        continue;
      }

      final existingResult = findResultForStudent(studentId);

      final marks = existingResult == null
          ? ''
          : getDoubleValue(
                existingResult,
                [
                  'marks_obtained',
                  'marks',
                  'score',
                ],
              )?.toString() ??
              '';

      if (!markControllers.containsKey(studentId)) {
        markControllers[studentId] = TextEditingController(
          text: marks,
        );
      } else {
        markControllers[studentId]!.text = marks;
      }
    }

    final validStudentIds =
        facultyStudents.map(getStudentId).toSet();

    final controllerIds = markControllers.keys.toList();

    for (final studentId in controllerIds) {
      if (!validStudentIds.contains(studentId)) {
        markControllers[studentId]?.dispose();
        markControllers.remove(studentId);
      }
    }
  }

  List<Map<String, dynamic>> getFilteredExams() {
    if (selectedSubjectId == null) {
      return [];
    }

    return facultyExams.where(
      (exam) {
        final subjectId = getExamSubjectId(exam);

        return subjectId == selectedSubjectId;
      },
    ).toList();
  }

  double getTotalMarks() {
    if (selectedExamId == null) {
      return 100;
    }

    for (final exam in facultyExams) {
      if (getExamId(exam) == selectedExamId) {
        final value = getDoubleValue(
          exam,
          [
            'total_marks',
            'max_marks',
            'marks',
          ],
        );

        if (value != null && value > 0) {
          return value;
        }
      }
    }

    return 100;
  }

  String getSelectedSubjectName() {
    if (selectedSubjectId == null) {
      return 'Subject';
    }

    for (final subject in facultySubjects) {
      final id = getIntValue(
        subject,
        ['subject_id', 'id'],
      );

      if (id == selectedSubjectId) {
        return getSubjectName(subject);
      }
    }

    return 'Subject';
  }

  String getSelectedExamName() {
    if (selectedExamId == null) {
      return 'Exam';
    }

    for (final exam in facultyExams) {
      if (getExamId(exam) == selectedExamId) {
        return getExamName(exam);
      }
    }

    return 'Exam';
  }

  String calculateGrade(
    double marks,
    double total,
  ) {
    if (total <= 0) {
      return '';
    }

    final percentage = (marks / total) * 100;

    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C';
    if (percentage >= 40) return 'D';

    return 'F';
  }

  String calculateResultStatus(
    double marks,
    double total,
  ) {
    if (total <= 0) {
      return 'Fail';
    }

    final percentage = (marks / total) * 100;

    return percentage >= 40 ? 'Pass' : 'Fail';
  }

  Color getMarkColor(
    double? marks,
    double total,
  ) {
    if (marks == null) {
      return Colors.grey;
    }

    if (marks >= total * 0.75) {
      return Colors.green;
    }

    if (marks >= total * 0.40) {
      return Colors.orange;
    }

    return Colors.red;
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 55,
            ),
            const SizedBox(height: 14),
            Text(
              errorMessage ?? 'Unable to load marks.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });

                loadMarksData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNoSessionState() {
    return RefreshIndicator(
      onRefresh: loadMarksData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 150),
          Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: 60,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Faculty session not found.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please login again to manage marks.',
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

  Widget buildNoClassState() {
    return RefreshIndicator(
      onRefresh: loadMarksData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 150),
          Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.class_outlined,
                    size: 60,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'No class is assigned.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No class or teaching assignment was found for this faculty.',
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

  Widget buildNoSubjectState() {
    return RefreshIndicator(
      onRefresh: loadMarksData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 100),
          Icon(
            Icons.book_outlined,
            size: 70,
          ),
          SizedBox(height: 18),
          Text(
            'No subjects found.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'No subjects are currently associated with your teaching assignments.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildFilters() {
    final filteredExams = getFilteredExams();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              initialValue: selectedSubjectId,
              decoration: const InputDecoration(
                labelText: 'Select Subject',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.book_outlined,
                ),
              ),
              items: facultySubjects.map(
                (subject) {
                  final id = getIntValue(
                    subject,
                    [
                      'subject_id',
                      'id',
                    ],
                  );

                  final name = getSubjectName(subject);

                  final code = getSubjectCode(subject);

                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(
                      code.isEmpty ? name : '$name ($code)',
                    ),
                  );
                },
              ).toList(),
              onChanged: isSaving
                  ? null
                  : (value) {
                      setState(() {
                        selectedSubjectId = value;

                        selectedExamId = null;

                        _ensureExamMatchesSubject();

                        _initializeMarkControllers();
                      });
                    },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              initialValue: filteredExams.any(
                (exam) =>
                    getExamId(exam) == selectedExamId,
              )
                  ? selectedExamId
                  : null,
              decoration: const InputDecoration(
                labelText: 'Select Exam',
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.assignment_outlined,
                ),
              ),
              items: filteredExams.map(
                (exam) {
                  final id = getExamId(exam);

                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(
                      getExamName(exam),
                    ),
                  );
                },
              ).toList(),
              onChanged: isSaving
                  ? null
                  : (value) {
                      setState(() {
                        selectedExamId = value;

                        _initializeMarkControllers();
                      });
                    },
            ),
            if (filteredExams.isEmpty &&
                selectedSubjectId != null) ...[
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'No exam is available for this subject.',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildStudentCard(
    Map<String, dynamic> student,
  ) {
    final studentId = getStudentId(student);

    if (studentId <= 0) {
      return const SizedBox.shrink();
    }

    final controller = markControllers[studentId];

    if (controller == null) {
      return const SizedBox.shrink();
    }

    final marks = double.tryParse(
      controller.text.trim(),
    );

    final totalMarks = getTotalMarks();

    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const CircleAvatar(
              child: Icon(
                Icons.person_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getStudentName(student),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    getStudentCode(student).isEmpty
                        ? 'Student ID: $studentId'
                        : getStudentCode(student),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 90,
              child: TextFormField(
                controller: controller,
                enabled: !isSaving && selectedExamId != null,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'Marks',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 45,
              child: Text(
                '/ ${totalMarks.toStringAsFixed(0)}',
                style: TextStyle(
                  color: getMarkColor(
                    marks,
                    totalMarks,
                  ),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveMarks() async {
    if (facultyId == null) {
      showMessage(
        'Faculty session not found. Please login again.',
      );
      return;
    }

    if (selectedSubjectId == null) {
      showMessage(
        'Please select a subject.',
      );
      return;
    }

    if (selectedExamId == null) {
      showMessage(
        'Please select an exam.',
      );
      return;
    }

    if (facultyStudents.isEmpty) {
      showMessage(
        'No students found for this faculty.',
      );
      return;
    }

    final totalMarks = getTotalMarks();

    if (totalMarks <= 0) {
      showMessage(
        'Invalid total marks for the selected exam.',
      );
      return;
    }

    for (final student in facultyStudents) {
      final studentId = getStudentId(student);

      final controller = markControllers[studentId];

      if (controller == null) {
        continue;
      }

      final text = controller.text.trim();

      if (text.isEmpty) {
        continue;
      }

      final marks = double.tryParse(text);

      if (marks == null) {
        showMessage(
          'Enter valid marks for ${getStudentName(student)}.',
        );
        return;
      }

      if (marks < 0 || marks > totalMarks) {
        showMessage(
          'Marks for ${getStudentName(student)} must be between 0 and $totalMarks.',
        );
        return;
      }
    }

    setState(() {
      isSaving = true;
    });

    try {
      for (final student in facultyStudents) {
        final studentId = getStudentId(student);

        final controller = markControllers[studentId];

        if (controller == null) {
          continue;
        }

        final text = controller.text.trim();

        if (text.isEmpty) {
          continue;
        }

        final marks = double.parse(text);

        final grade = calculateGrade(
          marks,
          totalMarks,
        );

        final resultStatus = calculateResultStatus(
          marks,
          totalMarks,
        );

        final existingResult = findResultForStudent(
          studentId,
        );

        final payload = <String, dynamic>{
          'exam_id': selectedExamId,
          'student_id': studentId,
          'subject_id': selectedSubjectId,
          'marks_obtained': marks,
          'total_marks': totalMarks,
          'grade': grade,
          'result_status': resultStatus,
          'remarks': null,
        };

        if (existingResult == null) {
          await ApiService.createResult(
            payload,
          );
        } else {
          final resultId = getResultId(
            existingResult,
          );

          if (resultId <= 0) {
            throw Exception(
              'Invalid result ID.',
            );
          }

          await ApiService.updateResult(
            resultId,
            payload,
          );
        }
      }

      if (!mounted) return;

      await loadMarksData();

      if (!mounted) return;

      showMessage(
        'Marks saved successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Unable to save marks. Please check the backend and try again.',
      );
    }

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
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
      return buildNoSessionState();
    }

    if (facultyClasses.isEmpty) {
      return buildNoClassState();
    }

    if (facultySubjects.isEmpty) {
      return buildNoSubjectState();
    }

    if (facultyStudents.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadMarksData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 100),
            Icon(
              Icons.people_outline,
              size: 70,
            ),
            SizedBox(height: 18),
            Text(
              'No students found.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No students are currently associated with your assigned class.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: isSaving ? () async {} : loadMarksData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Marks Management',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter and save marks for students assigned to your teaching classes.',
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          buildClassBanner(),
          const SizedBox(height: 16),
          buildFilters(),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${getSelectedSubjectName()} • '
                      '${getSelectedExamName()} • '
                      'Total Marks: '
                      '${getTotalMarks().toStringAsFixed(0)}',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (selectedExamId == null)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select a subject and exam to enter marks.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ...facultyStudents.map(buildStudentCard),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSaving || selectedExamId == null
                  ? null
                  : saveMarks,
              icon: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.save_outlined,
                    ),
              label: Text(
                isSaving ? 'Saving Marks...' : 'Save Marks',
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildClassBanner() {
    final classNames = facultyClasses
        .map(
          (classItem) => getStringValue(
            classItem,
            [
              'class_name',
              'name',
              'class_code',
            ],
            defaultValue: 'Assigned Class',
          ),
        )
        .where(
          (name) => name.isNotEmpty,
        )
        .toSet()
        .join(', ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(
              Icons.class_outlined,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Assigned Class: $classNames',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
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
          'Marks Management',
        ),
      ),
      body: buildBody(),
    );
  }
}