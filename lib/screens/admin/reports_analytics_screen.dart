import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ReportsAnalyticsScreen extends StatefulWidget {
  const ReportsAnalyticsScreen({super.key});

  @override
  State<ReportsAnalyticsScreen> createState() =>
      _ReportsAnalyticsScreenState();
}

class _ReportsAnalyticsScreenState extends State<ReportsAnalyticsScreen> {
  bool _isLoading = true;
  String? _error;

  List<dynamic> students = [];
  List<dynamic> attendance = [];
  List<dynamic> results = [];
  List<dynamic> assignments = [];
  List<dynamic> submissions = [];
  List<dynamic> users = [];
  List<dynamic> complaints = [];
  List<dynamic> events = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final responses = await Future.wait<dynamic>([
      _safeLoad(ApiService.getStudents),
      _safeLoad(ApiService.getAttendance),
      _safeLoad(ApiService.getResults),
      _safeLoad(ApiService.getAssignments),
      _safeLoad(ApiService.getSubmissions),
      _safeLoad(ApiService.getUsers),
      _safeLoad(ApiService.getComplaints),
      _safeLoad(ApiService.getEvents),
    ]);

    if (!mounted) return;

    final errors = responses.whereType<_LoadFailure>().toList();

    setState(() {
      students = _toList(responses[0]);
      attendance = _toList(responses[1]);
      results = _toList(responses[2]);
      assignments = _toList(responses[3]);
      submissions = _toList(responses[4]);
      users = _toList(responses[5]);
      complaints = _toList(responses[6]);
      events = _toList(responses[7]);

      _error = errors.isEmpty
          ? null
          : 'Some reports could not load:\n${errors.map((e) => e.message).join('\n')}';

      _isLoading = false;
    });
  }

  Future<dynamic> _safeLoad(
    Future<dynamic> Function() loader,
  ) async {
    try {
      return await loader();
    } catch (e) {
      return _LoadFailure(e.toString());
    }
  }

  List<dynamic> _toList(dynamic value) {
    if (value is List) return value;

    if (value is Map) {
      if (value['data'] is List) return value['data'] as List;
      if (value['items'] is List) return value['items'] as List;
      if (value['results'] is List) return value['results'] as List;
    }

    return [];
  }

  double _number(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _text(dynamic value) {
    return value?.toString() ?? '';
  }

  String _firstValue(
    Map<String, dynamic> item,
    List<String> keys, {
    String fallback = 'N/A',
  }) {
    for (final key in keys) {
      final value = item[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }

  double get attendancePercentage {
    final records = attendance.whereType<Map>().toList();

    if (records.isEmpty) return 0;

    final present = records.where((raw) {
      final item = Map<String, dynamic>.from(raw);

      final status = _text(
        item['status'] ?? item['attendance_status'],
      ).toLowerCase();

      return status == 'present';
    }).length;

    return present * 100 / records.length;
  }

  double get academicAverage {
    final values = <double>[];

    for (final raw in results) {
      if (raw is! Map) continue;

      final item = Map<String, dynamic>.from(raw);

      final value = item['marks'] ??
          item['score'] ??
          item['percentage'] ??
          item['obtained_marks'];

      if (value != null) {
        values.add(_number(value));
      }
    }

    if (values.isEmpty) return 0;

    return values.reduce((a, b) => a + b) / values.length;
  }

  double get submissionPercentage {
    if (assignments.isEmpty) return 0;

    return (submissions.length * 100 / assignments.length)
        .clamp(0, 100)
        .toDouble();
  }

  double get complaintResolutionPercentage {
    final records = complaints.whereType<Map>().toList();

    if (records.isEmpty) return 0;

    final resolved = records.where((raw) {
      final item = Map<String, dynamic>.from(raw);

      final status = _text(item['status']).toLowerCase();

      return status == 'resolved' ||
          status == 'closed' ||
          status == 'completed';
    }).length;

    return resolved * 100 / records.length;
  }

  Widget _report(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.5),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(value),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showDetails(
    String title,
    List<dynamic> records,
    List<String> preferredKeys,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.75,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: records.isEmpty
                      ? const Center(
                          child: Text('No records available'),
                        )
                      : ListView.builder(
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            final raw = records[index];

                            if (raw is! Map) {
                              return ListTile(
                                title: Text(raw.toString()),
                              );
                            }

                            final item =
                                Map<String, dynamic>.from(raw);

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              child: ExpansionTile(
                                leading: const Icon(
                                  Icons.description,
                                ),
                                title: Text(
                                  _firstValue(item, [
                                    'name',
                                    'student_name',
                                    'title',
                                    'subject_name',
                                    'subject',
                                    'username',
                                    'email',
                                    'id',
                                  ]),
                                ),
                                subtitle: Text(
                                  'ID: ${_firstValue(item, preferredKeys)}',
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: item.entries.map((entry) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          child: Text(
                                            '${entry.key}: ${entry.value ?? "N/A"}',
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null ||
            int.tryParse(value.trim()) == null) {
          return 'Enter a valid $label';
        }

        return null;
      },
    );
  }

  void _disposeControllers(
    List<TextEditingController> controllers,
  ) {
    for (final controller in controllers) {
      controller.dispose();
    }
  }

  Future<void> _editAttendance(
    Map<String, dynamic> item,
  ) async {
    final id = int.tryParse(
      _firstValue(
        item,
        ['id', 'attendance_id'],
        fallback: '',
      ),
    );

    if (id == null) {
      _message('Attendance ID not found.');
      return;
    }

    final student = TextEditingController(
      text: _firstValue(item, ['student_id'], fallback: ''),
    );

    final subject = TextEditingController(
      text: _firstValue(item, ['subject_id'], fallback: ''),
    );

    final faculty = TextEditingController(
      text: _firstValue(item, ['faculty_id'], fallback: ''),
    );

    final remarks = TextEditingController(
      text: _text(item['remarks']),
    );

    final date = TextEditingController(
      text: _firstValue(
        item,
        ['attendance_date', 'date'],
        fallback: DateTime.now().toIso8601String().split('T').first,
      ),
    );

    String status =
        _text(item['status'] ?? item['attendance_status']).toLowerCase();

    if (!['present', 'absent', 'late'].contains(status)) {
      status = 'present';
    }

    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Attendance'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _numberField(student, 'Student ID'),
                      _numberField(subject, 'Subject ID'),
                      _numberField(faculty, 'Faculty ID'),
                      TextFormField(
                        controller: date,
                        decoration: const InputDecoration(
                          labelText: 'Attendance Date (YYYY-MM-DD)',
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          final parsed = DateTime.tryParse(text);

                          if (parsed == null ||
                              parsed.toIso8601String().split('T').first !=
                                  text) {
                            return 'Use YYYY-MM-DD';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                         initialValue: status,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'present',
                            child: Text('Present'),
                          ),
                          DropdownMenuItem(
                            value: 'absent',
                            child: Text('Absent'),
                          ),
                          DropdownMenuItem(
                            value: 'late',
                            child: Text('Late'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => status = value);
                          }
                        },
                      ),
                      TextFormField(
                        controller: remarks,
                        decoration: const InputDecoration(
                          labelText: 'Remarks',
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) {
      _disposeControllers([
        student,
        subject,
        faculty,
        remarks,
        date,
      ]);
      return;
    }

    try {
      await ApiService.updateAttendance(
        attendanceId: id,
        studentId: int.parse(student.text.trim()),
        subjectId: int.parse(subject.text.trim()),
        facultyId: int.parse(faculty.text.trim()),
        attendanceDate: date.text.trim(),
        status: status,
        remarks: remarks.text.trim(),
      );

      if (!mounted) return;

      _message('Attendance updated successfully!');
      await _loadReports();
    } catch (e) {
      _message('Could not update attendance: $e');
    } finally {
      _disposeControllers([
        student,
        subject,
        faculty,
        remarks,
        date,
      ]);
    }
  }

  Future<void> _editResult(
    Map<String, dynamic> item,
  ) async {
    final id = int.tryParse(
      _firstValue(
        item,
        ['id', 'result_id'],
        fallback: '',
      ),
    );

    if (id == null) {
      _message('Result ID not found.');
      return;
    }

    final controllers = <String, TextEditingController>{};

    for (final entry in item.entries) {
      if (entry.value == null ||
          entry.value is Map ||
          entry.value is List) {
        continue;
      }

      controllers[entry.key] = TextEditingController(
        text: entry.value.toString(),
      );
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Academic Result'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: controllers.entries.map((entry) {
                  final readOnly = [
                    'id',
                    'result_id',
                    'created_at',
                  ].contains(entry.key);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TextField(
                      controller: entry.value,
                      readOnly: readOnly,
                      decoration: InputDecoration(
                        labelText: entry.key,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      for (final controller in controllers.values) {
        controller.dispose();
      }
      return;
    }

    try {
      final updated = <String, dynamic>{};

      for (final entry in controllers.entries) {
        final key = entry.key;

        if (['id', 'result_id', 'created_at'].contains(key)) {
          continue;
        }

        final value = entry.value.text.trim();
        final original = item[key];

        if (original is int) {
          final parsed = int.tryParse(value);

          if (parsed == null) {
            _message('Enter a valid number for $key.');
            return;
          }

          updated[key] = parsed;
        } else if (original is double) {
          final parsed = double.tryParse(value);

          if (parsed == null) {
            _message('Enter a valid number for $key.');
            return;
          }

          updated[key] = parsed;
        } else {
          updated[key] = value;
        }
      }

      await ApiService.updateResult(id, updated);

      if (!mounted) return;

      _message('Academic result updated successfully!');
      await _loadReports();
    } catch (e) {
      _message('Could not update result: $e');
    } finally {
      for (final controller in controllers.values) {
        controller.dispose();
      }
    }
  }

  void _openAttendance() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.8,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Student Attendance',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Attendance: ${attendancePercentage.toStringAsFixed(1)}%',
                  ),
                ),
                const Divider(),
                Expanded(
                  child: attendance.isEmpty
                      ? const Center(
                          child: Text('No attendance records'),
                        )
                      : ListView.builder(
                          itemCount: attendance.length,
                          itemBuilder: (context, index) {
                            final raw = attendance[index];

                            if (raw is! Map) {
                              return ListTile(title: Text('$raw'));
                            }

                            final item =
                                Map<String, dynamic>.from(raw);

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                                title: Text(
                                  'Student: ${_firstValue(item, ['student_name', 'student_id'])}',
                                ),
                                subtitle: Text(
                                  'Date: ${_firstValue(item, ['attendance_date', 'date'])}\n'
                                  'Status: ${_firstValue(item, ['status', 'attendance_status'])}\n'
                                  'Subject: ${_firstValue(item, ['subject_name', 'subject_id'])}',
                                ),
                                isThreeLine: true,
                                trailing: IconButton(
                                  tooltip: 'Edit attendance',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editAttendance(item),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openResults() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.8,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Academic Performance',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Average: ${academicAverage.toStringAsFixed(1)}',
                  ),
                ),
                const Divider(),
                Expanded(
                  child: results.isEmpty
                      ? const Center(
                          child: Text('No academic results'),
                        )
                      : ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final raw = results[index];

                            if (raw is! Map) {
                              return ListTile(title: Text('$raw'));
                            }

                            final item =
                                Map<String, dynamic>.from(raw);

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.school),
                                ),
                                title: Text(
                                  _firstValue(item, [
                                    'student_name',
                                    'student_id',
                                    'name',
                                    'id',
                                  ]),
                                ),
                                subtitle: Text(
                                  'Subject: ${_firstValue(item, ['subject_name', 'subject_id', 'subject'])}\n'
                                  'Marks: ${_firstValue(item, ['marks', 'score', 'obtained_marks', 'percentage'])}',
                                ),
                                isThreeLine: true,
                                trailing: IconButton(
                                  tooltip: 'Edit result',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editResult(item),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _message(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            tooltip: 'Refresh reports',
            onPressed: _loadReports,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReports,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_error != null)
                    Card(
                      color: Colors.amber.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.deepOrange,
                          ),
                        ),
                      ),
                    ),
                  _sectionTitle('Overview'),
                  _report(
                    'Total Students',
                    '${students.length} students',
                    Icons.people,
                    Colors.blue,
                    () => _showDetails(
                      'Students',
                      students,
                      ['id', 'student_id'],
                    ),
                  ),
                  _report(
                    'Student Attendance',
                    '${attendancePercentage.toStringAsFixed(1)}% attendance',
                    Icons.fact_check,
                    Colors.green,
                    _openAttendance,
                  ),
                  _report(
                    'Academic Performance',
                    '${academicAverage.toStringAsFixed(1)} average marks',
                    Icons.school,
                    Colors.orange,
                    _openResults,
                  ),
                  _report(
                    'Assignment Submissions',
                    '${submissionPercentage.toStringAsFixed(1)}% submission rate',
                    Icons.assignment_turned_in,
                    Colors.purple,
                    () => _showDetails(
                      'Assignment Submissions',
                      submissions,
                      ['id', 'submission_id'],
                    ),
                  ),
                  _report(
                    'Users',
                    '${users.length} users',
                    Icons.group,
                    Colors.teal,
                    () => _showDetails(
                      'Users',
                      users,
                      ['id', 'user_id'],
                    ),
                  ),
                  _report(
                    'Complaints',
                    '${complaints.length} total complaints',
                    Icons.report_problem,
                    Colors.red,
                    () => _showDetails(
                      'Complaints',
                      complaints,
                      ['id', 'complaint_id'],
                    ),
                  ),
                  _report(
                    'Complaint Resolution',
                    '${complaintResolutionPercentage.toStringAsFixed(1)}% resolved',
                    Icons.task_alt,
                    Colors.green,
                    () => _showDetails(
                      'Complaint Resolution',
                      complaints,
                      ['id', 'complaint_id'],
                    ),
                  ),
                  _report(
                    'Campus Events',
                    '${events.length} events',
                    Icons.event,
                    Colors.indigo,
                    () => _showDetails(
                      'Campus Events',
                      events,
                      ['id', 'event_id'],
                    ),
                  ),
                  _report(
                    'Assignments',
                    '${assignments.length} assignments',
                    Icons.assignment,
                    Colors.deepOrange,
                    () => _showDetails(
                      'Assignments',
                      assignments,
                      ['id', 'assignment_id'],
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _loadReports,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh All Reports'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _LoadFailure {
  const _LoadFailure(this.message);

  final String message;
}