import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  State<ClassManagementScreen> createState() =>
      _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  List<dynamic> _classes = [];
  List<dynamic> _courses = [];
  List<dynamic> _faculty = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getClasses(),
        ApiService.getCourses(),
        ApiService.getFaculty(),
      ]);

      if (!mounted) return;

      setState(() {
        _classes = List<dynamic>.from(results[0]);
        _courses = List<dynamic>.from(results[1]);
        _faculty = List<dynamic>.from(results[2]);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // SAFE VALUE HELPERS
  // ============================================================

  dynamic _value(
    Map<dynamic, dynamic> item,
    List<String> keys,
  ) {
    for (final key in keys) {
      if (item[key] != null) {
        return item[key];
      }
    }

    return null;
  }

  int? _intValue(
    Map<dynamic, dynamic> item,
    List<String> keys,
  ) {
    final value = _value(item, keys);

    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  String _stringValue(
    Map<dynamic, dynamic> item,
    List<String> keys, {
    String fallback = 'N/A',
  }) {
    final value = _value(item, keys);

    if (value == null) return fallback;

    final text = value.toString().trim();

    return text.isEmpty ? fallback : text;
  }

  // ============================================================
  // COURSE HELPERS
  // ============================================================

  int? _courseId(Map<dynamic, dynamic> item) {
    return _intValue(item, [
      'course_id',
      'courseId',
      'id',
    ]);
  }

  String _courseName(Map<dynamic, dynamic> item) {
    return _stringValue(
      item,
      [
        'course_name',
        'courseName',
        'name',
      ],
      fallback: 'Course',
    );
  }

  // ============================================================
  // FACULTY HELPERS
  // ============================================================

  int? _facultyId(Map<dynamic, dynamic> item) {
    return _intValue(item, [
      'faculty_id',
      'facultyId',
      'id',
    ]);
  }

  String _facultyName(Map<dynamic, dynamic> item) {
    return _stringValue(
      item,
      [
        'name',
        'faculty_name',
        'facultyName',
      ],
      fallback: 'Faculty',
    );
  }

  // ============================================================
  // CLASS HELPERS
  // ============================================================

  int? _classId(Map<dynamic, dynamic> item) {
    return _intValue(item, [
      'class_id',
      'classId',
      'id',
    ]);
  }

  String _className(Map<dynamic, dynamic> item) {
    return _stringValue(
      item,
      [
        'class_name',
        'className',
        'name',
      ],
      fallback: 'Class',
    );
  }

  int? _semester(Map<dynamic, dynamic> item) {
    return _intValue(item, [
      'semester',
    ]);
  }

  String _academicYear(Map<dynamic, dynamic> item) {
    return _stringValue(
      item,
      [
        'academic_year',
        'academicYear',
      ],
      fallback: 'N/A',
    );
  }

  int? _classTeacherId(Map<dynamic, dynamic> item) {
    return _intValue(item, [
      'class_teacher_id',
      'classTeacherId',
    ]);
  }

  // ============================================================
  // FIND COURSE / FACULTY
  // ============================================================

  String _getCourseDisplayName(int? courseId) {
    if (courseId == null) return 'Course not assigned';

    for (final value in _courses) {
      if (value is! Map) continue;

      final item = Map<dynamic, dynamic>.from(value);

      if (_courseId(item) == courseId) {
        return _courseName(item);
      }
    }

    return 'Course #$courseId';
  }

  String _getFacultyDisplayName(int? facultyId) {
    if (facultyId == null) return 'Not assigned';

    for (final value in _faculty) {
      if (value is! Map) continue;

      final item = Map<dynamic, dynamic>.from(value);

      if (_facultyId(item) == facultyId) {
        return _facultyName(item);
      }
    }

    return 'Faculty #$facultyId';
  }

  // ============================================================
  // ADD / EDIT CLASS DIALOG
  // ============================================================

  Future<void> _showClassDialog({
    Map<dynamic, dynamic>? existingClass,
  }) async {
    final isEditing = existingClass != null;

    final formKey = GlobalKey<FormState>();

    final classNameController = TextEditingController(
      text: isEditing ? _className(existingClass) : '',
    );

    final academicYearController = TextEditingController(
      text: isEditing ? _academicYear(existingClass) : '',
    );

    int? selectedCourseId =
        isEditing ? _courseId(existingClass) : null;

    int? selectedSemester =
        isEditing ? _semester(existingClass) : null;

    int? selectedFacultyId =
        isEditing ? _classTeacherId(existingClass) : null;

    bool isSaving = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> saveClass() async {
              if (!formKey.currentState!.validate()) {
                return;
              }

              if (selectedCourseId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a course'),
                  ),
                );
                return;
              }

              if (selectedSemester == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a semester'),
                  ),
                );
                return;
              }

              setDialogState(() {
                isSaving = true;
              });

              try {
                if (isEditing) {
                  final classId = _classId(existingClass);

                  if (classId == null) {
                    throw Exception('Invalid class ID');
                  }

                  await ApiService.updateClass(
                    classId: classId,
                    courseId: selectedCourseId!,
                    className: classNameController.text.trim(),
                    semester: selectedSemester!,
                    academicYear:
                        academicYearController.text.trim(),
                    classTeacherId: selectedFacultyId,
                  );
                } else {
                  await ApiService.createClass(
                    courseId: selectedCourseId!,
                    className: classNameController.text.trim(),
                    semester: selectedSemester!,
                    academicYear:
                        academicYearController.text.trim(),
                    classTeacherId: selectedFacultyId,
                  );
                }

                if (!mounted || !dialogContext.mounted) return;

                Navigator.of(dialogContext).pop(true);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditing
                          ? 'Class updated successfully'
                          : 'Class created successfully',
                    ),
                  ),
                );
              } catch (e) {
                if (!mounted) return;

                setDialogState(() {
                  isSaving = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to save class: $e',
                    ),
                  ),
                );
              }
            }

            return AlertDialog(
              title: Text(
                isEditing ? 'Edit Class' : 'Add Class',
              ),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // COURSE
                        DropdownButtonFormField<int>(
                          initialValue: selectedCourseId,
                          decoration: const InputDecoration(
                            labelText: 'Course',
                            border: OutlineInputBorder(),
                            prefixIcon:
                                Icon(Icons.school_outlined),
                          ),
                          items: _courses
                              .whereType<Map>()
                              .map((value) {
                            final item =
                                Map<dynamic, dynamic>.from(value);

                            final id = _courseId(item);

                            if (id == null) return null;

                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(
                                _courseName(item),
                              ),
                            );
                          })
                              .whereType<DropdownMenuItem<int>>()
                              .toList(),
                          onChanged: isSaving
                              ? null
                              : (value) {
                                  setDialogState(() {
                                    selectedCourseId = value;
                                  });
                                },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a course';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // CLASS NAME
                        TextFormField(
                          controller: classNameController,
                          enabled: !isSaving,
                          decoration: const InputDecoration(
                            labelText: 'Class Name',
                            hintText: 'Example: FY Computer A',
                            border: OutlineInputBorder(),
                            prefixIcon:
                                Icon(Icons.class_outlined),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter class name';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // SEMESTER
                        DropdownButtonFormField<int>(
                          initialValue:selectedSemester,
                          decoration: const InputDecoration(
                            labelText: 'Semester',
                            border: OutlineInputBorder(),
                            prefixIcon:
                                Icon(Icons.menu_book_outlined),
                          ),
                          items: List.generate(
                            8,
                            (index) => DropdownMenuItem<int>(
                              value: index + 1,
                              child: Text(
                                'Semester ${index + 1}',
                              ),
                            ),
                          ),
                          onChanged: isSaving
                              ? null
                              : (value) {
                                  setDialogState(() {
                                    selectedSemester = value;
                                  });
                                },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select semester';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // ACADEMIC YEAR
                        TextFormField(
                          controller: academicYearController,
                          enabled: !isSaving,
                          decoration: const InputDecoration(
                            labelText: 'Academic Year',
                            hintText: 'Example: 2026-27',
                            border: OutlineInputBorder(),
                            prefixIcon:
                                Icon(Icons.calendar_today),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter academic year';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // CLASS TEACHER
                        DropdownButtonFormField<int?>(
                          initialValue: selectedFacultyId,
                          decoration: const InputDecoration(
                            labelText: 'Class Teacher',
                            border: OutlineInputBorder(),
                            prefixIcon:
                                Icon(Icons.person_outline),
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('Not Assigned'),
                            ),
                            ..._faculty
                                .whereType<Map>()
                                .map((value) {
                              final item =
                                  Map<dynamic, dynamic>.from(value);

                              final id = _facultyId(item);

                              if (id == null) return null;

                              return DropdownMenuItem<int?>(
                                value: id,
                                child: Text(
                                  _facultyName(item),
                                ),
                              );
                            })
                                .whereType<DropdownMenuItem<int?>>()
                                
                          ],
                          onChanged: isSaving
                              ? null
                              : (value) {
                                  setDialogState(() {
                                    selectedFacultyId = value;
                                  });
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop(false);
                        },
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: isSaving ? null : saveClass,
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    isSaving ? 'Saving...' : 'Save',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    classNameController.dispose();
    academicYearController.dispose();

    if (result == true) {
      await _loadData();
    }
  }

  // ============================================================
  // VIEW CLASS
  // ============================================================

  void _showClassDetails(Map<dynamic, dynamic> item) {
    final classId = _classId(item);
    final courseId = _courseId(item);
    final semester = _semester(item);
    final teacherId = _classTeacherId(item);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_className(item)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow(
                  'Class ID',
                  classId?.toString() ?? 'N/A',
                ),
                _detailRow(
                  'Class Name',
                  _className(item),
                ),
                _detailRow(
                  'Course',
                  _getCourseDisplayName(courseId),
                ),
                _detailRow(
                  'Semester',
                  semester?.toString() ?? 'N/A',
                ),
                _detailRow(
                  'Academic Year',
                  _academicYear(item),
                ),
                _detailRow(
                  'Class Teacher',
                  _getFacultyDisplayName(teacherId),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DELETE CLASS
  // ============================================================

  Future<void> _deleteClass(Map<dynamic, dynamic> item) async {
    final classId = _classId(item);

    if (classId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid class ID'),
        ),
      );
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Class'),
          content: Text(
            'Are you sure you want to delete "${_className(item)}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await ApiService.deleteClass(classId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Class deleted successfully'),
        ),
      );

      await _loadData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete class: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // CLASS CARD
  // ============================================================

  Widget _buildClassCard(dynamic value) {
    if (value is! Map) {
      return const SizedBox.shrink();
    }

    final item = Map<dynamic, dynamic>.from(value);

    final courseId = _courseId(item);
    final teacherId = _classTeacherId(item);
    final semester = _semester(item);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            semester?.toString() ?? '?',
          ),
        ),
        title: Text(
          _className(item),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getCourseDisplayName(courseId),
              ),
              const SizedBox(height: 4),
              Text(
                'Semester ${semester ?? 'N/A'} • '
                '${_academicYear(item)}',
              ),
              const SizedBox(height: 4),
              Text(
                'Teacher: ${_getFacultyDisplayName(teacherId)}',
              ),
            ],
          ),
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'view') {
              _showClassDetails(item);
            } else if (value == 'edit') {
              _showClassDialog(existingClass: item);
            } else if (value == 'delete') {
              _deleteClass(item);
            }
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem<String>(
                value: 'view',
                child: ListTile(
                  leading: Icon(Icons.visibility_outlined),
                  title: Text('View'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem<String>(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Edit'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline),
                  title: Text('Delete'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ];
          },
        ),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 56,
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to load classes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
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

    if (_classes.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Center(
              child: Icon(
                Icons.class_outlined,
                size: 64,
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'No classes found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _classes.length,
        itemBuilder: (context, index) {
          return _buildClassCard(_classes[index]);
        },
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Management'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading
            ? null
            : () => _showClassDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Class'),
      ),
    );
  }
}