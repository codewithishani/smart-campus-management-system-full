import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState
    extends State<StudentManagementScreen> {
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> departments = [];

  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> loadStudents() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await Future.wait([
        ApiService.getStudents(),
        ApiService.getCourses(),
        ApiService.getDepartments(),
      ]);

      final studentData = data[0]
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      final courseData = data[1]
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      final departmentData = data[2]
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      if (!mounted) return;

      setState(() {
        students = studentData;
        courses = courseData;
        departments = departmentData;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load students.\n$e';
      });
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

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

  String getCourseName(int courseId) {
    for (final course in courses) {
      if (getIntValue(
            course,
            ['course_id', 'id'],
          ) ==
          courseId) {
        return getStringValue(
          course,
          ['course_name', 'name', 'title'],
          defaultValue: 'Course',
        );
      }
    }

    return courseId == 0
        ? 'Course not assigned'
        : 'Course $courseId';
  }

  String getDepartmentName(int departmentId) {
    for (final department in departments) {
      if (getIntValue(
            department,
            ['department_id', 'id'],
          ) ==
          departmentId) {
        return getStringValue(
          department,
          ['department_name', 'name', 'title'],
          defaultValue: 'Department',
        );
      }
    }

    return departmentId == 0
        ? 'Department not assigned'
        : 'Department $departmentId';
  }

  List<Map<String, dynamic>> get filteredStudents {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return students;
    }

    return students.where((student) {
      final name = getStringValue(
        student,
        ['name'],
      ).toLowerCase();

      final rollNo = getStringValue(
        student,
        ['roll_no'],
      ).toLowerCase();

      final email = getStringValue(
        student,
        ['email'],
      ).toLowerCase();

      final course = getCourseName(
        getIntValue(
          student,
          ['course_id'],
        ),
      ).toLowerCase();

      final department = getDepartmentName(
        getIntValue(
          student,
          ['department_id'],
        ),
      ).toLowerCase();

      return name.contains(query) ||
          rollNo.contains(query) ||
          email.contains(query) ||
          course.contains(query) ||
          department.contains(query);
    }).toList();
  }

  // ============================================================
  // ADD STUDENT
  // ============================================================

  Future<void> showAddStudentDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: !isSaving,
      builder: (dialogContext) {
        return StudentFormDialog(
          title: 'Add Student',
          courses: courses,
          departments: departments,
          onSubmit: (data) async {
            await _createStudent(data);
          },
        );
      },
    );
  }

  Future<void> _createStudent(
    Map<String, dynamic> data,
  ) async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      await ApiService.createStudent(data);

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Student added successfully.',
          ),
        ),
      );

      await loadStudents();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      rethrow;
    }
  }

  // ============================================================
  // EDIT STUDENT
  // ============================================================

  Future<void> showEditStudentDialog(
    Map<String, dynamic> student,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: !isSaving,
      builder: (dialogContext) {
        return StudentFormDialog(
          title: 'Edit Student',
          student: student,
          courses: courses,
          departments: departments,
          onSubmit: (data) async {
            final studentId = getIntValue(
              student,
              ['student_id'],
            );

            await _updateStudent(
              studentId,
              data,
            );
          },
        );
      },
    );
  }

  Future<void> _updateStudent(
    int studentId,
    Map<String, dynamic> data,
  ) async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      await ApiService.updateStudent(
        studentId,
        data,
      );

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Student updated successfully.',
          ),
        ),
      );

      await loadStudents();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      rethrow;
    }
  }

  // ============================================================
  // DELETE STUDENT
  // ============================================================

  Future<void> confirmDeleteStudent(
    Map<String, dynamic> student,
  ) async {
    final studentId = getIntValue(
      student,
      ['student_id'],
    );

    final name = getStringValue(
      student,
      ['name'],
      defaultValue: 'Student',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Student'),
          content: Text(
            'Are you sure you want to delete "$name"?\n\n'
            'Student ID: $studentId\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteStudent(studentId);
    }
  }

  Future<void> _deleteStudent(
    int studentId,
  ) async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      await ApiService.deleteStudent(studentId);

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Student deleted successfully.',
          ),
        ),
      );

      await loadStudents();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete student.\n$e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // STUDENT DETAILS
  // ============================================================

  Future<void> showStudentDetails(
    Map<String, dynamic> student,
  ) async {
    final studentId = getIntValue(
      student,
      ['student_id'],
    );

    final userId = getIntValue(
      student,
      ['user_id'],
    );

    final rollNo = getStringValue(
      student,
      ['roll_no'],
      defaultValue: 'Not available',
    );

    final name = getStringValue(
      student,
      ['name'],
      defaultValue: 'Student',
    );

    final email = getStringValue(
      student,
      ['email'],
      defaultValue: 'Not available',
    );

    final phone = getStringValue(
      student,
      ['phone'],
      defaultValue: 'Not available',
    );

    final semester = getIntValue(
      student,
      ['semester'],
    );

    final courseId = getIntValue(
      student,
      ['course_id'],
    );

    final departmentId = getIntValue(
      student,
      ['department_id'],
    );

    final address = getStringValue(
      student,
      ['address'],
      defaultValue: 'Not available',
    );

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow(
                  'Student ID',
                  studentId == 0
                      ? 'Not available'
                      : studentId.toString(),
                ),
                _detailRow(
                  'User ID',
                  userId == 0
                      ? 'Not available'
                      : userId.toString(),
                ),
                _detailRow(
                  'Roll Number',
                  rollNo,
                ),
                _detailRow(
                  'Email',
                  email,
                ),
                _detailRow(
                  'Phone',
                  phone,
                ),
                _detailRow(
                  'Course',
                  getCourseName(courseId),
                ),
                _detailRow(
                  'Department',
                  getDepartmentName(
                    departmentId,
                  ),
                ),
                _detailRow(
                  'Semester',
                  semester == 0
                      ? 'Not available'
                      : 'Semester $semester',
                ),
                _detailRow(
                  'Address',
                  address,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                showEditStudentDialog(student);
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(value),
        ],
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
            ),
            const SizedBox(height: 14),
            Text(
              errorMessage ??
                  'Unable to load students.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: loadStudents,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget buildEmpty() {
    return RefreshIndicator(
      onRefresh: loadStudents,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          const Icon(
            Icons.school_outlined,
            size: 70,
          ),
          const SizedBox(height: 18),
          const Text(
            'No students found.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: FilledButton.icon(
              onPressed: isSaving
                  ? null
                  : showAddStudentDialog,
              icon: const Icon(Icons.add),
              label: const Text(
                'Add Student',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STUDENT LIST
  // ============================================================

  Widget buildStudentList() {
    final list = filteredStudents;

    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadStudents,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 100),
            Icon(
              Icons.search_off,
              size: 60,
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'No students match your search.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadStudents,
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          12,
          8,
          12,
          100,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final student = list[index];

          final name = getStringValue(
            student,
            ['name'],
            defaultValue: 'Student',
          );

          final rollNo = getStringValue(
            student,
            ['roll_no'],
            defaultValue: 'No roll number',
          );

          final courseId = getIntValue(
            student,
            ['course_id'],
          );

          final departmentId = getIntValue(
            student,
            ['department_id'],
          );

          final semester = getIntValue(
            student,
            ['semester'],
          );

          return Card(
            margin: const EdgeInsets.only(
              bottom: 10,
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding:
                    const EdgeInsets.only(top: 5),
                child: Text(
                  '$rollNo\n'
                  '${getCourseName(courseId)}'
                  '${semester != 0 ? ' • Semester $semester' : ''}\n'
                  '${getDepartmentName(departmentId)}',
                ),
              ),
              isThreeLine: true,
              onTap: () {
                showStudentDetails(student);
              },
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'view') {
                    showStudentDetails(student);
                  } else if (value == 'edit') {
                    showEditStudentDialog(student);
                  } else if (value == 'delete') {
                    confirmDeleteStudent(student);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'view',
                    child: ListTile(
                      leading: Icon(
                        Icons.visibility,
                      ),
                      title: Text('View'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      title: Text('Delete'),
                    ),
                  ),
                ],
              ),
            ),
          );
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
        title: const Text(
          'Student Management',
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                isLoading ? null : loadStudents,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      // IMPORTANT:
      // This button is always available after
      // the initial data load, including when
      // there are ZERO students.
      floatingActionButton:
          !isLoading && errorMessage == null
              ? FloatingActionButton.extended(
                  onPressed: isSaving
                      ? null
                      : showAddStudentDialog,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Add Student',
                  ),
                )
              : null,

      body: isLoading
          ? buildLoading()
          : errorMessage != null
              ? buildError()
              : Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(
                        12,
                        12,
                        12,
                        4,
                      ),
                      child: TextField(
                        decoration:
                            InputDecoration(
                          hintText:
                              'Search students...',
                          prefixIcon:
                              const Icon(
                            Icons.search,
                          ),
                          suffixIcon:
                              searchQuery
                                      .isNotEmpty
                                  ? IconButton(
                                      onPressed:
                                          () {
                                        setState(() {
                                          searchQuery =
                                              '';
                                        });
                                      },
                                      icon:
                                          const Icon(
                                        Icons.clear,
                                      ),
                                    )
                                  : null,
                          border:
                              const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery =
                                value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Align(
                        alignment:
                            Alignment.centerLeft,
                        child: Text(
                          '${filteredStudents.length} student(s)',
                          style: TextStyle(
                            color:
                                Colors.grey.shade700,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: students.isEmpty
                          ? buildEmpty()
                          : buildStudentList(),
                    ),
                  ],
                ),
    );
  }
}

// ================================================================
// STUDENT FORM DIALOG
// ================================================================

class StudentFormDialog extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? student;
  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> departments;

  final Future<void> Function(
    Map<String, dynamic> data,
  ) onSubmit;

  const StudentFormDialog({
    super.key,
    required this.title,
    required this.courses,
    required this.departments,
    required this.onSubmit,
    this.student,
  });

  @override
  State<StudentFormDialog> createState() =>
      _StudentFormDialogState();
}

class _StudentFormDialogState
    extends State<StudentFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController userIdController;
  late final TextEditingController rollNoController;
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController semesterController;
  late final TextEditingController addressController;

  int? selectedDepartmentId;
  int? selectedCourseId;

  bool submitting = false;

  @override
  void initState() {
    super.initState();

    final student = widget.student;

    userIdController = TextEditingController(
      text: _getValue(
        student,
        ['user_id'],
      ),
    );

    rollNoController = TextEditingController(
      text: _getValue(
        student,
        ['roll_no'],
      ),
    );

    nameController = TextEditingController(
      text: _getValue(
        student,
        ['name'],
      ),
    );

    emailController = TextEditingController(
      text: _getValue(
        student,
        ['email'],
      ),
    );

    phoneController = TextEditingController(
      text: _getValue(
        student,
        ['phone'],
      ),
    );

    semesterController = TextEditingController(
      text: _getValue(
        student,
        ['semester'],
      ),
    );

    addressController = TextEditingController(
      text: _getValue(
        student,
        ['address'],
      ),
    );

    selectedDepartmentId = _getIntValue(
      student,
      ['department_id'],
    );

    selectedCourseId = _getIntValue(
      student,
      ['course_id'],
    );

    if (!_departmentExists(
      selectedDepartmentId,
    )) {
      selectedDepartmentId = null;
    }

    if (!_courseExists(
      selectedCourseId,
    )) {
      selectedCourseId = null;
    }
  }

  String _getValue(
    Map<String, dynamic>? data,
    List<String> keys,
  ) {
    if (data == null) return '';

    for (final key in keys) {
      final value = data[key];

      if (value != null) {
        return value.toString();
      }
    }

    return '';
  }

  int? _getIntValue(
    Map<String, dynamic>? data,
    List<String> keys,
  ) {
    if (data == null) return null;

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

    return null;
  }

  int _getListInt(
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

  String _getListString(
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

  bool _departmentExists(int? id) {
    if (id == null) return false;

    return widget.departments.any(
      (department) =>
          _getListInt(
            department,
            ['department_id', 'id'],
          ) ==
          id,
    );
  }

  bool _courseExists(int? id) {
    if (id == null) return false;

    return widget.courses.any(
      (course) =>
          _getListInt(
            course,
            ['course_id', 'id'],
          ) ==
          id,
    );
  }

  @override
  void dispose() {
    userIdController.dispose();
    rollNoController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    semesterController.dispose();
    addressController.dispose();

    super.dispose();
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> submit() async {
    if (submitting) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedDepartmentId == null) {
      _showError(
        'Please select a department.',
      );
      return;
    }

    if (selectedCourseId == null) {
      _showError(
        'Please select a course.',
      );
      return;
    }

    final userId = int.tryParse(
      userIdController.text.trim(),
    );

    final semester = int.tryParse(
      semesterController.text.trim(),
    );

    if (userId == null) {
      _showError(
        'User ID must be a valid number.',
      );
      return;
    }

    if (semester == null ||
        semester < 1 ||
        semester > 12) {
      _showError(
        'Semester must be between 1 and 12.',
      );
      return;
    }

    final data = <String, dynamic>{
      'user_id': userId,
      'roll_no':
          rollNoController.text.trim(),
      'name':
          nameController.text.trim(),
      'email':
          emailController.text.trim(),
      'phone':
          phoneController.text.trim().isEmpty
              ? null
              : phoneController.text.trim(),
      'department_id':
          selectedDepartmentId,
      'course_id':
          selectedCourseId,
      'semester':
          semester,
      'address':
          addressController.text.trim().isEmpty
              ? null
              : addressController.text.trim(),
    };

    setState(() {
      submitting = true;
    });

    try {
      await widget.onSubmit(data);

      // The parent closes the dialog
      // after successful API operation.
    } catch (e) {
      if (!mounted) return;

      setState(() {
        submitting = false;
      });

      _showError(
        'Operation failed.\n$e',
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // DECORATION
  // ============================================================

  InputDecoration _decoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
    );
  }

  // ============================================================
  // BUILD FORM
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // USER ID
                TextFormField(
                  controller: userIdController,
                  keyboardType:
                      TextInputType.number,
                  enabled: !submitting,
                  decoration: _decoration(
                    'User ID',
                    Icons.person_outline,
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter User ID';
                    }

                    if (int.tryParse(
                          value.trim(),
                        ) ==
                        null) {
                      return 'Enter a valid User ID';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // ROLL NUMBER
                TextFormField(
                  controller:
                      rollNoController,
                  enabled: !submitting,
                  decoration: _decoration(
                    'Roll Number',
                    Icons.badge_outlined,
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter roll number';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // NAME
                TextFormField(
                  controller:
                      nameController,
                  enabled: !submitting,
                  textCapitalization:
                      TextCapitalization.words,
                  decoration: _decoration(
                    'Student Name',
                    Icons.person,
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter student name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // EMAIL
                TextFormField(
                  controller:
                      emailController,
                  enabled: !submitting,
                  keyboardType:
                      TextInputType.emailAddress,
                  decoration: _decoration(
                    'Email',
                    Icons.email_outlined,
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter email';
                    }

                    if (!value.contains('@')) {
                      return 'Enter a valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // PHONE
                TextFormField(
                  controller:
                      phoneController,
                  enabled: !submitting,
                  keyboardType:
                      TextInputType.phone,
                  decoration: _decoration(
                    'Phone',
                    Icons.phone_outlined,
                  ),
                ),

                const SizedBox(height: 12),

                // DEPARTMENT
                DropdownButtonFormField<int>(
                  initialValue: selectedDepartmentId,
                  decoration: _decoration(
                    'Department',
                    Icons
                        .account_balance_outlined,
                  ),
                  items:
                      widget.departments.map(
                    (department) {
                      final id = _getListInt(
                        department,
                        [
                          'department_id',
                          'id',
                        ],
                      );

                      final name =
                          _getListString(
                        department,
                        [
                          'department_name',
                          'name',
                          'title',
                        ],
                        fallback:
                            'Department $id',
                      );

                      return DropdownMenuItem<
                          int>(
                        value: id,
                        child: Text(name),
                      );
                    },
                  ).toList(),
                  onChanged: submitting
                      ? null
                      : (value) {
                          setState(() {
                            selectedDepartmentId =
                                value;
                          });
                        },
                  validator: (value) {
                    if (value == null) {
                      return 'Select department';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // COURSE
                DropdownButtonFormField<int>(
                  initialValue:selectedCourseId,
                  decoration: _decoration(
                    'Course',
                    Icons
                        .menu_book_outlined,
                  ),
                  items:
                      widget.courses.map(
                    (course) {
                      final id = _getListInt(
                        course,
                        [
                          'course_id',
                          'id',
                        ],
                      );

                      final name =
                          _getListString(
                        course,
                        [
                          'course_name',
                          'name',
                          'title',
                        ],
                        fallback:
                            'Course $id',
                      );

                      return DropdownMenuItem<
                          int>(
                        value: id,
                        child: Text(name),
                      );
                    },
                  ).toList(),
                  onChanged: submitting
                      ? null
                      : (value) {
                          setState(() {
                            selectedCourseId =
                                value;
                          });
                        },
                  validator: (value) {
                    if (value == null) {
                      return 'Select course';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // SEMESTER
                TextFormField(
                  controller:
                      semesterController,
                  enabled: !submitting,
                  keyboardType:
                      TextInputType.number,
                  decoration: _decoration(
                    'Semester',
                    Icons.school_outlined,
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter semester';
                    }

                    final semester =
                        int.tryParse(
                      value.trim(),
                    );

                    if (semester == null) {
                      return 'Enter a valid semester';
                    }

                    if (semester < 1 ||
                        semester > 12) {
                      return 'Semester must be 1-12';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // ADDRESS
                TextFormField(
                  controller:
                      addressController,
                  enabled: !submitting,
                  maxLines: 3,
                  textCapitalization:
                      TextCapitalization.sentences,
                  decoration: _decoration(
                    'Address',
                    Icons
                        .location_on_outlined,
                  ),
                ),

                if (submitting) ...[
                  const SizedBox(height: 20),
                  const LinearProgressIndicator(),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: submitting
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed:
              submitting ? null : submit,
          icon: submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.save),
          label: Text(
            submitting
                ? 'Saving...'
                : 'Save',
          ),
        ),
      ],
    );
  }
}