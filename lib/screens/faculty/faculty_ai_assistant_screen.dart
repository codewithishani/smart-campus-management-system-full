import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'faculty_dashboard.dart';

class FacultyAiAssistantScreen extends StatefulWidget {
  const FacultyAiAssistantScreen({super.key});

  @override
  State<FacultyAiAssistantScreen> createState() =>
      _FacultyAiAssistantScreenState();
}

class _FacultyAiAssistantScreenState
    extends State<FacultyAiAssistantScreen> {
  final TextEditingController controller =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();

  final List<Map<String, String>> messages = [
    {
      'sender': 'AI',
      'message':
          'Hello! I am your AI Faculty Assistant. Ask me about your students, attendance, assignments, marks, notices, leave requests, or teaching suggestions.',
    },
  ];

  bool isProcessing = false;

  int? get facultyId =>
      FacultyDashboard.currentFacultyId;

  int getIntValue(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value is int) {
        return value;
      }

      if (value is num) {
        return value.toInt();
      }

      final parsed =
          int.tryParse(value?.toString() ?? '');

      if (parsed != null) {
        return parsed;
      }
    }

    return 0;
  }

  double getDoubleValue(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value is num) {
        return value.toDouble();
      }

      final parsed =
          double.tryParse(value?.toString() ?? '');

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

  int getStudentId(
    Map<String, dynamic> student,
  ) {
    return getIntValue(
      student,
      [
        'student_id',
        'id',
      ],
    );
  }

  int getClassId(
    Map<String, dynamic> classData,
  ) {
    return getIntValue(
      classData,
      [
        'class_id',
        'id',
      ],
    );
  }

  int getClassCourseId(
    Map<String, dynamic> classData,
  ) {
    return getIntValue(
      classData,
      [
        'course_id',
      ],
    );
  }

  int getAssignedFacultyId(
    Map<String, dynamic> classData,
  ) {
    return getIntValue(
      classData,
      [
        'class_teacher_id',
        'faculty_id',
        'teacher_id',
        'assigned_faculty_id',
      ],
    );
  }

  int getStudentClassId(
    Map<String, dynamic> student,
  ) {
    return getIntValue(
      student,
      [
        'class_id',
      ],
    );
  }

  int getStudentCourseId(
    Map<String, dynamic> student,
  ) {
    return getIntValue(
      student,
      [
        'course_id',
      ],
    );
  }

  List<Map<String, dynamic>> getFacultyClasses(
    List<dynamic> classes,
    List<dynamic> assignments,
  ) {
    final currentFacultyId = facultyId;

    if (currentFacultyId == null) {
      return [];
    }

    final facultyClassIds = <int>{};

    // Classes where this faculty is the class teacher.
    for (final item in classes) {
      if (item is! Map) continue;

      final classData =
          Map<String, dynamic>.from(item);

      final classId = getClassId(classData);
      final assignedFacultyId =
          getAssignedFacultyId(classData);

      if (classId > 0 &&
          assignedFacultyId == currentFacultyId) {
        facultyClassIds.add(classId);
      }
    }

    // Classes associated with this faculty through
    // their assignments.
    for (final item in assignments) {
      if (item is! Map) continue;

      final assignment =
          Map<String, dynamic>.from(item);

      final assignmentFacultyId =
          getIntValue(
        assignment,
        [
          'faculty_id',
          'teacher_id',
          'created_by',
          'assigned_to',
        ],
      );

      final assignmentClassId =
          getIntValue(
        assignment,
        [
          'class_id',
        ],
      );

      if (assignmentFacultyId ==
              currentFacultyId &&
          assignmentClassId > 0) {
        facultyClassIds.add(
          assignmentClassId,
        );
      }
    }

    final result = <Map<String, dynamic>>[];

    for (final item in classes) {
      if (item is! Map) continue;

      final classData =
          Map<String, dynamic>.from(item);

      final classId = getClassId(classData);

      if (facultyClassIds.contains(classId)) {
        result.add(classData);
      }
    }

    return result;
  }

  List<int> getFacultyClassIds(
    List<Map<String, dynamic>> facultyClasses,
  ) {
    return facultyClasses
        .map(getClassId)
        .where((id) => id > 0)
        .toList();
  }

  List<int> getFacultyCourseIds(
    List<Map<String, dynamic>> facultyClasses,
  ) {
    return facultyClasses
        .map(getClassCourseId)
        .where((id) => id > 0)
        .toList();
  }

  List<Map<String, dynamic>> getFacultyStudents(
    List<dynamic> students,
    List<int> facultyClassIds,
    List<int> facultyCourseIds,
  ) {
    if (facultyClassIds.isEmpty &&
        facultyCourseIds.isEmpty) {
      return [];
    }

    return students
        .whereType<Map>()
        .map(
          (item) =>
              Map<String, dynamic>.from(item),
        )
        .where(
          (student) {
            final studentClassId =
                getStudentClassId(student);

            final studentCourseId =
                getStudentCourseId(student);

            final classMatch =
                studentClassId > 0 &&
                facultyClassIds.contains(
                  studentClassId,
                );

            final courseMatch =
                studentCourseId > 0 &&
                facultyCourseIds.contains(
                  studentCourseId,
                );

            return classMatch || courseMatch;
          },
        )
        .toList();
  }

  bool isAssignmentForFaculty(
    Map<String, dynamic> assignment,
    List<int> facultyClassIds,
    List<int> facultyCourseIds,
    Set<int> facultyStudentIds,
    Set<int> facultySubjectIds,
  ) {
    final currentFacultyId = facultyId;

    final assignmentFacultyId =
        getIntValue(
      assignment,
      [
        'faculty_id',
        'teacher_id',
        'created_by',
        'assigned_to',
      ],
    );

    if (assignmentFacultyId > 0) {
      return assignmentFacultyId == currentFacultyId;
    }

    final assignmentClassId =
        getIntValue(
      assignment,
      [
        'class_id',
      ],
    );

    if (assignmentClassId > 0) {
      return facultyClassIds.contains(
        assignmentClassId,
      );
    }

    final assignmentCourseId =
        getIntValue(
      assignment,
      [
        'course_id',
      ],
    );

    final assignmentSubjectId =
        getIntValue(
      assignment,
      [
        'subject_id',
      ],
    );

    if (assignmentCourseId > 0 &&
        facultyCourseIds.contains(
          assignmentCourseId,
        )) {
      if (assignmentSubjectId > 0) {
        return facultySubjectIds.contains(
          assignmentSubjectId,
        );
      }

      return true;
    }

    final assignmentStudentId =
        getIntValue(
      assignment,
      [
        'student_id',
      ],
    );

    if (assignmentStudentId > 0) {
      return facultyStudentIds.contains(
        assignmentStudentId,
      );
    }

    if (assignmentSubjectId > 0) {
      return facultySubjectIds.contains(
        assignmentSubjectId,
      );
    }

    return false;
  }

  Future<void> sendMessage() async {
    final text = controller.text.trim();

    if (text.isEmpty || isProcessing) {
      return;
    }

    setState(() {
      messages.add({
        'sender': 'You',
        'message': text,
      });

      isProcessing = true;
    });

    controller.clear();
    scrollToBottom();

    final response =
        await generateResponse(text);

    if (!mounted) return;

    setState(() {
      messages.add({
        'sender': 'AI',
        'message': response,
      });

      isProcessing = false;
    });

    scrollToBottom();
  }

  Future<String> generateResponse(
    String question,
  ) async {
    final query = question.toLowerCase();

    if (facultyId == null) {
      return 'Faculty session not found. Please login again.';
    }

    try {
      final data = await Future.wait([
        ApiService.getStudents(),
        ApiService.getAttendance(),
        ApiService.getAssignments(),
        ApiService.getSubmissions(),
        ApiService.getResults(),
        ApiService.getClasses(),
        ApiService.getSubjects(),
        ApiService.getLeaveRequests(),
      ]);

      final students = data[0];
      final attendance = data[1];
      final assignments = data[2];
      final submissions = data[3];
      final results = data[4];
      final classes = data[5];
      final subjects = data[6];
      final leaveRequests = data[7];

      final facultyClasses =
          getFacultyClasses(
        classes,
        assignments,
      );

      final facultyClassIds =
          getFacultyClassIds(
        facultyClasses,
      );

      final facultyCourseIds =
          getFacultyCourseIds(
        facultyClasses,
      );

      /*
       * If the faculty is connected to assignments
       * but the class endpoint does not expose the
       * class correctly, still continue with the
       * assignments instead of immediately failing.
       */
      final facultyAssignments =
          assignments.where(
        (item) {
          if (item is! Map) return false;

          final assignment =
              Map<String, dynamic>.from(item);

          final assignmentFacultyId =
              getIntValue(
            assignment,
            [
              'faculty_id',
              'teacher_id',
              'created_by',
              'assigned_to',
            ],
          );

          return assignmentFacultyId ==
              facultyId;
        },
      ).toList();

      final effectiveClassIds =
          <int>{...facultyClassIds};

      for (final item in facultyAssignments) {
        final assignment =
            Map<String, dynamic>.from(item);

        final classId = getIntValue(
          assignment,
          ['class_id'],
        );

        if (classId > 0) {
          effectiveClassIds.add(classId);
        }
      }

      final effectiveCourseIds =
          <int>{...facultyCourseIds};

      for (final item in facultyClasses) {
        final courseId =
            getClassCourseId(item);

        if (courseId > 0) {
          effectiveCourseIds.add(courseId);
        }
      }

      final facultyStudents =
          getFacultyStudents(
        students,
        effectiveClassIds.toList(),
        effectiveCourseIds.toList(),
      );

      final facultyStudentIds =
          facultyStudents
              .map(getStudentId)
              .where((id) => id > 0)
              .toSet();

      final classNames = facultyClasses
          .map(
            (classData) => getStringValue(
              classData,
              [
                'class_name',
                'name',
                'class_code',
              ],
              defaultValue: 'Assigned Class',
            ),
          )
          .join(', ');

      final facultySubjectIds = <int>{};

      for (final item in subjects) {
        if (item is! Map) continue;

        final subject =
            Map<String, dynamic>.from(item);

        final subjectClassId =
            getIntValue(
          subject,
          ['class_id'],
        );

        final subjectCourseId =
            getIntValue(
          subject,
          ['course_id'],
        );

        final belongsToClass =
            subjectClassId > 0 &&
            effectiveClassIds.contains(
              subjectClassId,
            );

        final belongsToCourse =
            subjectCourseId > 0 &&
            effectiveCourseIds.contains(
              subjectCourseId,
            );

        if (belongsToClass ||
            belongsToCourse) {
          final subjectId =
              getIntValue(
            subject,
            [
              'subject_id',
              'id',
            ],
          );

          if (subjectId > 0) {
            facultySubjectIds.add(
              subjectId,
            );
          }
        }
      }

      if (query.contains('attendance') ||
          query.contains('absent') ||
          query.contains('present')) {
        int present = 0;
        int absent = 0;

        for (final item in attendance) {
          if (item is! Map) continue;

          final record =
              Map<String, dynamic>.from(item);

          final studentId =
              getIntValue(
            record,
            [
              'student_id',
              'studentId',
            ],
          );

          if (!facultyStudentIds.contains(
            studentId,
          )) {
            continue;
          }

          final status =
              getStringValue(
            record,
            [
              'status',
              'attendance_status',
            ],
          ).toLowerCase();

          if (status == 'present' ||
              status == 'p' ||
              status == 'true') {
            present++;
          } else if (status == 'absent' ||
              status == 'a' ||
              status == 'false') {
            absent++;
          }
        }

        final total =
            present + absent;

        if (total == 0) {
          return 'I could not find attendance records for your assigned students.';
        }

        final percentage =
            (present / total) * 100;

        return 'Attendance summary:\n\n'
            'Present: $present\n'
            'Absent: $absent\n'
            'Recorded entries: $total\n'
            'Attendance percentage: '
            '${percentage.toStringAsFixed(1)}%';
      }

      if (query.contains('assignment') ||
          query.contains('assignments')) {
        final relevantAssignments =
            assignments.where(
          (item) {
            if (item is! Map) return false;

            final assignment =
                Map<String, dynamic>.from(
              item,
            );

            return isAssignmentForFaculty(
              assignment,
              effectiveClassIds.toList(),
              effectiveCourseIds.toList(),
              facultyStudentIds,
              facultySubjectIds,
            );
          },
        ).toList();

        final assignmentIds =
            relevantAssignments
                .map(
                  (item) => getIntValue(
                    Map<String, dynamic>.from(
                      item,
                    ),
                    [
                      'assignment_id',
                      'id',
                    ],
                  ),
                )
                .where((id) => id > 0)
                .toSet();

        int submissionCount = 0;

        for (final item in submissions) {
          if (item is! Map) continue;

          final submission =
              Map<String, dynamic>.from(item);

          final studentId =
              getIntValue(
            submission,
            [
              'student_id',
              'studentId',
            ],
          );

          final assignmentId =
              getIntValue(
            submission,
            [
              'assignment_id',
              'assignmentId',
            ],
          );

          if (facultyStudentIds.contains(
                studentId,
              ) &&
              assignmentIds.contains(
                assignmentId,
              )) {
            submissionCount++;
          }
        }

        return 'Assignment summary:\n\n'
            'Assignments: '
            '${relevantAssignments.length}\n'
            'Submission records: '
            '$submissionCount\n\n'
            'Open Assignment Management or Submission Review for detailed information.';
      }

      if (query.contains('student') ||
          query.contains('students')) {
        final classText =
            classNames.isEmpty
                ? 'your assigned teaching classes'
                : classNames;

        return 'Your teaching classes: '
            '$classText\n\n'
            'Students connected to your classes: '
            '${facultyStudents.length}\n\n'
            'Open Student List to view student details.';
      }

      if (query.contains('mark') ||
          query.contains('marks') ||
          query.contains('result') ||
          query.contains('results')) {
        double totalObtained = 0;
        double totalMarks = 0;
        int resultCount = 0;

        for (final item in results) {
          if (item is! Map) continue;

          final result =
              Map<String, dynamic>.from(item);

          final studentId =
              getIntValue(
            result,
            [
              'student_id',
              'studentId',
            ],
          );

          if (!facultyStudentIds.contains(
            studentId,
          )) {
            continue;
          }

          final obtained =
              getDoubleValue(
            result,
            [
              'marks_obtained',
              'marks',
              'obtained_marks',
            ],
          );

          final maximum =
              getDoubleValue(
            result,
            [
              'total_marks',
              'max_marks',
            ],
          );

          totalObtained += obtained;
          totalMarks += maximum;
          resultCount++;
        }

        if (resultCount == 0) {
          return 'No result records are currently available for your assigned students.';
        }

        if (totalMarks <= 0) {
          return 'Result records are available, but total marks could not be calculated.';
        }

        final percentage =
            (totalObtained / totalMarks) * 100;

        return 'Marks summary:\n\n'
            'Result records: $resultCount\n'
            'Calculated marks percentage: '
            '${percentage.toStringAsFixed(1)}%';
      }

      if (query.contains('notice') ||
          query.contains('notices')) {
        final notices =
            await ApiService.getNotices();

        return 'There are ${notices.length} notice(s) available in the campus system.\n\n'
            'Use Notice Publishing to create and review faculty notices.';
      }

      if (query.contains('leave')) {
        int facultyLeaveCount = 0;

        for (final item in leaveRequests) {
          if (item is! Map) continue;

          final leave =
              Map<String, dynamic>.from(item);

          final assignedFacultyId =
              getIntValue(
            leave,
            [
              'faculty_id',
              'teacher_id',
              'assigned_to',
              'approved_by',
            ],
          );

          if (assignedFacultyId == facultyId) {
            facultyLeaveCount++;
          }
        }

        return 'There are $facultyLeaveCount leave request(s) associated with your faculty account.\n\n'
            'Open Leave Requests to review their current status.';
      }

      if (query.contains('class') ||
          query.contains('classes') ||
          query.contains('subject') ||
          query.contains('subjects')) {
        return 'Your teaching information:\n\n'
            'Assigned classes: '
            '${classNames.isEmpty ? 'No class name available' : classNames}\n'
            'Students: ${facultyStudents.length}\n'
            'Subjects: ${facultySubjectIds.length}';
      }

      if (query.contains('help') ||
          query.contains('what can you do') ||
          query.contains('how can you help')) {
        return 'I can help you with your faculty work:\n\n'
            '• Attendance summary\n'
            '• Assigned student count\n'
            '• Assignment information\n'
            '• Submission information\n'
            '• Marks and results\n'
            '• Leave requests\n'
            '• Classes and subjects\n'
            '• Basic teaching suggestions\n\n'
            'Try asking:\n'
            '"Show my attendance summary."\n'
            '"How many students are in my class?"\n'
            '"Show my assignment information."';
      }

      if (query.contains('teach') ||
          query.contains('teaching') ||
          query.contains('lesson')) {
        return 'Teaching suggestion:\n\n'
            'Identify students with lower attendance, incomplete assignments, or weaker marks. '
            'Provide focused revision material, short practice tasks, and regular feedback. '
            'Then compare later performance to monitor improvement.';
      }

      if (query.contains('weak') ||
          query.contains('improve') ||
          query.contains('performance')) {
        final weakStudents =
            <String>[];

        for (final student
            in facultyStudents) {
          final studentId =
              getStudentId(student);

          final attendanceRecords =
              attendance.where(
            (item) {
              if (item is! Map) {
                return false;
              }

              final record =
                  Map<String, dynamic>.from(
                item,
              );

              return getIntValue(
                    record,
                    [
                      'student_id',
                      'studentId',
                    ],
                  ) ==
                  studentId;
            },
          );

          int present = 0;
          int total = 0;

          for (final item
              in attendanceRecords) {
            if (item is! Map) continue;

            final record =
                Map<String, dynamic>.from(
              item,
            );

            final status =
                getStringValue(
              record,
              [
                'status',
                'attendance_status',
              ],
            ).toLowerCase();

            if (status.isEmpty) {
              continue;
            }

            total++;

            if (status == 'present' ||
                status == 'p') {
              present++;
            }
          }

          final attendancePercentage =
              total > 0
                  ? (present / total) * 100
                  : 0;

          if (attendancePercentage > 0 &&
              attendancePercentage < 75) {
            final name =
                getStringValue(
              student,
              [
                'name',
                'student_name',
                'full_name',
              ],
              defaultValue: 'Student',
            );

            weakStudents.add(
              '$name '
              '(${attendancePercentage.toStringAsFixed(1)}% attendance)',
            );
          }
        }

        if (weakStudents.isEmpty) {
          return 'I did not find any assigned students with attendance below 75% based on the currently available attendance records.';
        }

        return 'Students needing attendance attention:\n\n'
            '${weakStudents.join('\n')}\n\n'
            'Consider reviewing their attendance and academic activity.';
      }

      return 'I can help with your assigned classes, students, attendance, assignments, submissions, marks, results, leave requests, subjects, and teaching suggestions.\n\n'
          'Try asking:\n'
          '"Show attendance summary."\n'
          '"How many students are in my class?"\n'
          '"Show marks summary."';
    } catch (e) {
      return 'I could not retrieve the requested information from the backend right now. '
          'Please check that the FastAPI server is running and try again.';
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!scrollController.hasClients) {
        return;
      }

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration:
            const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void clearChat() {
    setState(() {
      messages.clear();

      messages.add({
        'sender': 'AI',
        'message':
            'Chat cleared. How can I help you with your faculty work?',
      });
    });

    scrollToBottom();
  }

  Widget buildMessage(
    Map<String, String> message,
  ) {
    final isUser =
        message['sender'] == 'You';

    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 600,
        ),
        margin:
            const EdgeInsets.only(bottom: 12),
        child: Card(
          elevation: 1,
          child: Padding(
            padding:
                const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      isUser
                          ? Icons.person
                          : Icons.auto_awesome,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      message['sender']!,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  message['message']!,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSuggestion(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        controller.text = text;
        sendMessage();
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('AI Faculty Assistant'),
        actions: [
          IconButton(
            tooltip: 'Clear Chat',
            onPressed: clearChat,
            icon: const Icon(
              Icons.delete_outline,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding:
                  const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder:
                  (context, index) {
                return buildMessage(
                  messages[index],
                );
              },
            ),
          ),
          if (isProcessing)
            const Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 8,
              ),
              child: Align(
                alignment:
                    Alignment.centerLeft,
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'AI is checking your campus data...',
                    ),
                  ],
                ),
              ),
            ),
          SingleChildScrollView(
            scrollDirection:
                Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            child: Row(
              children: [
                buildSuggestion(
                  'Show attendance summary',
                ),
                const SizedBox(width: 8),
                buildSuggestion(
                  'Show student count',
                ),
                const SizedBox(width: 8),
                buildSuggestion(
                  'Show assignment information',
                ),
                const SizedBox(width: 8),
                buildSuggestion(
                  'Show marks summary',
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textInputAction:
                          TextInputAction.send,
                      decoration:
                          const InputDecoration(
                        hintText:
                            'Ask the AI assistant...',
                        border:
                            OutlineInputBorder(),
                      ),
                      onSubmitted: (_) =>
                          sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: isProcessing
                        ? null
                        : sendMessage,
                    icon: const Icon(
                      Icons.send,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}