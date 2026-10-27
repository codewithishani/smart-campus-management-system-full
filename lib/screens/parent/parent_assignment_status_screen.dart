
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ParentAssignmentStatusScreen extends StatefulWidget {
  final int parentId;

  const ParentAssignmentStatusScreen(
    this.parentId, {
    super.key,
  });

  @override
  State<ParentAssignmentStatusScreen> createState() =>
      _ParentAssignmentStatusScreenState();
}

class _ParentAssignmentStatusScreenState
    extends State<ParentAssignmentStatusScreen> {
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _assignments = [];
  List<Map<String, dynamic>> _submissions = [];
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _linkedStudents = [];

  int _selectedStudentId = 0;
  int _selectedClassId = 0;
  int _selectedCourseId = 0;

  @override
  void initState() {
    super.initState();
    _loadAssignmentStatus();
  }

  Future<void> _loadAssignmentStatus() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final responses = await Future.wait([
        ApiService.getParentStudentLinks(),
        ApiService.getStudents(),
        ApiService.getAssignments(),
        ApiService.getSubmissions(),
        ApiService.getSubjects(),
        ApiService.getClasses(),
      ]);

      final links =
          _toMapList(responses[0]);
      final students =
          _toMapList(responses[1]);
      final assignments =
          _toMapList(responses[2]);
      final submissions =
          _toMapList(responses[3]);
      final subjects =
          _toMapList(responses[4]);
      final classes =
          _toMapList(responses[5]);

      final linkedStudentIds = <int>{};

      for (final link in links) {
        final parentId =
            _toInt(link['parent_id']);
        final studentId =
            _toInt(link['student_id']);

        if (parentId == widget.parentId &&
            studentId != null) {
          linkedStudentIds.add(studentId);
        }
      }

      final linkedStudents = students.where((student) {
        final studentId =
            _toInt(student['student_id']);

        return studentId != null &&
            linkedStudentIds.contains(studentId);
      }).toList();

      int selectedStudentId = _selectedStudentId;

      if (!linkedStudentIds.contains(
        selectedStudentId,
      )) {
        selectedStudentId =
            linkedStudents.isNotEmpty
                ? _toInt(
                      linkedStudents.first[
                          'student_id'],
                    ) ??
                    0
                : 0;
      }

      if (!mounted) return;

      setState(() {
        _assignments = assignments;
        _submissions = submissions;
        _subjects = subjects;
        _students = students;
        _classes = classes;
        _linkedStudents = linkedStudents;
        _selectedStudentId = selectedStudentId;
        _loading = false;
      });

      _updateSelectedStudent();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Unable to load assignment status.';
      });
    }
  }

  List<Map<String, dynamic>> _toMapList(
    dynamic value,
  ) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) =>
              Map<String, dynamic>.from(item),
        )
        .toList();
  }

  int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  String _stringValue(
    Map<String, dynamic> data,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = data[key];

      if (value != null &&
          value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }

  void _updateSelectedStudent() {
    _selectedClassId = 0;
    _selectedCourseId = 0;

    if (_selectedStudentId == 0) {
      if (mounted) {
        setState(() {});
      }
      return;
    }

    Map<String, dynamic>? student;

    for (final item in _students) {
      if (_toInt(item['student_id']) ==
          _selectedStudentId) {
        student = item;
        break;
      }
    }

    if (student != null) {
      _selectedCourseId =
          _toInt(student['course_id']) ?? 0;
    }

    // The actual students table does not contain
    // class_id. Resolve the student's class from
    // the student's course.
    if (_selectedCourseId != 0) {
      for (final classRecord in _classes) {
        final courseId =
            _toInt(classRecord['course_id']);

        if (courseId == _selectedCourseId) {
          _selectedClassId =
              _toInt(classRecord['class_id']) ?? 0;
          break;
        }
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  String _studentName() {
    for (final student in _linkedStudents) {
      if (_toInt(student['student_id']) ==
          _selectedStudentId) {
        return _stringValue(
          student,
          ['name'],
          fallback: 'Student',
        );
      }
    }

    return 'Student';
  }

  String _studentRollNo() {
    for (final student in _linkedStudents) {
      if (_toInt(student['student_id']) ==
          _selectedStudentId) {
        return _stringValue(
          student,
          ['roll_no'],
        );
      }
    }

    return '';
  }

  String _subjectName(int subjectId) {
    for (final subject in _subjects) {
      if (_toInt(subject['subject_id']) ==
          subjectId) {
        return _stringValue(
          subject,
          ['subject_name', 'name'],
          fallback: 'Subject $subjectId',
        );
      }
    }

    return 'Subject $subjectId';
  }

  String _className() {
    for (final classRecord in _classes) {
      if (_toInt(classRecord['class_id']) ==
          _selectedClassId) {
        return _stringValue(
          classRecord,
          ['class_name', 'name'],
          fallback: 'Class $_selectedClassId',
        );
      }
    }

    return _selectedClassId == 0
        ? 'Class not assigned'
        : 'Class $_selectedClassId';
  }

  List<Map<String, dynamic>>
      _getStudentAssignments() {
    if (_selectedClassId == 0 &&
        _selectedCourseId == 0) {
      return [];
    }

    final result =
        <Map<String, dynamic>>[];

    for (final assignment in _assignments) {
      final assignmentClassId =
          _toInt(assignment['class_id']);

      // Assignments in the current database are
      // associated with classes through class_id.
      if (_selectedClassId != 0 &&
          assignmentClassId ==
              _selectedClassId) {
        result.add(assignment);
      }
    }

    return result;
  }

  Map<String, dynamic>? _findSubmission(
    int assignmentId,
  ) {
    Map<String, dynamic>? latest;

    for (final submission in _submissions) {
      final studentId =
          _toInt(submission['student_id']);

      final submissionAssignmentId =
          _toInt(submission['assignment_id']);

      if (studentId == _selectedStudentId &&
          submissionAssignmentId ==
              assignmentId) {
        latest = submission;
      }
    }

    return latest;
  }

  String _formatDate(String value) {
    if (value.trim().isEmpty) {
      return '';
    }

    try {
      final date = DateTime.parse(value);

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return value;
    }
  }

  bool _isPastDue(String dueDate) {
    if (dueDate.trim().isEmpty) {
      return false;
    }

    try {
      final date =
          DateTime.parse(dueDate);

      final today = DateTime.now();

      final todayOnly = DateTime(
        today.year,
        today.month,
        today.day,
      );

      final dueOnly = DateTime(
        date.year,
        date.month,
        date.day,
      );

      return dueOnly.isBefore(todayOnly);
    } catch (_) {
      return false;
    }
  }

  bool _isSubmitted(
    Map<String, dynamic>? submission,
  ) {
    if (submission == null) {
      return false;
    }

    final status = _stringValue(
      submission,
      ['status'],
    ).toLowerCase().trim();

    if (status == 'not submitted' ||
        status == 'pending' ||
        status == 'rejected') {
      return false;
    }

    return true;
  }

  String _submissionStatus(
    Map<String, dynamic>? submission,
    String dueDate,
  ) {
    if (submission == null) {
      if (_isPastDue(dueDate)) {
        return 'Overdue';
      }

      return 'Pending';
    }

    final rawStatus = _stringValue(
      submission,
      ['status'],
    ).trim();

    if (rawStatus.isEmpty) {
      return 'Submitted';
    }

    return rawStatus;
  }

  Color _statusColor(String status) {
    final value =
        status.toLowerCase();

    if (value.contains('graded') ||
        value.contains('approved') ||
        value == 'submitted') {
      return Colors.green;
    }

    if (value.contains('overdue') ||
        value.contains('late')) {
      return Colors.red;
    }

    if (value.contains('pending')) {
      return Colors.orange;
    }

    return Colors.grey;
  }

  IconData _statusIcon(String status) {
    final value =
        status.toLowerCase();

    if (value.contains('graded') ||
        value.contains('approved') ||
        value == 'submitted') {
      return Icons.check_circle;
    }

    if (value.contains('overdue') ||
        value.contains('late')) {
      return Icons.warning;
    }

    if (value.contains('pending')) {
      return Icons.pending_actions;
    }

    return Icons.info_outline;
  }

  Widget _buildStudentSelector() {
    if (_linkedStudents.length <= 1) {
      return const SizedBox.shrink();
    }

    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: DropdownButtonFormField<int>(
          initialValue:
              _selectedStudentId == 0
                  ? null
                  : _selectedStudentId,
          decoration:
              const InputDecoration(
            labelText: 'Select Student',
            prefixIcon:
                Icon(Icons.person),
            border:
                OutlineInputBorder(),
          ),
          items: _linkedStudents
              .map((student) {
            final id = _toInt(
              student['student_id'],
            );

            if (id == null) {
              return null;
            }

            return DropdownMenuItem<int>(
              value: id,
              child: Text(
                _stringValue(
                  student,
                  ['name'],
                  fallback: 'Student',
                ),
              ),
            );
          })
              .whereType<
                  DropdownMenuItem<int>>()
              .toList(),
          onChanged: (value) {
            if (value == null) {
              return;
            }

            setState(() {
              _selectedStudentId = value;
            });

            _updateSelectedStudent();
          },
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(
    Map<String, dynamic> assignment,
  ) {
    final assignmentId =
        _toInt(
              assignment['assignment_id'],
            ) ??
            0;

    final title = _stringValue(
      assignment,
      ['title'],
      fallback: 'Assignment',
    );

    final description =
        _stringValue(
      assignment,
      ['description'],
    );

    final subjectId =
        _toInt(
              assignment['subject_id'],
            ) ??
            0;

    final subjectName =
        _subjectName(subjectId);

    final dueDate = _stringValue(
      assignment,
      ['due_date'],
    );

    final submission =
        _findSubmission(
      assignmentId,
    );

    final submitted =
        _isSubmitted(submission);

    final status =
        _submissionStatus(
      submission,
      dueDate,
    );

    final statusColor =
        _statusColor(status);

    final marks = submission == null
        ? null
        : _toDouble(
            submission['marks'] ??
                submission[
                    'marks_obtained'],
          );

    final feedback = submission == null
        ? ''
        : _stringValue(
            submission,
            ['feedback', 'remarks'],
          );

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  _statusIcon(status),
                  color: statusColor,
                  size: 27,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  status,
                  style:
                      TextStyle(
                    color: statusColor,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.book_outlined,
                  size: 17,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child:
                      Text(subjectName),
                ),
              ],
            ),
            if (dueDate.isNotEmpty) ...[
              const SizedBox(height: 7),
              Row(
                children: [
                  const Icon(
                    Icons
                        .calendar_today_outlined,
                    size: 17,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Due: ${_formatDate(dueDate)}',
                  ),
                ],
              ),
            ],
            if (description.isNotEmpty) ...[
              const SizedBox(height: 9),
              Text(
                description,
                maxLines: 3,
                overflow:
                    TextOverflow.ellipsis,
              ),
            ],
            if (submitted &&
                marks != null) ...[
              const SizedBox(height: 9),
              Text(
                'Marks: ${marks % 1 == 0 ? marks.toInt() : marks.toStringAsFixed(1)}',
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
            if (feedback.isNotEmpty) ...[
              const SizedBox(height: 7),
              Text(
                'Feedback: $feedback',
                style:
                    TextStyle(
                  color:
                      Colors.grey.shade700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(
    int total,
    int submitted,
    int pending,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _studentName(),
              style:
                  const TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            if (_studentRollNo()
                .isNotEmpty)
              Text(
                '${_studentRollNo()} • ${_className()}',
                style: TextStyle(
                  color:
                      Colors.grey.shade700,
                ),
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _summaryItem(
                    value: '$submitted',
                    label: 'Submitted',
                    color:
                        Colors.green,
                  ),
                ),
                Expanded(
                  child: _summaryItem(
                    value: '$pending',
                    label: 'Pending',
                    color:
                        Colors.orange,
                  ),
                ),
                Expanded(
                  child: _summaryItem(
                    value: '$total',
                    label: 'Total',
                    color:
                        Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style:
              TextStyle(
            fontSize: 24,
            fontWeight:
                FontWeight.bold,
            color: color,
          ),
        ),
        Text(label),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 52,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load assignment status.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              textAlign:
                  TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed:
                  _loadAssignmentStatus,
              icon: const Icon(
                Icons.refresh,
              ),
              label:
                  const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _buildError();
    }

    if (_linkedStudents.isEmpty) {
      return RefreshIndicator(
        onRefresh:
            _loadAssignmentStatus,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 140),
            Icon(
              Icons.link_off,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'No students are linked to this parent account.',
              textAlign:
                  TextAlign.center,
            ),
          ],
        ),
      );
    }

    final assignments =
        _getStudentAssignments();

    int submitted = 0;
    int pending = 0;

    for (final assignment
        in assignments) {
      final assignmentId =
          _toInt(
                assignment[
                    'assignment_id'],
              ) ??
              0;

      final submission =
          _findSubmission(
        assignmentId,
      );

      if (_isSubmitted(
        submission,
      )) {
        submitted++;
      } else {
        pending++;
      }
    }

    return RefreshIndicator(
      onRefresh:
          _loadAssignmentStatus,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(16),
        children: [
          _buildStudentSelector(),

          _buildSummary(
            assignments.length,
            submitted,
            pending,
          ),

          const SizedBox(height: 14),

          if (assignments.isEmpty)
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons
                          .assignment_outlined,
                      size: 60,
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    const Text(
                      'No assignments found.',
                      textAlign:
                          TextAlign.center,
                      style:
                          TextStyle(
                        fontSize: 19,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      'No assignments are currently available for ${_studentName()}.',
                      textAlign:
                          TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...assignments.map(
              _buildAssignmentCard,
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Assignment Status'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                _loading
                    ? null
                    : _loadAssignmentStatus,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}

