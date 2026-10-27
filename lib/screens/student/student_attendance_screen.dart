import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StudentAttendanceScreen extends StatefulWidget {
  final int studentId;

  const StudentAttendanceScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState
    extends State<StudentAttendanceScreen> {
  List<dynamic> attendanceData = [];
  List<dynamic> subjectsData = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    try {
      final attendance = await ApiService.getAttendance();
      final subjects = await ApiService.getSubjects();

      if (!mounted) return;

      final filteredAttendance = attendance.where((item) {
        final record = Map<String, dynamic>.from(item as Map);

        final recordStudentId = record['student_id'];

        return recordStudentId?.toString() ==
            widget.studentId.toString();
      }).toList();

      setState(() {
        attendanceData = filteredAttendance;
        subjectsData = subjects;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load attendance.';
      });
    }
  }

  String getSubjectName(dynamic subjectId) {
    for (final item in subjectsData) {
      final subject = Map<String, dynamic>.from(item as Map);

      final id = subject['subject_id'] ?? subject['id'];

      if (id?.toString() == subjectId?.toString()) {
        return (subject['name'] ??
                subject['subject_name'] ??
                subject['title'] ??
                'Subject $subjectId')
            .toString();
      }
    }

    return 'Subject $subjectId';
  }

  bool isPresent(dynamic status) {
    return status
            ?.toString()
            .trim()
            .toLowerCase() ==
        'present';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Attendance'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Attendance'),
        ),
        body: Center(
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
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: loadAttendance,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final presentCount = attendanceData
        .where((item) => isPresent(item['status']))
        .length;

    final absentCount = attendanceData
        .where((item) => !isPresent(item['status']))
        .length;

    final totalCount = attendanceData.length;

    final attendancePercentage = totalCount == 0
        ? 0
        : ((presentCount / totalCount) * 100).round();

    final Map<String, List<dynamic>> groupedAttendance = {};

    for (final item in attendanceData) {
      final subjectId = item['subject_id']?.toString() ?? 'unknown';

      groupedAttendance.putIfAbsent(
        subjectId,
        () => [],
      );

      groupedAttendance[subjectId]!.add(item);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      body: RefreshIndicator(
        onRefresh: loadAttendance,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Overall Attendance',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: totalCount == 0
                                  ? 0
                                  : presentCount / totalCount,
                              strokeWidth: 12,
                            ),
                            Text(
                              '$attendancePercentage%',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                        children: [
                          _Stat(
                            'Present',
                            presentCount.toString(),
                          ),
                          _Stat(
                            'Absent',
                            absentCount.toString(),
                          ),
                          _Stat(
                            'Total',
                            totalCount.toString(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Subject-wise Attendance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),

                      if (groupedAttendance.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 20,
                          ),
                          child: Center(
                            child: Text(
                              'No attendance records found.',
                            ),
                          ),
                        ),

                      ...groupedAttendance.entries.map(
                        (entry) {
                          final records = entry.value;

                          final present = records
                              .where(
                                (item) =>
                                    isPresent(item['status']),
                              )
                              .length;

                          final total = records.length;

                          final percentage = total == 0
                              ? 0
                              : ((present / total) * 100)
                                  .round();

                          final subjectName =
                              getSubjectName(entry.key);

                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 16,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        subjectName,
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '$percentage%',
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                LinearProgressIndicator(
                                  value: total == 0
                                      ? 0
                                      : present / total,
                                  minHeight: 8,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String title;
  final String value;

  const _Stat(
    this.title,
    this.value,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(title),
      ],
    );
  }
}