import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class StudentResultsScreen extends StatefulWidget {
  final int studentId;

  const StudentResultsScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentResultsScreen> createState() =>
      _StudentResultsScreenState();
}

class _StudentResultsScreenState
    extends State<StudentResultsScreen> {
  List<dynamic> results = [];
  List<dynamic> subjects = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadResults();
  }

  Future<void> loadResults() async {
    try {
      final resultData = await ApiService.getResults();
      final subjectData = await ApiService.getSubjects();

      if (!mounted) return;

      final studentResults = resultData.where((item) {
        if (item is! Map) {
          return false;
        }

        final result =
            Map<String, dynamic>.from(item);

        final resultStudentId =
            result['student_id'] ??
                result['studentId'];

        return resultStudentId?.toString() ==
            widget.studentId.toString();
      }).toList();

      setState(() {
        results = studentResults;
        subjects = subjectData;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load results.';
      });
    }
  }

  int? getSubjectId(
    Map<String, dynamic> result,
  ) {
    final value =
        result['subject_id'] ??
            result['subjectId'];

    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
  }

  String getSubjectName(
    Map<String, dynamic> result,
  ) {
    final subjectId =
        getSubjectId(result);

    for (final item in subjects) {
      if (item is! Map) {
        continue;
      }

      final subject =
          Map<String, dynamic>.from(item);

      final currentSubjectId =
          subject['subject_id'] ??
              subject['id'] ??
              subject['subjectId'];

      if (currentSubjectId?.toString() ==
          subjectId?.toString()) {
        return (subject['subject_name'] ??
                subject['name'] ??
                subject['title'] ??
                'Unknown Subject')
            .toString();
      }
    }

    return 'Subject ID: ${subjectId ?? '-'}';
  }

  double getMarks(
    Map<String, dynamic> result,
  ) {
    final value =
        result['marks_obtained'] ??
            result['marksObtained'] ??
            result['marks'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  double getTotalMarks(
    Map<String, dynamic> result,
  ) {
    final value =
        result['total_marks'] ??
            result['totalMarks'] ??
            result['max_marks'] ??
            result['maximum_marks'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String getGrade(
    Map<String, dynamic> result,
  ) {
    return (
      result['grade'] ??
          result['grade_name'] ??
          'N/A'
    ).toString();
  }

  String getResultStatus(
    Map<String, dynamic> result,
  ) {
    return (
      result['result_status'] ??
          result['status'] ??
          'N/A'
    ).toString();
  }

  String getRemarks(
    Map<String, dynamic> result,
  ) {
    return (
      result['remarks'] ??
          result['remark'] ??
          ''
    ).toString();
  }

  double calculatePercentage() {
    double obtained = 0;
    double total = 0;

    for (final item in results) {
      if (item is! Map) {
        continue;
      }

      final result =
          Map<String, dynamic>.from(item);

      obtained += getMarks(result);
      total += getTotalMarks(result);
    }

    if (total == 0) {
      return 0;
    }

    return (obtained / total) * 100;
  }

  int countPassedResults() {
    return results.where((item) {
      if (item is! Map) {
        return false;
      }

      final result =
          Map<String, dynamic>.from(item);

      final status =
          getResultStatus(result)
              .trim()
              .toLowerCase();

      return status == 'pass' ||
          status == 'passed';
    }).length;
  }

  Color getStatusColor(
    String status,
  ) {
    final value =
        status.trim().toLowerCase();

    if (value == 'pass' ||
        value == 'passed') {
      return Colors.green;
    }

    if (value == 'fail' ||
        value == 'failed') {
      return Colors.red;
    }

    return Colors.grey;
  }

  Widget buildSummaryCard() {
    final percentage =
        calculatePercentage();

    final passed =
        countPassedResults();

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Academic Performance',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 32,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const Text(
              'Overall Percentage',
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
              children: [
                buildSummaryItem(
                  'Subjects',
                  results.length.toString(),
                  Icons.menu_book,
                ),
                buildSummaryItem(
                  'Passed',
                  passed.toString(),
                  Icons.check_circle,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'CGPA is not calculated here because the current '
              'database stores marks and grades but does not '
              'store a CGPA value.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
              ),
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
            fontWeight:
                FontWeight.bold,
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

  Widget buildResultCard(
    Map<String, dynamic> result,
  ) {
    final subjectName =
        getSubjectName(result);

    final marks =
        getMarks(result);

    final totalMarks =
        getTotalMarks(result);

    final grade =
        getGrade(result);

    final status =
        getResultStatus(result);

    final remarks =
        getRemarks(result);

    final statusColor =
        getStatusColor(status);

    final formattedMarks =
        marks % 1 == 0
            ? marks.toStringAsFixed(0)
            : marks.toStringAsFixed(1);

    final formattedTotalMarks =
        totalMarks % 1 == 0
            ? totalMarks.toStringAsFixed(0)
            : totalMarks.toStringAsFixed(1);

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.all(14),
        leading: const CircleAvatar(
          child: Icon(Icons.book),
        ),
        title: Text(
          subjectName,
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding:
              const EdgeInsets.only(
            top: 6,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Grade: $grade',
              ),
              const SizedBox(height: 3),
              Text(
                'Status: $status',
                style: TextStyle(
                  color: statusColor,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
              if (remarks.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  'Remarks: $remarks',
                ),
              ],
            ],
          ),
        ),
        trailing: Text(
          '$formattedMarks / $formattedTotalMarks',
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
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

                  loadResults();
                },
                child:
                    const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (results.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadResults,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.assessment_outlined,
                    size: 60,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No results available.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Your marks and grades will appear here.',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadResults,
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            buildSummaryCard(),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  const ListTile(
                    title: Text(
                      'Subject-wise Marks',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                  ...results.map((item) {
                    if (item is! Map) {
                      return const SizedBox.shrink();
                    }

                    final result =
                        Map<String, dynamic>.from(item);

                    return buildResultCard(
                      result,
                    );
                  }),
                ],
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
        title:
            const Text('Results & Marks'),
      ),
      body: buildBody(),
    );
  }
}