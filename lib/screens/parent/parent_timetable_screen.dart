import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ParentTimetableScreen extends StatefulWidget {
  final int parentId;

  const ParentTimetableScreen({
    super.key,
    required this.parentId,
  });

  @override
  State<ParentTimetableScreen> createState() =>
      _ParentTimetableScreenState();
}

class _ParentTimetableScreenState
    extends State<ParentTimetableScreen> {
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _timetable = [];
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _classes = [];

  List<Map<String, dynamic>> _linkedStudents = [];

  int _selectedStudentId = 0;
  int _selectedClassId = 0;
  int _selectedCourseId = 0;

  final List<String> _weekdays = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  @override
  void initState() {
    super.initState();
    _loadTimetable();
  }

  Future<void> _loadTimetable() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final responses = await Future.wait([
        ApiService.getParentStudentLinks(),
        ApiService.getStudents(),
        ApiService.getTimetable(),
        ApiService.getSubjects(),
        ApiService.getClasses(),
      ]);

      final links = _toMapList(responses[0]);
      final students = _toMapList(responses[1]);
      final timetable = _toMapList(responses[2]);
      final subjects = _toMapList(responses[3]);
      final classes = _toMapList(responses[4]);

      final linkedStudentIds = <int>{};

      for (final link in links) {
        final parentId = _toInt(link['parent_id']);
        final studentId = _toInt(link['student_id']);

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
        _students = students;
        _timetable = timetable;
        _subjects = subjects;
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
        _error = 'Unable to load timetable data.';
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

    if (student == null) {
      if (mounted) {
        setState(() {});
      }
      return;
    }

    _selectedCourseId =
        _toInt(student['course_id']) ?? 0;

    // Students table has no class_id.
    // Resolve the class from the student's course.
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

  String _studentName(
    Map<String, dynamic> student,
  ) {
    return _stringValue(
      student,
      ['name'],
      fallback: 'Student',
    );
  }

  String _studentRollNo(
    Map<String, dynamic> student,
  ) {
    return _stringValue(
      student,
      ['roll_no'],
    );
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

  String _subjectCode(int subjectId) {
    for (final subject in _subjects) {
      if (_toInt(subject['subject_id']) ==
          subjectId) {
        return _stringValue(
          subject,
          ['subject_code', 'code'],
        );
      }
    }

    return '';
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

    if (_selectedClassId == 0) {
      return 'Class not assigned';
    }

    return 'Class $_selectedClassId';
  }

  String _normalizeDay(String value) {
    switch (value.trim().toLowerCase()) {
      case 'mon':
      case 'monday':
        return 'Monday';

      case 'tue':
      case 'tues':
      case 'tuesday':
        return 'Tuesday';

      case 'wed':
      case 'wednesday':
        return 'Wednesday';

      case 'thu':
      case 'thur':
      case 'thurs':
      case 'thursday':
        return 'Thursday';

      case 'fri':
      case 'friday':
        return 'Friday';

      case 'sat':
      case 'saturday':
        return 'Saturday';

      case 'sun':
      case 'sunday':
        return 'Sunday';

      default:
        return value;
    }
  }

  String _recordDay(
    Map<String, dynamic> record,
  ) {
    return _normalizeDay(
      _stringValue(
        record,
        ['day', 'weekday', 'day_name'],
      ),
    );
  }

  String _formatTime(String value) {
    if (value.trim().isEmpty) {
      return 'Time';
    }

    final parts = value.split(':');

    if (parts.length < 2) {
      return value;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return value;
    }

    final period = hour >= 12 ? 'PM' : 'AM';

    final displayHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;

    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String _recordTime(
    Map<String, dynamic> record,
  ) {
    final start = _stringValue(
      record,
      ['start_time', 'time', 'from_time'],
    );

    final end = _stringValue(
      record,
      ['end_time', 'to_time'],
    );

    if (start.isEmpty) {
      return 'Time';
    }

    final formattedStart =
        _formatTime(start);

    if (end.isEmpty) {
      return formattedStart;
    }

    return '$formattedStart - ${_formatTime(end)}';
  }

  List<Map<String, dynamic>> _recordsForDay(
    String day,
  ) {
    if (_selectedClassId == 0 &&
        _selectedCourseId == 0) {
      return [];
    }

    final records = <Map<String, dynamic>>[];

    for (final record in _timetable) {
      if (_recordDay(record) != day) {
        continue;
      }

      final recordClassId =
          _toInt(record['class_id']);

      final recordCourseId =
          _toInt(record['course_id']);

      bool belongsToStudent = false;

      if (_selectedClassId != 0 &&
          recordClassId == _selectedClassId) {
        belongsToStudent = true;
      }

      if (!belongsToStudent &&
          _selectedCourseId != 0 &&
          recordCourseId == _selectedCourseId) {
        belongsToStudent = true;
      }

      if (belongsToStudent) {
        records.add(record);
      }
    }

    records.sort((a, b) {
      final aTime = _stringValue(
        a,
        ['start_time', 'time', 'from_time'],
      );

      final bTime = _stringValue(
        b,
        ['start_time', 'time', 'from_time'],
      );

      return aTime.compareTo(bTime);
    });

    return records;
  }

  Widget _buildTimetableEntry(
    Map<String, dynamic> record,
  ) {
    final subjectId =
        _toInt(record['subject_id']) ?? 0;

    final subjectName =
        _subjectName(subjectId);

    final code =
        _subjectCode(subjectId);

    final room = _stringValue(
      record,
      ['room_no', 'room', 'room_number'],
    );

    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            subjectName.isNotEmpty
                ? subjectName[0].toUpperCase()
                : 'S',
          ),
        ),
        title: Text(
          subjectName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _recordTime(record),
            ),
            if (code.isNotEmpty)
              Text(code),
            if (room.isNotEmpty)
              Text('Room: $room'),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySection(String day) {
    final records =
        _recordsForDay(day);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              day,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (records.isEmpty)
              const Padding(
                padding:
                    EdgeInsets.symmetric(
                  vertical: 14,
                ),
                child: Text(
                  'No classes scheduled.',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              )
            else
              ...records.map(
                _buildTimetableEntry,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentSelector() {
    if (_linkedStudents.length <= 1) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: DropdownButtonFormField<int>(
          initialValue: _selectedStudentId,
          decoration: const InputDecoration(
            labelText: 'Select Student',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          items: _linkedStudents.map(
            (student) {
              final id =
                  _toInt(student['student_id']);

              if (id == null) {
                return null;
              }

              return DropdownMenuItem<int>(
                value: id,
                child: Text(
                  _studentName(student),
                ),
              );
            },
          ).whereType<DropdownMenuItem<int>>()
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

  Widget _buildStudentHeader() {
    Map<String, dynamic>? student;

    for (final item in _linkedStudents) {
      if (_toInt(item['student_id']) ==
          _selectedStudentId) {
        student = item;
        break;
      }
    }

    if (student == null) {
      return const SizedBox.shrink();
    }

    final rollNo =
        _studentRollNo(student);

    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(
            Icons.calendar_month,
          ),
        ),
        title: Text(
          _studentName(student),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          rollNo.isEmpty
              ? _className()
              : '$rollNo • ${_className()}',
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 52,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load timetable.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadTimetable,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _buildError();
    }

    if (_linkedStudents.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadTimetable,
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTimetable,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          28,
        ),
        children: [
          _buildStudentSelector(),
          if (_linkedStudents.length > 1)
            const SizedBox(height: 12),
          _buildStudentHeader(),
          const SizedBox(height: 16),
          ..._weekdays.map(
            _buildDaySection,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                _loading ? null : _loadTimetable,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}