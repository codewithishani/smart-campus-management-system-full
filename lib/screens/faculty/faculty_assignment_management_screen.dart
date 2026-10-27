import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'faculty_dashboard.dart';

class FacultyAssignmentManagementScreen extends StatefulWidget {
  const FacultyAssignmentManagementScreen({
    super.key,
  });

  @override
  State<FacultyAssignmentManagementScreen> createState() =>
      _FacultyAssignmentManagementScreenState();
}

class _FacultyAssignmentManagementScreenState
    extends State<FacultyAssignmentManagementScreen> {
  List<dynamic> assignments = [];
  List<dynamic> subjects = [];
  List<dynamic> students = [];
  List<dynamic> classes = [];

  List<Map<String, dynamic>> facultyClasses = [];
  List<Map<String, dynamic>> facultySubjects = [];

  bool isLoading = true;
  String? errorMessage;

  int? get facultyId => FacultyDashboard.currentFacultyId;

  @override
  void initState() {
    super.initState();
    loadAssignmentData();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> loadAssignmentData() async {
    try {
      final results = await Future.wait([
        ApiService.getAssignments(),
        ApiService.getSubjects(),
        ApiService.getStudents(),
        ApiService.getClasses(),
      ]);

      final assignmentData = results[0];
      final subjectData = results[1];
      final studentData = results[2];
      final classData = results[3];

      if (!mounted) return;

      final normalizedAssignments = assignmentData
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();

      final normalizedSubjects = subjectData
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();

      final normalizedStudents = studentData
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();

      final normalizedClasses = classData
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();

      final loadedFacultyClasses =
          <Map<String, dynamic>>[];

      if (facultyId != null) {
        final assignmentClassIds = normalizedAssignments
            .where(
              (assignment) =>
                  getAssignmentFacultyId(assignment) ==
                  facultyId,
            )
            .map(
              (assignment) =>
                  getNullableIntValue(
                assignment,
                ['class_id'],
              ),
            )
            .whereType<int>()
            .toSet();

        for (final classItem in normalizedClasses) {
          final classId = getClassId(classItem);
          final classTeacherId =
              getClassFacultyId(classItem);

          if (classTeacherId == facultyId ||
              (classId != null &&
                  assignmentClassIds.contains(classId))) {
            loadedFacultyClasses.add(classItem);
          }
        }
      }

      final classIds = loadedFacultyClasses
          .map(getClassId)
          .whereType<int>()
          .toSet();

      final courseIds = loadedFacultyClasses
          .map(getCourseId)
          .whereType<int>()
          .toSet();

      final facultyAssignmentSubjectIds =
          normalizedAssignments
              .where(
                (assignment) =>
                    getAssignmentFacultyId(assignment) ==
                    facultyId,
              )
              .map(getSubjectId)
              .where((id) => id != 0)
              .toSet();

      final loadedFacultySubjects =
          <Map<String, dynamic>>[];

      for (final subject in normalizedSubjects) {
        final subjectId =
            getSubjectIdFromSubject(subject);
        final subjectClassId =
            getSubjectClassId(subject);
        final subjectCourseId =
            getSubjectCourseId(subject);

        bool matches = false;

        if (facultyAssignmentSubjectIds
            .contains(subjectId)) {
          matches = true;
        }

        if (!matches &&
            subjectClassId != null &&
            classIds.contains(subjectClassId)) {
          matches = true;
        }

        if (!matches &&
            subjectCourseId != null &&
            courseIds.contains(subjectCourseId)) {
          matches = true;
        }

        if (matches) {
          loadedFacultySubjects.add(subject);
        }
      }

      if (!mounted) return;

      setState(() {
        assignments = normalizedAssignments;
        subjects = normalizedSubjects;
        students = normalizedStudents;
        classes = normalizedClasses;
        facultyClasses = loadedFacultyClasses;
        facultySubjects = loadedFacultySubjects;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load assignments.';
      });
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  int? parseId(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();

    return int.tryParse(
      value?.toString().trim() ?? '',
    );
  }

  int getIntValue(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = parseId(data[key]);

      if (value != null) {
        return value;
      }
    }

    return 0;
  }

  int? getNullableIntValue(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = parseId(data[key]);

      if (value != null) {
        return value;
      }
    }

    return null;
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

  int? getClassId(
    Map<String, dynamic> data,
  ) {
    return getNullableIntValue(
      data,
      ['class_id', 'id'],
    );
  }

  int? getCourseId(
    Map<String, dynamic> data,
  ) {
    return getNullableIntValue(
      data,
      ['course_id', 'courseId'],
    );
  }

  int? getClassFacultyId(
    Map<String, dynamic> data,
  ) {
    return getNullableIntValue(
      data,
      [
        'class_teacher_id',
        'faculty_id',
        'teacher_id',
        'assigned_faculty_id',
      ],
    );
  }

  int? getSubjectClassId(
    Map<String, dynamic> data,
  ) {
    return getNullableIntValue(
      data,
      ['class_id', 'classId'],
    );
  }

  int? getSubjectCourseId(
    Map<String, dynamic> data,
  ) {
    return getNullableIntValue(
      data,
      ['course_id', 'courseId'],
    );
  }

  int getSubjectIdFromSubject(
    Map<String, dynamic> subject,
  ) {
    return getIntValue(
      subject,
      ['subject_id', 'id'],
    );
  }

  int getSubjectId(
    Map<String, dynamic> assignment,
  ) {
    return getIntValue(
      assignment,
      ['subject_id'],
    );
  }

  int? getAssignmentFacultyId(
    Map<String, dynamic> assignment,
  ) {
    return getNullableIntValue(
      assignment,
      [
        'faculty_id',
        'teacher_id',
        'created_by',
        'assigned_to',
      ],
    );
  }

  int? getAssignmentId(
    Map<String, dynamic> assignment,
  ) {
    return getNullableIntValue(
      assignment,
      ['assignment_id', 'id'],
    );
  }

  String getAssignmentTitle(
    Map<String, dynamic> assignment,
  ) {
    return getStringValue(
      assignment,
      [
        'title',
        'assignment_title',
        'name',
      ],
      defaultValue: 'Assignment',
    );
  }

  String getAssignmentDescription(
    Map<String, dynamic> assignment,
  ) {
    return getStringValue(
      assignment,
      [
        'description',
        'details',
        'instructions',
      ],
    );
  }

  String getSubjectNameById(int subjectId) {
    for (final subject in facultySubjects) {
      final id = getSubjectIdFromSubject(subject);

      if (id == subjectId) {
        return getStringValue(
          subject,
          [
            'subject_name',
            'name',
            'subject_code',
          ],
          defaultValue: 'Subject',
        );
      }
    }

    return 'Subject';
  }

  String getSubjectCodeById(int subjectId) {
    for (final subject in facultySubjects) {
      final id = getSubjectIdFromSubject(subject);

      if (id == subjectId) {
        return getStringValue(
          subject,
          ['subject_code'],
        );
      }
    }

    return '';
  }

  String getClassNameById(int classId) {
    for (final classItem in facultyClasses) {
      final id = getClassId(classItem);

      if (id == classId) {
        return getStringValue(
          classItem,
          [
            'class_name',
            'name',
            'class_code',
          ],
          defaultValue: 'Class',
        );
      }
    }

    return 'Class';
  }

  String getDueDate(
    Map<String, dynamic> assignment,
  ) {
    final value = getStringValue(
      assignment,
      [
        'due_date',
        'deadline',
        'submission_date',
      ],
    );

    if (value.isEmpty) {
      return 'Not specified';
    }

    try {
      final date = DateTime.parse(value);

      return '${date.day.toString().padLeft(2, '0')} '
          '${_monthName(date.month)} '
          '${date.year}';
    } catch (_) {
      return value;
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    if (month < 1 || month > 12) {
      return '';
    }

    return months[month - 1];
  }

  int? getStudentClassId(
    Map<String, dynamic> student,
  ) {
    return getNullableIntValue(
      student,
      ['class_id', 'classId'],
    );
  }

  int? getStudentCourseId(
    Map<String, dynamic> student,
  ) {
    return getNullableIntValue(
      student,
      ['course_id', 'courseId'],
    );
  }

  int getAssignmentStudentCount(
    Map<String, dynamic> assignment,
  ) {
    final directCount = getIntValue(
      assignment,
      [
        'student_count',
        'students_count',
        'total_students',
      ],
    );

    if (directCount > 0) {
      return directCount;
    }

    final assignmentClassId =
        getNullableIntValue(
      assignment,
      ['class_id'],
    );

    final assignmentCourseId =
        getNullableIntValue(
      assignment,
      ['course_id'],
    );

    return students.where((item) {
      if (item is! Map) {
        return false;
      }

      final student =
          Map<String, dynamic>.from(item);

      final studentClassId =
          getStudentClassId(student);

      final studentCourseId =
          getStudentCourseId(student);

      if (assignmentClassId != null) {
        return studentClassId == assignmentClassId;
      }

      if (assignmentCourseId != null) {
        return studentCourseId == assignmentCourseId;
      }

      return false;
    }).length;
  }

  bool assignmentMatchesFaculty(
    Map<String, dynamic> assignment,
  ) {
    if (facultyId == null) {
      return false;
    }

    final assignmentFacultyId =
        getAssignmentFacultyId(assignment);

    if (assignmentFacultyId != null) {
      return assignmentFacultyId == facultyId;
    }

    final assignmentClassId =
        getNullableIntValue(
      assignment,
      ['class_id'],
    );

    if (assignmentClassId != null) {
      final facultyClassIds = facultyClasses
          .map(getClassId)
          .whereType<int>()
          .toSet();

      return facultyClassIds.contains(
        assignmentClassId,
      );
    }

    return false;
  }

  List<Map<String, dynamic>>
      getFilteredAssignments() {
    final result = assignments
        .whereType<Map>()
        .map(
          (item) =>
              Map<String, dynamic>.from(item),
        )
        .where(assignmentMatchesFaculty)
        .toList();

    result.sort((a, b) {
      final aDate = getStringValue(
        a,
        [
          'due_date',
          'deadline',
          'submission_date',
        ],
      );

      final bDate = getStringValue(
        b,
        [
          'due_date',
          'deadline',
          'submission_date',
        ],
      );

      return aDate.compareTo(bDate);
    });

    return result;
  }

  // ============================================================
  // CREATE / EDIT ASSIGNMENT
  // ============================================================

  Future<void> showAssignmentForm({
    Map<String, dynamic>? existingAssignment,
  }) async {
    if (facultyId == null) {
      showMessage(
        'Faculty session not found.',
        isError: true,
      );
      return;
    }

    if (facultyClasses.isEmpty) {
      showMessage(
        'No classes are assigned to this faculty.',
        isError: true,
      );
      return;
    }

    if (facultySubjects.isEmpty) {
      showMessage(
        'No subjects are assigned to this faculty.',
        isError: true,
      );
      return;
    }

    final isEditing = existingAssignment != null;

    final titleController = TextEditingController(
      text: isEditing
          ? getAssignmentTitle(
              existingAssignment,
            )
          : '',
    );

    final descriptionController =
        TextEditingController(
      text: isEditing
          ? getAssignmentDescription(
              existingAssignment,
            )
          : '',
    );

    int? selectedSubjectId = isEditing
        ? getNullableIntValue(
            existingAssignment,
            ['subject_id'],
          )
        : null;

    int? selectedClassId = isEditing
        ? getNullableIntValue(
            existingAssignment,
            ['class_id'],
          )
        : null;

    DateTime? selectedDueDate;

    if (isEditing) {
      final existingDate = getStringValue(
        existingAssignment,
        ['due_date'],
      );

      try {
        selectedDueDate =
            DateTime.parse(existingDate);
      } catch (_) {
        selectedDueDate = null;
      }
    }

    if (!facultySubjects.any(
      (subject) =>
          getSubjectIdFromSubject(subject) ==
          selectedSubjectId,
    )) {
      selectedSubjectId = null;
    }

    if (!facultyClasses.any(
      (classItem) =>
          getClassId(classItem) ==
          selectedClassId,
    )) {
      selectedClassId = null;
    }

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: Text(
                isEditing
                    ? 'Edit Assignment'
                    : 'Create Assignment',
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<int>(
                         initialValue:selectedSubjectId,
                          decoration:
                              const InputDecoration(
                            labelText: 'Subject',
                            border:
                                OutlineInputBorder(),
                          ),
                          items: facultySubjects
                              .map(
                                (subject) {
                                  final id =
                                      getSubjectIdFromSubject(
                                    subject,
                                  );

                                  final name =
                                      getStringValue(
                                    subject,
                                    [
                                      'subject_name',
                                      'name',
                                      'subject_code',
                                    ],
                                    defaultValue:
                                        'Subject',
                                  );

                                  final code =
                                      getStringValue(
                                    subject,
                                    [
                                      'subject_code',
                                    ],
                                  );

                                  return DropdownMenuItem<
                                      int>(
                                    value: id,
                                    child: Text(
                                      code.isEmpty
                                          ? name
                                          : '$name ($code)',
                                    ),
                                  );
                                },
                              )
                              .toList(),
                          onChanged: saving
                              ? null
                              : (value) {
                                  setDialogState(() {
                                    selectedSubjectId =
                                        value;
                                  });
                                },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a subject';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          initialValue: selectedClassId,
                          decoration:
                              const InputDecoration(
                            labelText: 'Assign to Class',
                            border:
                                OutlineInputBorder(),
                          ),
                          items: facultyClasses
                              .map(
                                (classItem) {
                                  final id =
                                      getClassId(
                                    classItem,
                                  );

                                  final name =
                                      getStringValue(
                                    classItem,
                                    [
                                      'class_name',
                                      'name',
                                      'class_code',
                                    ],
                                    defaultValue:
                                        'Class',
                                  );

                                  return DropdownMenuItem<
                                      int>(
                                    value: id,
                                    child: Text(name),
                                  );
                                },
                              )
                              .toList(),
                          onChanged: saving
                              ? null
                              : (value) {
                                  setDialogState(() {
                                    selectedClassId =
                                        value;
                                  });
                                },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a class';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: titleController,
                          enabled: !saving,
                          decoration:
                              const InputDecoration(
                            labelText: 'Assignment Title',
                            hintText:
                                'Enter assignment title',
                            border:
                                OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller:
                              descriptionController,
                          enabled: !saving,
                          maxLines: 4,
                          decoration:
                              const InputDecoration(
                            labelText: 'Description',
                            hintText:
                                'Enter assignment instructions',
                            border:
                                OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: saving
                              ? null
                              : () async {
                                  final now =
                                      DateTime.now();

                                  final picked =
                                      await showDatePicker(
                                    context: context,
                                    initialDate:
                                        selectedDueDate ??
                                            now,
                                    firstDate: now,
                                    lastDate:
                                        DateTime(
                                      now.year + 5,
                                    ),
                                  );

                                  if (picked != null) {
                                    setDialogState(() {
                                      selectedDueDate =
                                          picked;
                                    });
                                  }
                                },
                          child: InputDecorator(
                            decoration:
                                const InputDecoration(
                              labelText: 'Due Date',
                              border:
                                  OutlineInputBorder(),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons
                                      .calendar_today_outlined,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(
                                    selectedDueDate ==
                                            null
                                        ? 'Select due date'
                                        : '${selectedDueDate!.day.toString().padLeft(2, '0')}/'
                                            '${selectedDueDate!.month.toString().padLeft(2, '0')}/'
                                            '${selectedDueDate!.year}',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (selectedDueDate == null)
                          const Align(
                            alignment:
                                Alignment.centerLeft,
                            child: Text(
                              'Due date is required',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () {
                          Navigator.pop(
                            dialogContext,
                            false,
                          );
                        },
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: saving
                      ? null
                      : () async {
                          if (!formKey.currentState!
                              .validate()) {
                            return;
                          }

                          if (selectedDueDate ==
                              null) {
                            showDialogMessage(
                              dialogContext,
                              'Please select a due date.',
                            );
                            return;
                          }

                          setDialogState(() {
                            saving = true;
                          });

                          try {
                            final dueDate =
                                '${selectedDueDate!.year.toString().padLeft(4, '0')}-'
                                '${selectedDueDate!.month.toString().padLeft(2, '0')}-'
                                '${selectedDueDate!.day.toString().padLeft(2, '0')}';

                            if (isEditing) {
                              final assignmentId =
                                  getAssignmentId(
                                existingAssignment,
                              );

                              if (assignmentId ==
                                  null) {
                                throw Exception(
                                  'Assignment ID not found.',
                                );
                              }

                              await ApiService
                                  .updateAssignment(
                                assignmentId:
                                    assignmentId,
                                facultyId: facultyId!,
                                subjectId:
                                    selectedSubjectId!,
                                classId:
                                    selectedClassId!,
                                title:
                                    titleController
                                        .text
                                        .trim(),
                                description:
                                    descriptionController
                                        .text
                                        .trim()
                                        .isEmpty
                                    ? null
                                    : descriptionController
                                        .text
                                        .trim(),
                                dueDate: dueDate,
                              );
                            } else {
                              await ApiService
                                  .createAssignment(
                                facultyId: facultyId!,
                                subjectId:
                                    selectedSubjectId!,
                                classId:
                                    selectedClassId!,
                                title:
                                    titleController
                                        .text
                                        .trim(),
                                description:
                                    descriptionController
                                        .text
                                        .trim()
                                        .isEmpty
                                    ? null
                                    : descriptionController
                                        .text
                                        .trim(),
                                dueDate: dueDate,
                              );
                            }

                            if (!dialogContext
                                .mounted) {
                              return;
                            }

                            Navigator.pop(
                              dialogContext,
                              true,
                            );
                          } catch (e) {
                            if (!dialogContext
                                .mounted) {
                              return;
                            }

                            setDialogState(() {
                              saving = false;
                            });

                            showDialogMessage(
                              dialogContext,
                              e
                                  .toString()
                                  .replaceFirst(
                                    'Exception: ',
                                    '',
                                  ),
                            );
                          }
                        },
                  icon: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          isEditing
                              ? Icons.save_outlined
                              : Icons.add,
                        ),
                  label: Text(
                    isEditing
                        ? 'Save Changes'
                        : 'Create',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();

    if (result == true && mounted) {
      await loadAssignmentData();

      showMessage(
        isEditing
            ? 'Assignment updated successfully.'
            : 'Assignment created and assigned successfully.',
      );
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteAssignment(
    Map<String, dynamic> assignment,
  ) async {
    final assignmentId =
        getAssignmentId(assignment);

    if (assignmentId == null) {
      showMessage(
        'Assignment ID not found.',
        isError: true,
      );
      return;
    }

    final title = getAssignmentTitle(
      assignment,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Assignment?',
          ),
          content: Text(
            'Are you sure you want to delete "$title"?',
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
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ApiService.deleteAssignment(
        assignmentId,
      );

      if (!mounted) return;

      await loadAssignmentData();

      if (!mounted) return;

      showMessage(
        'Assignment deleted successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      showMessage(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        isError: true,
      );
    }
  }

  // ============================================================
  // DETAILS
  // ============================================================

  void showAssignmentDetails(
    Map<String, dynamic> assignment,
  ) {
    final title =
        getAssignmentTitle(assignment);

    final description =
        getAssignmentDescription(assignment);

    final subjectId =
        getSubjectId(assignment);

    final directSubject =
        getStringValue(
      assignment,
      [
        'subject_name',
        'subject',
      ],
    );

    final subject = directSubject.isNotEmpty
        ? directSubject
        : getSubjectNameById(subjectId);

    final dueDate =
        getDueDate(assignment);

    final studentsCount =
        getAssignmentStudentCount(
      assignment,
    );

    final assignmentClassId =
        getNullableIntValue(
      assignment,
      ['class_id'],
    );

    final className =
        assignmentClassId != null
            ? getClassNameById(
                assignmentClassId,
              )
            : 'Assigned class';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ListTile(
                    contentPadding:
                        EdgeInsets.zero,
                    leading: const Icon(
                      Icons.book_outlined,
                    ),
                    title: const Text('Subject'),
                    subtitle: Text(subject),
                  ),
                  ListTile(
                    contentPadding:
                        EdgeInsets.zero,
                    leading: const Icon(
                      Icons.class_outlined,
                    ),
                    title: const Text('Assigned Class'),
                    subtitle: Text(className),
                  ),
                  ListTile(
                    contentPadding:
                        EdgeInsets.zero,
                    leading: const Icon(
                      Icons.calendar_today_outlined,
                    ),
                    title: const Text('Due Date'),
                    subtitle: Text(dueDate),
                  ),
                  ListTile(
                    contentPadding:
                        EdgeInsets.zero,
                    leading: const Icon(
                      Icons.people_outline,
                    ),
                    title: const Text('Students'),
                    subtitle: Text(
                      studentsCount > 0
                          ? '$studentsCount students'
                          : 'Student count not available',
                    ),
                  ),
                  if (description.isNotEmpty)
                    Padding(
                      padding:
                          const EdgeInsets.only(
                        top: 8,
                      ),
                      child: Text(description),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(
                              sheetContext,
                            );
                            showAssignmentForm(
                              existingAssignment:
                                  assignment,
                            );
                          },
                          icon: const Icon(
                            Icons.edit_outlined,
                          ),
                          label: const Text('Edit'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(
                              sheetContext,
                            );
                            deleteAssignment(
                              assignment,
                            );
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                          ),
                          label: const Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(
                          sheetContext,
                        );
                      },
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // UI HELPERS
  // ============================================================

  void showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void showDialogMessage(
    BuildContext context,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Validation'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // LOADING / ERROR
  // ============================================================

  Widget buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 55,
            ),
            const SizedBox(height: 14),
            Text(
              errorMessage ??
                  'Unable to load assignments.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });

                loadAssignmentData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNoSessionState() {
    return RefreshIndicator(
      onRefresh: loadAssignmentData,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 150),
          Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: 60,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Faculty session not found.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please login again to view your assignments.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ASSIGNMENT CARD
  // ============================================================

  Widget buildAssignmentCard(
    Map<String, dynamic> assignment,
  ) {
    final title =
        getAssignmentTitle(assignment);

    final description =
        getAssignmentDescription(assignment);

    final subjectId =
        getSubjectId(assignment);

    final directSubjectName =
        getStringValue(
      assignment,
      [
        'subject_name',
        'subject',
      ],
    );

    final resolvedSubject =
        directSubjectName.isNotEmpty
            ? directSubjectName
            : getSubjectNameById(subjectId);

    final subjectCode =
        getSubjectCodeById(subjectId);

    final dueDate =
        getDueDate(assignment);

    final studentCount =
        getAssignmentStudentCount(
      assignment,
    );

    final assignmentClassId =
        getNullableIntValue(
      assignment,
      ['class_id'],
    );

    final className =
        assignmentClassId != null
            ? getClassNameById(
                assignmentClassId,
              )
            : 'Assigned class';

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            ListTile(
              contentPadding:
                  EdgeInsets.zero,
              leading: const CircleAvatar(
                child: Icon(
                  Icons.assignment_outlined,
                ),
              ),
              title: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
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
                      subjectCode.isEmpty
                          ? resolvedSubject
                          : '$resolvedSubject ($subjectCode)',
                    ),
                    Text(
                      'Class: $className',
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Due: $dueDate',
                    ),
                    Text(
                      studentCount > 0
                          ? 'Students: $studentCount'
                          : 'Students: Not available',
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              onTap: () {
                showAssignmentDetails(
                  assignment,
                );
              },
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showAssignmentForm(
                        existingAssignment:
                            assignment,
                      );
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      deleteAssignment(
                        assignment,
                      );
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                    ),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget buildBody() {
    if (isLoading) {
      return buildLoadingState();
    }

    if (errorMessage != null) {
      return buildErrorState();
    }

    if (facultyId == null) {
      return buildNoSessionState();
    }

    final filteredAssignments =
        getFilteredAssignments();

    return RefreshIndicator(
      onRefresh: loadAssignmentData,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        child: Icon(
                          Icons.assignment,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Assignment Management',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${filteredAssignments.length} assignment(s) assigned to you',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showAssignmentForm();
                      },
                      icon: const Icon(
                        Icons.add,
                      ),
                      label: const Text(
                        'Create Assignment',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (filteredAssignments.isEmpty)
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(28),
                child: Column(
                  children: [
                    const Icon(
                      Icons.assignment_outlined,
                      size: 65,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'No assignments found.',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create a new assignment using the button above.',
                      textAlign:
                          TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        showAssignmentForm();
                      },
                      icon: const Icon(
                        Icons.add,
                      ),
                      label: const Text(
                        'Create Assignment',
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...filteredAssignments.map(
              buildAssignmentCard,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assignment Management',
        ),
      ),
      body: buildBody(),
    );
  }
}