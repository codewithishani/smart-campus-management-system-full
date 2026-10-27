
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'faculty_dashboard.dart';

class FacultyNotesUploadScreen extends StatefulWidget {
  const FacultyNotesUploadScreen({super.key});

  @override
  State<FacultyNotesUploadScreen> createState() =>
      _FacultyNotesUploadScreenState();
}

class _FacultyNotesUploadScreenState
    extends State<FacultyNotesUploadScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController =
      TextEditingController();
  final TextEditingController resourceUrlController =
      TextEditingController();

  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> subjects = [];
  List<Map<String, dynamic>> notes = [];

  int? selectedClassId;
  int? selectedSubjectId;

  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  int? get facultyId => FacultyDashboard.currentFacultyId;

  @override
  void initState() {
    super.initState();
    loadNotesData();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    resourceUrlController.dispose();
    super.dispose();
  }

  int? parseId(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();

    return int.tryParse(
      value?.toString().trim() ?? '',
    );
  }

  int? getId(
    Map<String, dynamic> item,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = parseId(item[key]);

      if (value != null) {
        return value;
      }
    }

    return null;
  }

  int? getClassId(Map<String, dynamic> item) {
    return getId(
      item,
      ['class_id', 'id'],
    );
  }

  int? getCourseId(Map<String, dynamic> item) {
    return getId(
      item,
      ['course_id', 'courseId'],
    );
  }

  int? getClassTeacherId(Map<String, dynamic> item) {
    return getId(
      item,
      [
        'class_teacher_id',
        'classTeacherId',
      ],
    );
  }

  int? getAssignmentFacultyId(Map<String, dynamic> item) {
    return getId(
      item,
      [
        'faculty_id',
        'facultyId',
      ],
    );
  }

  int? getAssignmentClassId(Map<String, dynamic> item) {
    return getId(
      item,
      [
        'class_id',
        'classId',
      ],
    );
  }

  int? getSubjectId(Map<String, dynamic> item) {
    return getId(
      item,
      [
        'subject_id',
        'id',
      ],
    );
  }

  int? getSubjectClassId(Map<String, dynamic> item) {
    return getId(
      item,
      [
        'class_id',
        'classId',
      ],
    );
  }

  int? getSubjectCourseId(Map<String, dynamic> item) {
    return getId(
      item,
      [
        'course_id',
        'courseId',
      ],
    );
  }

  int? getNoteId(Map<String, dynamic> item) {
    return getId(
      item,
      [
        'note_id',
        'id',
      ],
    );
  }

  int? getNoteSubjectId(Map<String, dynamic> item) {
    return getId(
      item,
      [
        'subject_id',
        'subjectId',
      ],
    );
  }

  int? getNoteClassId(Map<String, dynamic> item) {
    return getId(
      item,
      [
        'class_id',
        'classId',
      ],
    );
  }

  String getClassName(Map<String, dynamic> item) {
    return (
      item['class_name'] ??
      item['name'] ??
      item['class_code'] ??
      'Class'
    ).toString();
  }

  String getSubjectName(Map<String, dynamic> item) {
    return (
      item['subject_name'] ??
      item['name'] ??
      item['subject_code'] ??
      'Subject'
    ).toString();
  }

  String getSubjectCode(Map<String, dynamic> item) {
    return (
      item['subject_code'] ??
      ''
    ).toString();
  }

  String getNoteTitle(Map<String, dynamic> item) {
    return (
      item['title'] ??
      'Untitled Note'
    ).toString();
  }

  String getNoteDescription(Map<String, dynamic> item) {
    return (
      item['description'] ??
      ''
    ).toString();
  }

  String getNoteUrl(Map<String, dynamic> item) {
    return (
      item['file_url'] ??
      ''
    ).toString();
  }

  Future<void> loadNotesData() async {
    if (facultyId == null) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Faculty session not found. Please login again.';
      });

      return;
    }

    try {
      final results = await Future.wait([
        ApiService.getClasses(),
        ApiService.getSubjects(),
        ApiService.getAssignments(),
        ApiService.getNotes(),
      ]);

      final classData = results[0];
      final subjectData = results[1];
      final assignmentData = results[2];
      final notesData = results[3];

      if (!mounted) return;

      final facultyClassIds = <int>{};

      final loadedClasses = <Map<String, dynamic>>[];

      for (final item in classData) {
        if (item is! Map) continue;

        final classItem = Map<String, dynamic>.from(item);
        final classId = getClassId(classItem);

        if (classId == null) continue;

        final classTeacherId = getClassTeacherId(classItem);

        if (classTeacherId == facultyId) {
          facultyClassIds.add(classId);
          loadedClasses.add(classItem);
        }
      }

      for (final item in assignmentData) {
        if (item is! Map) continue;

        final assignment = Map<String, dynamic>.from(item);

        if (getAssignmentFacultyId(assignment) != facultyId) {
          continue;
        }

        final classId = getAssignmentClassId(assignment);

        if (classId == null) continue;

        facultyClassIds.add(classId);

        final alreadyAdded = loadedClasses.any(
          (item) => getClassId(item) == classId,
        );

        if (alreadyAdded) continue;

        final matchingClass = classData
            .whereType<Map>()
            .map(
              (item) => Map<String, dynamic>.from(item),
            )
            .where(
              (item) => getClassId(item) == classId,
            )
            .toList();

        if (matchingClass.isNotEmpty) {
          loadedClasses.add(matchingClass.first);
        }
      }

      final facultyCourseIds = loadedClasses
          .map(getCourseId)
          .whereType<int>()
          .toSet();

      final facultyAssignmentSubjectIds = <int>{};

      for (final item in assignmentData) {
        if (item is! Map) continue;

        final assignment = Map<String, dynamic>.from(item);

        if (getAssignmentFacultyId(assignment) != facultyId) {
          continue;
        }

        final subjectId = getSubjectId(assignment);

        if (subjectId != null) {
          facultyAssignmentSubjectIds.add(subjectId);
        }
      }

      final loadedSubjects = <Map<String, dynamic>>[];

      for (final item in subjectData) {
        if (item is! Map) continue;

        final subject = Map<String, dynamic>.from(item);

        final subjectId = getSubjectId(subject);
        final subjectClassId = getSubjectClassId(subject);
        final subjectCourseId = getSubjectCourseId(subject);

        bool matches = false;

        if (subjectId != null &&
            facultyAssignmentSubjectIds.contains(subjectId)) {
          matches = true;
        }

        if (!matches &&
            subjectClassId != null &&
            facultyClassIds.contains(subjectClassId)) {
          matches = true;
        }

        if (!matches &&
            subjectCourseId != null &&
            facultyCourseIds.contains(subjectCourseId)) {
          matches = true;
        }

        if (matches) {
          loadedSubjects.add(subject);
        }
      }

      final facultySubjectIds = loadedSubjects
          .map(getSubjectId)
          .whereType<int>()
          .toSet();

      final loadedNotes = <Map<String, dynamic>>[];

      for (final item in notesData) {
        if (item is! Map) continue;

        final note = Map<String, dynamic>.from(item);

        final noteFacultyId = getId(
          note,
          ['faculty_id', 'facultyId'],
        );

        final noteSubjectId = getNoteSubjectId(note);
        final noteClassId = getNoteClassId(note);

        final belongsToFaculty =
            noteFacultyId == null || noteFacultyId == facultyId;

        final belongsToSubject =
            noteSubjectId != null &&
            facultySubjectIds.contains(noteSubjectId);

        final belongsToClass =
            noteClassId != null &&
            facultyClassIds.contains(noteClassId);

        if (belongsToFaculty &&
            (belongsToSubject || belongsToClass)) {
          loadedNotes.add(note);
        }
      }

      int? newSelectedClassId = selectedClassId;
      int? newSelectedSubjectId = selectedSubjectId;

      if (newSelectedClassId == null ||
          !facultyClassIds.contains(newSelectedClassId)) {
        newSelectedClassId = loadedClasses.isNotEmpty
            ? getClassId(loadedClasses.first)
            : null;
      }

      final subjectsForSelectedClass =
          getSubjectsForClass(
        loadedSubjects,
        newSelectedClassId,
        loadedClasses,
      );

      if (newSelectedSubjectId == null ||
          !subjectsForSelectedClass.any(
            (item) => getSubjectId(item) == newSelectedSubjectId,
          )) {
        newSelectedSubjectId =
            subjectsForSelectedClass.isNotEmpty
                ? getSubjectId(subjectsForSelectedClass.first)
                : null;
      }

      setState(() {
        classes = loadedClasses;
        subjects = loadedSubjects;
        notes = loadedNotes;
        selectedClassId = newSelectedClassId;
        selectedSubjectId = newSelectedSubjectId;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load notes data.';
      });
    }
  }

  List<Map<String, dynamic>> getSubjectsForClass(
    List<Map<String, dynamic>> allSubjects,
    int? classId,
    List<Map<String, dynamic>> allClasses,
  ) {
    if (classId == null) {
      return allSubjects;
    }

    final selectedClass = allClasses.where(
      (item) => getClassId(item) == classId,
    );

    final courseId = selectedClass.isNotEmpty
        ? getCourseId(selectedClass.first)
        : null;

    final result = <Map<String, dynamic>>[];

    for (final subject in allSubjects) {
      final subjectClassId = getSubjectClassId(subject);
      final subjectCourseId = getSubjectCourseId(subject);

      if (subjectClassId == classId) {
        result.add(subject);
        continue;
      }

      if (subjectClassId == null &&
          courseId != null &&
          subjectCourseId == courseId) {
        result.add(subject);
      }
    }

    if (result.isEmpty) {
      return allSubjects;
    }

    return result;
  }

  Future<void> createNote() async {
    if (facultyId == null) {
      showMessage(
        'Faculty session not found. Please login again.',
        isError: true,
      );
      return;
    }

    if (selectedClassId == null) {
      showMessage(
        'Please select a class.',
        isError: true,
      );
      return;
    }

    if (selectedSubjectId == null) {
      showMessage(
        'Please select a subject.',
        isError: true,
      );
      return;
    }

    final title = titleController.text.trim();

    if (title.isEmpty) {
      showMessage(
        'Please enter a resource title.',
        isError: true,
      );
      return;
    }

    final description = descriptionController.text.trim();
    final fileUrl = resourceUrlController.text.trim();

    setState(() {
      isSaving = true;
    });

    try {
      final payload = <String, dynamic>{
        'faculty_id': facultyId,
        'subject_id': selectedSubjectId,
        'class_id': selectedClassId,
        'title': title,
        'description': description.isEmpty
            ? null
            : description,
        'file_url': fileUrl.isEmpty
            ? null
            : fileUrl,
      };

      await ApiService.createNote(payload);

      if (!mounted) return;

      titleController.clear();
      descriptionController.clear();
      resourceUrlController.clear();

      showMessage(
        'Note uploaded successfully.',
      );

      setState(() {
        isSaving = false;
      });

      await loadNotesData();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      showMessage(
        'Unable to upload note.',
        isError: true,
      );
    }
  }

  void showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  Widget buildExistingNotes() {
    if (notes.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.info_outline),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'No notes have been uploaded for your assigned classes yet.',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Existing Resources',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...notes.map(
          (item) {
            final note = Map<String, dynamic>.from(item);

            final title = getNoteTitle(note);
            final description =
                getNoteDescription(note);
            final url = getNoteUrl(note);

            final subjectId =
                getNoteSubjectId(note);

            final classId =
                getNoteClassId(note);

            final subjectName = subjects
                .where(
                  (subject) =>
                      getSubjectId(subject) ==
                      subjectId,
                )
                .map(getSubjectName)
                .firstOrNull;

            final className = classes
                .where(
                  (classItem) =>
                      getClassId(classItem) ==
                      classId,
                )
                .map(getClassName)
                .firstOrNull;

            return Card(
              margin: const EdgeInsets.only(
                bottom: 10,
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(
                    Icons.description_outlined,
                  ),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(
                    top: 5,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      if (className != null)
                        Text(
                          'Class: $className',
                        ),
                      if (subjectName != null)
                        Text(
                          'Subject: $subjectName',
                        ),
                      if (description.isNotEmpty)
                        Text(description),
                      if (url.isNotEmpty)
                        Text(
                          'Resource: $url',
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });

                  loadNotesData();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (facultyId == null) {
      return const Center(
        child: Text(
          'Faculty session not found. Please login again.',
        ),
      );
    }

    if (classes.isEmpty) {
      return const Center(
        child: Text(
          'No class is assigned to this faculty.',
          textAlign: TextAlign.center,
        ),
      );
    }

    final visibleSubjects = getSubjectsForClass(
      subjects,
      selectedClassId,
      classes,
    );

    return RefreshIndicator(
      onRefresh: loadNotesData,
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Notes & Resources',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            DropdownButtonFormField<int>(
              initialValue: selectedClassId,
              decoration: const InputDecoration(
                labelText: 'Select Class',
                border: OutlineInputBorder(),
              ),
              items: classes.map(
                (item) {
                  final classId =
                      getClassId(item);

                  if (classId == null) {
                    return null;
                  }

                  return DropdownMenuItem<int>(
                    value: classId,
                    child: Text(
                      getClassName(item),
                    ),
                  );
                },
              ).whereType<DropdownMenuItem<int>>().toList(),
              onChanged: (value) {
                final classSubjects =
                    getSubjectsForClass(
                  subjects,
                  value,
                  classes,
                );

                setState(() {
                  selectedClassId = value;
                  selectedSubjectId =
                      classSubjects.isNotEmpty
                          ? getSubjectId(
                              classSubjects.first,
                            )
                          : null;
                });
              },
            ),

            const SizedBox(height: 16),

            if (visibleSubjects.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No subjects found for the selected class.',
                  ),
                ),
              )
            else
              DropdownButtonFormField<int>(
                initialValue: selectedSubjectId,
                decoration: const InputDecoration(
                  labelText: 'Select Subject',
                  border: OutlineInputBorder(),
                ),
                items: visibleSubjects.map(
                  (item) {
                    final subjectId =
                        getSubjectId(item);

                    if (subjectId == null) {
                      return null;
                    }

                    final name =
                        getSubjectName(item);
                    final code =
                        getSubjectCode(item);

                    return DropdownMenuItem<int>(
                      value: subjectId,
                      child: Text(
                        code.isEmpty
                            ? name
                            : '$name ($code)',
                      ),
                    );
                  },
                ).whereType<DropdownMenuItem<int>>().toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSubjectId = value;
                  });
                },
              ),

            const SizedBox(height: 16),

            TextField(
              controller: titleController,
              decoration:
                  const InputDecoration(
                labelText: 'Resource Title',
                hintText:
                    'Enter note/resource title',
                prefixIcon:
                    Icon(Icons.title),
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  descriptionController,
              maxLines: 4,
              decoration:
                  const InputDecoration(
                labelText: 'Description',
                hintText:
                    'Enter a description for the resource',
                prefixIcon:
                    Icon(Icons.notes_outlined),
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  resourceUrlController,
              keyboardType:
                  TextInputType.url,
              decoration:
                  const InputDecoration(
                labelText:
                    'Resource URL (optional)',
                hintText:
                    'Enter PDF, Drive, or resource URL',
                prefixIcon:
                    Icon(Icons.link),
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The current backend stores a resource URL in file_url. Direct file storage/upload is not part of the current Notes API.',
                        style: TextStyle(
                          color:
                              Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child:
                  ElevatedButton.icon(
                onPressed:
                    isSaving ||
                            visibleSubjects
                                .isEmpty
                        ? null
                        : createNote,
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.upload_outlined,
                      ),
                label: Text(
                  isSaving
                      ? 'Uploading...'
                      : 'Upload Notes',
                ),
              ),
            ),

            const SizedBox(height: 28),

            buildExistingNotes(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Notes Upload'),
      ),
      body: buildBody(),
    );
  }
}

