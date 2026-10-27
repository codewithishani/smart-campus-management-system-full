
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ParentAttendanceScreen extends StatefulWidget {
  final int parentId;

  const ParentAttendanceScreen({
    super.key,
    required this.parentId,
  });

  @override
  State<ParentAttendanceScreen> createState() =>
      _ParentAttendanceScreenState();
}

class _ParentAttendanceScreenState
    extends State<ParentAttendanceScreen> {
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _attendance = [];
  List<Map<String, dynamic>> _subjects = [];

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getParentStudentLinks(),
        ApiService.getStudents(),
        ApiService.getAttendance(),
        ApiService.getSubjects(),
      ]);

      final parentStudentResponse = results[0];
      final studentsResponse = results[1];
      final attendanceResponse = results[2];
      final subjectsResponse = results[3];

      final parentStudentLinks =
          _mapList(parentStudentResponse);

      final students =
          _mapList(studentsResponse);

      final attendance =
          _mapList(attendanceResponse);

      final subjects =
          _mapList(subjectsResponse);

      final linkedStudentIds = <int>{};

      for (final link in parentStudentLinks) {
        final parentId = _toInt(link['parent_id']);
        final studentId = _toInt(link['student_id']);

        if (parentId == widget.parentId &&
            studentId != null &&
            studentId > 0) {
          linkedStudentIds.add(studentId);
        }
      }

      final linkedStudents = students.where((student) {
        final studentId =
            _toInt(student['student_id']);

        return studentId != null &&
            linkedStudentIds.contains(studentId);
      }).toList();

      final linkedAttendance =
          attendance.where((record) {
        final studentId =
            _toInt(record['student_id']);

        return studentId != null &&
            linkedStudentIds.contains(studentId);
      }).toList();

      if (!mounted) return;

      setState(() {
        _students = linkedStudents;
        _attendance = linkedAttendance;
        _subjects = subjects;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Unable to load attendance.';
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  String _studentName(
    Map<String, dynamic> student,
  ) {
    final name = student['name'];

    if (name != null &&
        name.toString().trim().isNotEmpty) {
      return name.toString();
    }

    return 'Student';
  }

  String _studentRollNo(
    Map<String, dynamic> student,
  ) {
    final rollNo = student['roll_no'];

    if (rollNo != null &&
        rollNo.toString().trim().isNotEmpty) {
      return rollNo.toString();
    }

    return '';
  }

  String _subjectName(dynamic subjectId) {
    final id = _toInt(subjectId);

    if (id == null) {
      return 'Subject';
    }

    for (final subject in _subjects) {
      final currentId =
          _toInt(subject['subject_id']);

      if (currentId == id) {
        final name = subject['subject_name'] ??
            subject['name'];

        if (name != null &&
            name.toString().trim().isNotEmpty) {
          return name.toString();
        }
      }
    }

    return 'Subject $id';
  }

  bool _isPresent(
    Map<String, dynamic> record,
  ) {
    final status =
        record['status']?.toString().toLowerCase().trim();

    return status == 'present';
  }

  Widget _buildStudentAttendance(
    Map<String, dynamic> student,
  ) {
    final studentId =
        _toInt(student['student_id']);

    if (studentId == null) {
      return const SizedBox.shrink();
    }

    final records = _attendance.where((record) {
      return _toInt(record['student_id']) ==
          studentId;
    }).toList();

    final total = records.length;

    final present =
        records.where(_isPresent).length;

    final absent = total - present;

    final percentage = total == 0
        ? 0.0
        : (present / total) * 100;

    final bySubject =
        <int, List<Map<String, dynamic>>>{};

    for (final record in records) {
      final subjectId =
          _toInt(record['subject_id']);

      if (subjectId == null) {
        continue;
      }

      bySubject
          .putIfAbsent(subjectId, () => [])
          .add(record);
    }

    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(
                    Icons.person_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        _studentName(student),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      if (_studentRollNo(student)
                          .isNotEmpty)
                        Text(
                          'Roll No: ${_studentRollNo(student)}',
                          style: TextStyle(
                            color:
                                Colors.grey.shade700,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    icon: Icons
                        .event_available_outlined,
                    title: 'Present',
                    value: '$present',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _summaryCard(
                    icon: Icons
                        .event_busy_outlined,
                    title: 'Absent',
                    value: '$absent',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _summaryCard(
                    icon: Icons
                        .percent_outlined,
                    title: 'Attendance',
                    value:
                        '${percentage.toStringAsFixed(1)}%',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Text(
              'Subject-wise Attendance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            if (bySubject.isEmpty)
              const Padding(
                padding:
                    EdgeInsets.symmetric(
                  vertical: 12,
                ),
                child: Text(
                  'No attendance records available.',
                ),
              )
            else
              ...bySubject.entries.map(
                (entry) {
                  final subjectRecords =
                      entry.value;

                  final subjectTotal =
                      subjectRecords.length;

                  final subjectPresent =
                      subjectRecords
                          .where(_isPresent)
                          .length;

                  final subjectPercentage =
                      subjectTotal == 0
                          ? 0.0
                          : (subjectPresent /
                                  subjectTotal) *
                              100;

                  return ListTile(
                    contentPadding:
                        EdgeInsets.zero,
                    leading:
                        const CircleAvatar(
                      child: Icon(
                        Icons
                            .menu_book_outlined,
                      ),
                    ),
                    title: Text(
                      _subjectName(
                        entry.key,
                      ),
                    ),
                    subtitle: Text(
                      '$subjectPresent / $subjectTotal classes attended',
                    ),
                    trailing: Text(
                      '${subjectPercentage.toStringAsFixed(1)}%',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              _error ??
                  'Unable to load attendance.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadAttendance,
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance Monitoring',
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed:
                _loading ? null : _loadAttendance,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : _error != null
              ? _buildError()
              : _students.isEmpty
                  ? RefreshIndicator(
                      onRefresh: _loadAttendance,
                      child: ListView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 150),
                          Icon(
                            Icons
                                .person_off_outlined,
                            size: 60,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No students are linked to this parent account.',
                            textAlign:
                                TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh:
                          _loadAttendance,
                      child: ListView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        padding:
                            const EdgeInsets.fromLTRB(
                          16,
                          18,
                          16,
                          28,
                        ),
                        children: [
                          Text(
                            'Attendance Overview',
                            style: Theme.of(
                                    context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          const Text(
                            'Attendance records for your linked student(s).',
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          ..._students.map(
                            (student) =>
                                _buildStudentAttendance(
                              student,
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}

