
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'faculty_dashboard.dart';

class FacultyClassSubjectsScreen extends StatefulWidget {
  const FacultyClassSubjectsScreen({super.key});

  @override
  State<FacultyClassSubjectsScreen> createState() =>
      _FacultyClassSubjectsScreenState();
}

class _FacultyClassSubjectsScreenState
    extends State<FacultyClassSubjectsScreen> {
  List<dynamic> classes = [];
  List<dynamic> subjects = [];
  List<dynamic> assignments = [];

  bool isLoading = true;
  String? errorMessage;

  int? get facultyId =>
      FacultyDashboard.currentFacultyId;

  @override
  void initState() {
    super.initState();
    loadClassSubjects();
  }

  Future<void> loadClassSubjects() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getClasses(),
        ApiService.getSubjects(),
        ApiService.getAssignments(),
      ]);

      if (!mounted) return;

      setState(() {
        classes = List<dynamic>.from(results[0]);
        subjects = List<dynamic>.from(results[1]);
        assignments = List<dynamic>.from(results[2]);
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load classes and subjects.';
      });
    }
  }

  int? parseId(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value == null) {
      return null;
    }

    return int.tryParse(
      value.toString().trim(),
    );
  }

  int? getClassId(
    Map<String, dynamic> item,
  ) {
    return parseId(
      item['class_id'] ?? item['id'],
    );
  }

  int? getCourseId(
    Map<String, dynamic> item,
  ) {
    return parseId(
      item['course_id'],
    );
  }

  int? getAssignedFacultyId(
    Map<String, dynamic> item,
  ) {
    return parseId(
      item['class_teacher_id'] ??
          item['faculty_id'] ??
          item['teacher_id'] ??
          item['assigned_faculty_id'],
    );
  }

  int? getAssignmentFacultyId(
    Map<String, dynamic> item,
  ) {
    return parseId(
      item['faculty_id'] ??
          item['teacher_id'] ??
          item['created_by'] ??
          item['assigned_to'],
    );
  }

  int? getAssignmentClassId(
    Map<String, dynamic> item,
  ) {
    return parseId(
      item['class_id'],
    );
  }

  int? getAssignmentCourseId(
    Map<String, dynamic> item,
  ) {
    return parseId(
      item['course_id'],
    );
  }

  int? getSubjectClassId(
    Map<String, dynamic> item,
  ) {
    return parseId(
      item['class_id'],
    );
  }

  int? getSubjectCourseId(
    Map<String, dynamic> item,
  ) {
    return parseId(
      item['course_id'],
    );
  }

  String getClassName(
    Map<String, dynamic> item,
  ) {
    return (
      item['class_name'] ??
      item['name'] ??
      item['class_code'] ??
      'Class'
    ).toString();
  }

  String getSemester(
    Map<String, dynamic> item,
  ) {
    return (
      item['semester'] ?? ''
    ).toString();
  }

  String getAcademicYear(
    Map<String, dynamic> item,
  ) {
    return (
      item['academic_year'] ?? ''
    ).toString();
  }

  String getSubjectName(
    Map<String, dynamic> item,
  ) {
    return (
      item['subject_name'] ??
      item['name'] ??
      item['subject_code'] ??
      'Subject'
    ).toString();
  }

  String getSubjectCode(
    Map<String, dynamic> item,
  ) {
    return (
      item['subject_code'] ?? ''
    ).toString();
  }

  String getCredits(
    Map<String, dynamic> item,
  ) {
    return (
      item['credits'] ?? ''
    ).toString();
  }

  List<Map<String, dynamic>> getFacultyClasses() {
    final result =
        <Map<String, dynamic>>[];

    final currentFacultyId = facultyId;

    if (currentFacultyId == null) {
      return result;
    }

    final facultyClassIds = <int>{};

    // 1. Classes where the faculty is the
    //    class teacher.
    for (final item in classes) {
      if (item is! Map) continue;

      final classData =
          Map<String, dynamic>.from(item);

      final classId =
          getClassId(classData);

      final assignedFacultyId =
          getAssignedFacultyId(classData);

      if (classId != null &&
          assignedFacultyId ==
              currentFacultyId) {
        facultyClassIds.add(classId);
      }
    }

    // 2. Classes connected through the
    //    faculty's assignments.
    //
    // This is important because a faculty member
    // can teach a subject without being the
    // class teacher.
    for (final item in assignments) {
      if (item is! Map) continue;

      final assignment =
          Map<String, dynamic>.from(item);

      final assignmentFacultyId =
          getAssignmentFacultyId(
        assignment,
      );

      final assignmentClassId =
          getAssignmentClassId(
        assignment,
      );

      if (assignmentFacultyId ==
              currentFacultyId &&
          assignmentClassId != null) {
        facultyClassIds.add(
          assignmentClassId,
        );
      }
    }

    for (final item in classes) {
      if (item is! Map) continue;

      final classData =
          Map<String, dynamic>.from(item);

      final classId =
          getClassId(classData);

      if (classId != null &&
          facultyClassIds.contains(
            classId,
          )) {
        result.add(classData);
      }
    }

    return result;
  }

  List<Map<String, dynamic>> getSubjectsForClass(
    Map<String, dynamic> classData,
  ) {
    final classId =
        getClassId(classData);

    final courseId =
        getCourseId(classData);

    final matchingSubjects =
        <Map<String, dynamic>>[];

    final addedSubjectIds = <int>{};

    for (final item in subjects) {
      if (item is! Map) continue;

      final subjectData =
          Map<String, dynamic>.from(item);

      final subjectId = parseId(
        subjectData['subject_id'] ??
            subjectData['id'],
      );

      final subjectClassId =
          getSubjectClassId(
        subjectData,
      );

      final subjectCourseId =
          getSubjectCourseId(
        subjectData,
      );

      bool matches = false;

      // Direct class mapping.
      if (subjectClassId != null &&
          classId != null &&
          subjectClassId == classId) {
        matches = true;
      }

      // Course mapping.
      if (subjectCourseId != null &&
          courseId != null &&
          subjectCourseId == courseId) {
        matches = true;
      }

      if (matches) {
        if (subjectId != null) {
          if (addedSubjectIds
              .contains(subjectId)) {
            continue;
          }

          addedSubjectIds.add(subjectId);
        }

        matchingSubjects.add(
          subjectData,
        );
      }
    }

    // Also include subjects referenced by
    // this faculty's assignments for this class.
    final classAssignmentSubjectIds =
        <int>{};

    for (final item in assignments) {
      if (item is! Map) continue;

      final assignment =
          Map<String, dynamic>.from(item);

      final assignmentFacultyId =
          getAssignmentFacultyId(
        assignment,
      );

      final assignmentClassId =
          getAssignmentClassId(
        assignment,
      );

      if (assignmentFacultyId != facultyId ||
          assignmentClassId != classId) {
        continue;
      }

      final subjectId = parseId(
        assignment['subject_id'],
      );

      if (subjectId != null) {
        classAssignmentSubjectIds
            .add(subjectId);
      }
    }

    for (final item in subjects) {
      if (item is! Map) continue;

      final subjectData =
          Map<String, dynamic>.from(item);

      final subjectId = parseId(
        subjectData['subject_id'] ??
            subjectData['id'],
      );

      if (subjectId != null &&
          classAssignmentSubjectIds
              .contains(subjectId) &&
          !addedSubjectIds.contains(
            subjectId,
          )) {
        addedSubjectIds.add(subjectId);

        matchingSubjects.add(
          subjectData,
        );
      }
    }

    return matchingSubjects;
  }

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
                  'Unable to load class information.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed:
                  loadClassSubjects,
              icon:
                  const Icon(Icons.refresh),
              label:
                  const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNoFacultySessionState() {
    return RefreshIndicator(
      onRefresh:
          loadClassSubjects,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          Center(
            child: Padding(
              padding:
                  EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: 60,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Faculty session not found.',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please login again to load your assigned classes.',
                    textAlign:
                        TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    return RefreshIndicator(
      onRefresh:
          loadClassSubjects,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 140),
          const Center(
            child: Column(
              children: [
                Icon(
                  Icons.class_outlined,
                  size: 60,
                ),
                SizedBox(height: 12),
                Text(
                  'No classes assigned.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Padding(
                  padding:
                      EdgeInsets.symmetric(
                    horizontal: 24,
                  ),
                  child: Text(
                    'No class connected to this faculty was found.',
                    textAlign:
                        TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Logged-in Faculty ID: '
              '${facultyId ?? "Unknown"}',
              style: TextStyle(
                color:
                    Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildClassCard(
    Map<String, dynamic> classData,
  ) {
    final className =
        getClassName(classData);

    final semester =
        getSemester(classData);

    final academicYear =
        getAcademicYear(classData);

    final classSubjects =
        getSubjectsForClass(
      classData,
    );

    String classInfo = '';

    if (semester.isNotEmpty) {
      classInfo +=
          'Semester $semester';
    }

    if (academicYear.isNotEmpty) {
      if (classInfo.isNotEmpty) {
        classInfo += ' • ';
      }

      classInfo += academicYear;
    }

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      child: ExpansionTile(
        leading:
            const CircleAvatar(
          child:
              Icon(Icons.school),
        ),
        title: Text(
          className,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        subtitle: Text(
          classInfo.isEmpty
              ? 'Assigned class'
              : classInfo,
        ),
        childrenPadding:
            const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          14,
        ),
        children: [
          const Divider(),

          Align(
            alignment:
                Alignment.centerLeft,
            child: Text(
              'Subjects',
              style:
                  Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
            ),
          ),

          const SizedBox(height: 8),

          if (classSubjects.isEmpty)
            const Align(
              alignment:
                  Alignment.centerLeft,
              child: Padding(
                padding:
                    EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: Text(
                  'No subjects found for this class.',
                ),
              ),
            ),

          ...classSubjects.map(
            (subject) {
              final name =
                  getSubjectName(
                subject,
              );

              final code =
                  getSubjectCode(
                subject,
              );

              final credits =
                  getCredits(
                subject,
              );

              String details = '';

              if (code.isNotEmpty) {
                details += code;
              }

              if (credits.isNotEmpty) {
                if (details.isNotEmpty) {
                  details += ' • ';
                }

                details +=
                    '$credits Credits';
              }

              return ListTile(
                contentPadding:
                    EdgeInsets.zero,
                leading:
                    const Icon(
                  Icons.menu_book_outlined,
                ),
                title: Text(
                  name,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                subtitle:
                    details.isEmpty
                        ? null
                        : Text(
                            details,
                          ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return buildLoadingState();
    }

    if (errorMessage != null) {
      return buildErrorState();
    }

    if (facultyId == null) {
      return buildNoFacultySessionState();
    }

    final facultyClasses =
        getFacultyClasses();

    if (facultyClasses.isEmpty) {
      return buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh:
          loadClassSubjects,
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(16),
        itemCount:
            facultyClasses.length,
        itemBuilder:
            (context, index) {
          return buildClassCard(
            facultyClasses[index],
          );
        },
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Class & Subjects',
        ),
      ),
      body: buildBody(),
    );
  }
}
