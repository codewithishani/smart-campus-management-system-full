import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CourseSubjectManagementScreen extends StatefulWidget {
  const CourseSubjectManagementScreen({super.key});

  @override
  State<CourseSubjectManagementScreen> createState() =>
      _CourseSubjectManagementScreenState();
}

class _CourseSubjectManagementScreenState
    extends State<CourseSubjectManagementScreen> {
  bool _loading = true;
  String? _error;

  List<dynamic> _courses = [];
  List<dynamic> _subjects = [];
  List<dynamic> _departments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final results = await Future.wait([
        ApiService.getCourses(),
        ApiService.getSubjects(),
        ApiService.getDepartments(),
      ]);

      if (!mounted) return;

      setState(() {
        _courses = List<dynamic>.from(results[0]);
        _subjects = List<dynamic>.from(results[1]);
        _departments = List<dynamic>.from(results[2]);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  int _intValue(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _stringValue(dynamic value) {
    return value?.toString() ?? '';
  }

  int _courseId(dynamic course) {
    return _intValue(course['course_id']);
  }

  int _subjectId(dynamic subject) {
    return _intValue(subject['subject_id']);
  }

  String _courseName(dynamic course) {
    return _stringValue(course['course_name']);
  }

  String _courseCode(dynamic course) {
    return _stringValue(course['course_code']);
  }

  int _departmentId(dynamic course) {
    return _intValue(course['department_id']);
  }

  String _subjectName(dynamic subject) {
    return _stringValue(subject['subject_name']);
  }

  String _subjectCode(dynamic subject) {
    return _stringValue(subject['subject_code']);
  }

  int _subjectCourseId(dynamic subject) {
    return _intValue(subject['course_id']);
  }

  String _departmentName(int departmentId) {
    for (final department in _departments) {
      if (_intValue(department['department_id']) == departmentId) {
        return _stringValue(department['department_name']);
      }
    }

    return 'Department ID: $departmentId';
  }

  List<dynamic> _subjectsForCourse(int courseId) {
    return _subjects
        .where((subject) => _subjectCourseId(subject) == courseId)
        .toList();
  }

  Future<void> _showCourseDialog({dynamic course}) async {
    final bool isEdit = course != null;

    final nameController = TextEditingController(
      text: isEdit ? _courseName(course) : '',
    );

    final codeController = TextEditingController(
      text: isEdit ? _courseCode(course) : '',
    );

    final durationController = TextEditingController(
      text: isEdit && course['duration'] != null
          ? course['duration'].toString()
          : '',
    );

    final descriptionController = TextEditingController(
      text: isEdit ? _stringValue(course['description']) : '',
    );

    int? selectedDepartmentId =
        isEdit ? _departmentId(course) : null;

    String? validationError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogBuilderContext, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Course' : 'Add Course'),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<int>(
                        initialValue: selectedDepartmentId,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          border: OutlineInputBorder(),
                        ),
                        items: _departments.map((department) {
                          final id =
                              _intValue(department['department_id']);
                          final name =
                              _stringValue(department['department_name']);

                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedDepartmentId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Course Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: codeController,
                        decoration: const InputDecoration(
                          labelText: 'Course Code',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: durationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Duration (Years)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (validationError != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          validationError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedDepartmentId == null) {
                      setDialogState(() {
                        validationError =
                            'Please select a department.';
                      });
                      return;
                    }

                    final courseName = nameController.text.trim();
                    final courseCode = codeController.text.trim();
                    final durationText =
                        durationController.text.trim();

                    if (courseName.isEmpty) {
                      setDialogState(() {
                        validationError =
                            'Course name is required.';
                      });
                      return;
                    }

                    if (courseCode.isEmpty) {
                      setDialogState(() {
                        validationError =
                            'Course code is required.';
                      });
                      return;
                    }

                    final duration = durationText.isEmpty
                        ? null
                        : int.tryParse(durationText);

                    if (durationText.isNotEmpty && duration == null) {
                      setDialogState(() {
                        validationError =
                            'Duration must be a valid number.';
                      });
                      return;
                    }

                    try {
                      if (isEdit) {
                        await ApiService.updateCourse(
                          courseId: _courseId(course),
                          departmentId: selectedDepartmentId!,
                          courseName: courseName,
                          courseCode: courseCode,
                          duration: duration,
                          description:
                              descriptionController.text.trim().isEmpty
                                  ? null
                                  : descriptionController.text.trim(),
                        );
                      } else {
                        await ApiService.createCourse(
                          departmentId: selectedDepartmentId!,
                          courseName: courseName,
                          courseCode: courseCode,
                          duration: duration,
                          description:
                              descriptionController.text.trim().isEmpty
                                  ? null
                                  : descriptionController.text.trim(),
                        );
                      }

                      if (!mounted) return;

                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEdit
                                ? 'Course updated successfully.'
                                : 'Course created successfully.',
                          ),
                        ),
                      );

                      await _loadData();
                    } catch (e) {
                      if (!mounted) return;

                      setDialogState(() {
                        validationError = e.toString();
                      });
                    }
                  },
                  child: Text(isEdit ? 'Update' : 'Create'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    codeController.dispose();
    durationController.dispose();
    descriptionController.dispose();
  }

  Future<void> _deleteCourse(dynamic course) async {
    final courseId = _courseId(course);
    final courseName = _courseName(course);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Course'),
          content: Text(
            'Are you sure you want to delete "$courseName"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await ApiService.deleteCourse(courseId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course deleted successfully.'),
        ),
      );

      await _loadData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to delete course: $e'),
        ),
      );
    }
  }

  Future<void> _showSubjectDialog({
    dynamic subject,
    required int courseId,
  }) async {
    final bool isEdit = subject != null;

    final nameController = TextEditingController(
      text: isEdit ? _subjectName(subject) : '',
    );

    final codeController = TextEditingController(
      text: isEdit ? _subjectCode(subject) : '',
    );

    final semesterController = TextEditingController(
      text: isEdit ? _stringValue(subject['semester']) : '',
    );

    final creditsController = TextEditingController(
      text: isEdit ? _stringValue(subject['credits']) : '',
    );

    final descriptionController = TextEditingController(
      text: isEdit ? _stringValue(subject['description']) : '',
    );

    String? validationError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogBuilderContext, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Subject' : 'Add Subject'),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Subject Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: codeController,
                        decoration: const InputDecoration(
                          labelText: 'Subject Code',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: semesterController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Semester',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: creditsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Credits',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (validationError != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          validationError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final subjectName = nameController.text.trim();
                    final subjectCode = codeController.text.trim();

                    if (subjectName.isEmpty) {
                      setDialogState(() {
                        validationError =
                            'Subject name is required.';
                      });
                      return;
                    }

                    if (subjectCode.isEmpty) {
                      setDialogState(() {
                        validationError =
                            'Subject code is required.';
                      });
                      return;
                    }

                    final semester = int.tryParse(
                      semesterController.text.trim(),
                    );

                    final credits = int.tryParse(
                      creditsController.text.trim(),
                    );

                    if (semester == null) {
                      setDialogState(() {
                        validationError =
                            'Semester must be a valid number.';
                      });
                      return;
                    }

                    if (credits == null) {
                      setDialogState(() {
                        validationError =
                            'Credits must be a valid number.';
                      });
                      return;
                    }

                    try {
                      if (isEdit) {
                        await ApiService.updateSubject(
                          subjectId: _subjectId(subject),
                          courseId: courseId,
                          subjectName: subjectName,
                          subjectCode: subjectCode,
                          semester: semester,
                          credits: credits,
                          description:
                              descriptionController.text.trim().isEmpty
                                  ? null
                                  : descriptionController.text.trim(),
                        );
                      } else {
                        await ApiService.createSubject(
                          courseId: courseId,
                          subjectName: subjectName,
                          subjectCode: subjectCode,
                          semester: semester,
                          credits: credits,
                          description:
                              descriptionController.text.trim().isEmpty
                                  ? null
                                  : descriptionController.text.trim(),
                        );
                      }

                      if (!mounted) return;

                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEdit
                                ? 'Subject updated successfully.'
                                : 'Subject created successfully.',
                          ),
                        ),
                      );

                      await _loadData();
                    } catch (e) {
                      if (!mounted) return;

                      setDialogState(() {
                        validationError = e.toString();
                      });
                    }
                  },
                  child: Text(isEdit ? 'Update' : 'Create'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    codeController.dispose();
    semesterController.dispose();
    creditsController.dispose();
    descriptionController.dispose();
  }

  Future<void> _deleteSubject(dynamic subject) async {
    final subjectId = _subjectId(subject);
    final subjectName = _subjectName(subject);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Subject'),
          content: Text(
            'Are you sure you want to delete "$subjectName"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await ApiService.deleteSubject(subjectId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subject deleted successfully.'),
        ),
      );

      await _loadData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to delete subject: $e'),
        ),
      );
    }
  }

  Widget _buildSubjectTile(dynamic subject) {
    final subjectName = _subjectName(subject);
    final subjectCode = _subjectCode(subject);
    final semester = _stringValue(subject['semester']);
    final credits = _stringValue(subject['credits']);

    return Card(
      margin: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 8,
      ),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.book_outlined),
        ),
        title: Text(
          subjectName.isEmpty ? 'Unnamed Subject' : subjectName,
        ),
        subtitle: Text(
          [
            if (subjectCode.isNotEmpty) subjectCode,
            if (semester.isNotEmpty) 'Semester $semester',
            if (credits.isNotEmpty) '$credits Credits',
          ].join(' • '),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showSubjectDialog(
                subject: subject,
                courseId: _subjectCourseId(subject),
              );
            } else if (value == 'delete') {
              _deleteSubject(subject);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(dynamic course) {
    final courseId = _courseId(course);
    final courseName = _courseName(course);
    final courseCode = _courseCode(course);
    final departmentId = _departmentId(course);
    final duration = course['duration'];
    final subjects = _subjectsForCourse(courseId);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: const CircleAvatar(
          child: Icon(Icons.menu_book),
        ),
        title: Text(
          courseName.isEmpty ? 'Unnamed Course' : courseName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          [
            if (courseCode.isNotEmpty) courseCode,
            _departmentName(departmentId),
            if (duration != null) '$duration Years',
            '${subjects.length} Subject${subjects.length == 1 ? '' : 's'}',
          ].join(' • '),
        ),
        children: [
          if (subjects.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'No subjects added for this course.',
                ),
              ),
            )
          else
            ...subjects.map(_buildSubjectTile),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showSubjectDialog(courseId: courseId);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Subject'),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showCourseDialog(course: course);
                    } else if (value == 'delete') {
                      _deleteCourse(course);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit Course'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Course'),
                    ),
                  ],
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.more_vert),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course & Subjects'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading || _departments.isEmpty
            ? null
            : () => _showCourseDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
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
              const Text(
                'Unable to load courses and subjects.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_courses.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Center(
              child: Text(
                'No courses found in the database.',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: _courses.map(_buildCourseCard).toList(),
      ),
    );
  }
}