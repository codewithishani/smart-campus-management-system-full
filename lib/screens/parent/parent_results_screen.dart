import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ParentResultsScreen extends StatefulWidget {
  final int parentId;

  const ParentResultsScreen({
    super.key,
    required this.parentId,
  });

  @override
  State<ParentResultsScreen> createState() =>
      _ParentResultsScreenState();
}

class _ParentResultsScreenState
    extends State<ParentResultsScreen> {
  List<dynamic> results = [];
  List<dynamic> subjects = [];
  List<dynamic> students = [];
  List<dynamic> linkedStudents = [];

  int selectedStudentId = 0;
  int semester = 0;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadResults();
  }

  Future<void> loadResults() async {
    try {
      final data = await Future.wait([
        ApiService.getParentStudentLinks(),
        ApiService.getStudents(),
        ApiService.getResults(),
        ApiService.getSubjects(),
      ]);

      final linkData = data[0];
      final studentData = data[1];
      final resultData = data[2];
      final subjectData = data[3];

      final studentIds = <int>[];

      for (final item in linkData) {
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
        linkedStudents = resolvedStudents;
        results = resultData;
        subjects = subjectData;

        selectedStudentId = initialStudentId;

        isLoading = false;
        errorMessage = null;
      });

      updateSelectedStudent(initialStudentId);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load results.';
      });
    }
  }

  void updateSelectedStudent(int studentId) {
    int studentSemester = 0;

    for (final item in students) {
      if (item is! Map) continue;

      final student = Map<String, dynamic>.from(item);

      final currentStudentId = getIntValue(
        student,
        ['student_id', 'id'],
      );

      if (currentStudentId == studentId) {
        studentSemester = getIntValue(
          student,
          ['semester', 'current_semester'],
        );
        break;
      }
    }

    if (!mounted) return;

    setState(() {
      selectedStudentId = studentId;
      semester = studentSemester;
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

  String getSubjectName(int subjectId) {
    for (final item in subjects) {
      if (item is! Map) continue;

      final subject = Map<String, dynamic>.from(item);

      final id = getIntValue(
        subject,
        ['subject_id', 'id'],
      );

      if (id == subjectId) {
        return getStringValue(
          subject,
          [
            'subject_name',
            'name',
            'title',
          ],
          defaultValue: 'Subject',
        );
      }
    }

    return 'Subject';
  }

  String getSubjectCode(int subjectId) {
    for (final item in subjects) {
      if (item is! Map) continue;

      final subject = Map<String, dynamic>.from(item);

      final id = getIntValue(
        subject,
        ['subject_id', 'id'],
      );

      if (id == subjectId) {
        return getStringValue(
          subject,
          [
            'subject_code',
            'code',
          ],
        );
      }
    }

    return '';
  }

  List<Map<String, dynamic>> getStudentResults() {
    final result = <Map<String, dynamic>>[];

    for (final item in results) {
      if (item is! Map) continue;

      final resultData = Map<String, dynamic>.from(item);

      final resultStudentId = getIntValue(
        resultData,
        ['student_id'],
      );

      if (resultStudentId == selectedStudentId) {
        result.add(resultData);
      }
    }

    return result;
  }

  double calculatePercentage(
    List<Map<String, dynamic>> studentResults,
  ) {
    double obtained = 0;
    double total = 0;

    for (final result in studentResults) {
      obtained += getDoubleValue(
        result,
        [
          'marks_obtained',
          'marks',
          'obtained_marks',
        ],
      );

      total += getDoubleValue(
        result,
        [
          'total_marks',
          'max_marks',
        ],
      );
    }

    if (total == 0) {
      return 0;
    }

    return (obtained / total) * 100;
  }

  int countPassed(
    List<Map<String, dynamic>> studentResults,
  ) {
    int passed = 0;

    for (final result in studentResults) {
      final status = getStringValue(
        result,
        [
          'result_status',
          'status',
        ],
      ).toLowerCase();

      if (status == 'pass' || status == 'passed') {
        passed++;
      }
    }

    return passed;
  }

  Color getStatusColor(String status) {
    final value = status.toLowerCase();

    if (value == 'pass' || value == 'passed') {
      return Colors.green;
    }

    if (value == 'fail' || value == 'failed') {
      return Colors.red;
    }

    return Colors.orange;
  }

  Widget buildSummaryCard(
    List<Map<String, dynamic>> studentResults,
  ) {
    final percentage = calculatePercentage(
      studentResults,
    );

    final passed = countPassed(
      studentResults,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              getStudentName(selectedStudentId),
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Overall Performance',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              semester > 0
                  ? 'Semester $semester'
                  : 'Current Semester',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$passed of ${studentResults.length} subjects passed',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildResultCard(
    Map<String, dynamic> result,
  ) {
    final subjectId = getIntValue(
      result,
      ['subject_id'],
    );

    final subjectName = getSubjectName(
      subjectId,
    );

    final subjectCode = getSubjectCode(
      subjectId,
    );

    final marks = getDoubleValue(
      result,
      [
        'marks_obtained',
        'marks',
        'obtained_marks',
      ],
    );

    final total = getDoubleValue(
      result,
      [
        'total_marks',
        'max_marks',
      ],
    );

    final grade = getStringValue(
      result,
      ['grade'],
      defaultValue: '-',
    );

    final status = getStringValue(
      result,
      [
        'result_status',
        'status',
      ],
      defaultValue: '-',
    );

    final remarks = getStringValue(
      result,
      ['remarks'],
    );

    final statusColor = getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            grade.isNotEmpty ? grade[0] : 'R',
          ),
        ),
        title: Text(
          subjectName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (subjectCode.isNotEmpty)
              Text(subjectCode),
            Text(
              'Marks: ${marks.toStringAsFixed(0)} / ${total.toStringAsFixed(0)}',
            ),
            if (remarks.isNotEmpty)
              Text('Remarks: $remarks'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              grade,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 55,
            ),
            const SizedBox(height: 14),
            Text(
              errorMessage ?? 'Unable to load results.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });

                loadResults();
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
        onRefresh: loadResults,
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

    final studentResults = getStudentResults();

    return RefreshIndicator(
      onRefresh: loadResults,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          buildStudentSelector(),

          if (studentResults.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.assessment_outlined,
                      size: 65,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'No results found.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Results for ${getStudentName(selectedStudentId)} '
                      'will appear here when they are available.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            buildSummaryCard(studentResults),
            const SizedBox(height: 20),
            const Text(
              'Subject Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...studentResults.map(buildResultCard),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results & Marks'),
      ),
      body: buildBody(),
    );
  }
}