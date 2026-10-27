import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // =========================
  // AUTH
  // =========================

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/auth/login'
        '?email=${Uri.encodeQueryComponent(email)}'
        '&password=${Uri.encodeQueryComponent(password)}',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    try {
      final body = jsonDecode(response.body);
      throw Exception(body['detail'] ?? 'Login failed');
    } catch (_) {
      throw Exception('Login failed');
    }
  }

  // =========================
  // STUDENTS
  // =========================

  static Future<List<dynamic>> getStudents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/students/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load students');
  }

  static Future<Map<String, dynamic>> getStudent(
    int studentId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/students/$studentId'),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    throw Exception('Failed to load student');
  }

 // =========================
// FACULTY
// =========================

static Future<List<dynamic>> getFaculty() async {
  final response = await http.get(
    Uri.parse('$baseUrl/faculty/'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception('Failed to load faculty');
}

static Future<Map<String, dynamic>> getFacultyById(
  int facultyId,
) async {
  final response = await http.get(
    Uri.parse('$baseUrl/faculty/$facultyId'),
  );

  if (response.statusCode == 200) {
    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  throw Exception(
    'Failed to load faculty: ${response.body}',
  );
}

// Get only the students and classes related
// to the currently logged-in faculty.
static Future<Map<String, dynamic>> getFacultyTeachingSummary(
  int facultyId,
) async {
  final response = await http.get(
    Uri.parse(
      '$baseUrl/faculty/$facultyId/teaching-summary',
    ),
  );

  if (response.statusCode == 200) {
    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  throw Exception(
    'Failed to load faculty teaching summary: ${response.body}',
  );
}

static Future<Map<String, dynamic>> updateFaculty({
  required int facultyId,
  required int userId,
  required String employeeId,
  required String name,
  required String email,
  String? phone,
  required int departmentId,
  String? designation,
}) async {
  final response = await http.put(
    Uri.parse('$baseUrl/faculty/$facultyId'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'user_id': userId,
      'employee_id': employeeId,
      'name': name,
      'email': email,
      'phone': phone,
      'department_id': departmentId,
      'designation': designation,
    }),
  );

  if (response.statusCode == 200) {
    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  throw Exception(
    'Failed to update faculty profile: ${response.body}',
  );
}


  // =========================
  // PARENTS
  // =========================

  static Future<List<dynamic>> getParents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/parents/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load parents');
  }

  // =========================
// DEPARTMENTS
// =========================

static Future<List<dynamic>> getDepartments() async {
  final response = await http.get(
    Uri.parse('$baseUrl/departments/'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception('Failed to load departments');
}

static Future<Map<String, dynamic>> createDepartment(
  Map<String, dynamic> data,
) async {
  final response = await http.post(
    Uri.parse('$baseUrl/departments/'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode == 200 ||
      response.statusCode == 201) {
    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  throw Exception(
    'Failed to create department: ${response.body}',
  );
}

static Future<Map<String, dynamic>> updateDepartment(
  int departmentId,
  Map<String, dynamic> data,
) async {
  final response = await http.put(
    Uri.parse('$baseUrl/departments/$departmentId'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode == 200) {
    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  throw Exception(
    'Failed to update department: ${response.body}',
  );
}

static Future<void> deleteDepartment(
  int departmentId,
) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/departments/$departmentId'),
  );

  if (response.statusCode != 200 &&
      response.statusCode != 204) {
    throw Exception(
      'Failed to delete department: ${response.body}',
    );
  }
}
  // =========================
  // COURSES
  // =========================

  static Future<List<dynamic>> getCourses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/courses/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load courses');
  }

  static Future<Map<String, dynamic>> createCourse({
    required int departmentId,
    required String courseName,
    required String courseCode,
    int? duration,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/courses/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'department_id': departmentId,
        'course_name': courseName,
        'course_code': courseCode,
        'duration': duration,
        'description': description,
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to create course: ${response.body}',
    );
  }

  static Future<Map<String, dynamic>> updateCourse({
    required int courseId,
    required int departmentId,
    required String courseName,
    required String courseCode,
    int? duration,
    String? description,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/courses/$courseId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'department_id': departmentId,
        'course_name': courseName,
        'course_code': courseCode,
        'duration': duration,
        'description': description,
      }),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to update course: ${response.body}',
    );
  }

  static Future<void> deleteCourse(int courseId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/courses/$courseId'),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 204) {
      return;
    }

    throw Exception(
      'Failed to delete course: ${response.body}',
    );
  }

  // =========================
  // SUBJECTS
  // =========================

  static Future<List<dynamic>> getSubjects() async {
    final response = await http.get(
      Uri.parse('$baseUrl/subjects/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load subjects');
  }

  static Future<Map<String, dynamic>> createSubject({
    required int courseId,
    required String subjectName,
    required String subjectCode,
    required int semester,
    required int credits,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/subjects/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'course_id': courseId,
        'subject_name': subjectName,
        'subject_code': subjectCode,
        'semester': semester,
        'credits': credits,
        'description': description,
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to create subject: ${response.body}',
    );
  }

  static Future<Map<String, dynamic>> updateSubject({
    required int subjectId,
    required int courseId,
    required String subjectName,
    required String subjectCode,
    required int semester,
    required int credits,
    String? description,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/subjects/$subjectId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'course_id': courseId,
        'subject_name': subjectName,
        'subject_code': subjectCode,
        'semester': semester,
        'credits': credits,
        'description': description,
      }),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to update subject: ${response.body}',
    );
  }

  static Future<void> deleteSubject(int subjectId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/subjects/$subjectId'),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 204) {
      return;
    }

    throw Exception('Failed to delete subject');
  }

  // =========================
  // CLASSES
  // =========================

  static Future<List<dynamic>> getClasses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/classes/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load classes');
  }

  static Future<Map<String, dynamic>> createClass({
  required int courseId,
  required String className,
  required int semester,
  required String academicYear,
  int? classTeacherId,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/classes/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'course_id': courseId,
      'class_name': className,
      'semester': semester,
      'academic_year': academicYear,
      'class_teacher_id': classTeacherId,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  throw Exception('Failed to create class: ${response.body}');
}

static Future<Map<String, dynamic>> updateClass({
  required int classId,
  required int courseId,
  required String className,
  required int semester,
  required String academicYear,
  int? classTeacherId,
}) async {
  final response = await http.put(
    Uri.parse('$baseUrl/classes/$classId'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'course_id': courseId,
      'class_name': className,
      'semester': semester,
      'academic_year': academicYear,
      'class_teacher_id': classTeacherId,
    }),
  );

  if (response.statusCode == 200) {
    return Map<String, dynamic>.from(jsonDecode(response.body));
  }

  throw Exception('Failed to update class: ${response.body}');
}

static Future<void> deleteClass(int classId) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/classes/$classId'),
  );

  if (response.statusCode == 200 || response.statusCode == 204) {
    return;
  }

  throw Exception('Failed to delete class: ${response.body}');
}

  // =========================
  // TIMETABLE
  // =========================

  static Future<List<dynamic>> getTimetable() async {
    final response = await http.get(
      Uri.parse('$baseUrl/timetable/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load timetable');
  }

  // =========================
  // ATTENDANCE
  // =========================

  static Future<List<dynamic>> getAttendance() async {
    final response = await http.get(
      Uri.parse('$baseUrl/attendance/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load attendance');
  }

  static Future<Map<String, dynamic>> createAttendance({
    required int studentId,
    required int subjectId,
    required int facultyId,
    required String attendanceDate,
    required String status,
    String? remarks,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/attendance/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'student_id': studentId,
        'subject_id': subjectId,
        'faculty_id': facultyId,
        'attendance_date': attendanceDate,
        'status': status,
        'remarks': remarks,
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to create attendance: ${response.body}',
    );
  }

  static Future<Map<String, dynamic>> updateAttendance({
    required int attendanceId,
    required int studentId,
    required int subjectId,
    required int facultyId,
    required String attendanceDate,
    required String status,
    String? remarks,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/attendance/$attendanceId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'student_id': studentId,
        'subject_id': subjectId,
        'faculty_id': facultyId,
        'attendance_date': attendanceDate,
        'status': status,
        'remarks': remarks,
      }),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to update attendance: ${response.body}',
    );
  }

  // =========================
  // NOTES
  // =========================

  static Future<List<dynamic>> getNotes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notes/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load notes');
  }

  static Future<Map<String, dynamic>> createNote(
    Map<String, dynamic> note,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notes/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(note),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to create note: ${response.body}',
    );
  }

  static Future<Map<String, dynamic>> updateNote(
    int noteId,
    Map<String, dynamic> note,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notes/$noteId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(note),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to update note: ${response.body}',
    );
  }

  static Future<void> deleteNote(int noteId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/notes/$noteId'),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 204) {
      return;
    }

    throw Exception(
      'Failed to delete note: ${response.body}',
    );
  }

  // =========================
  // ASSIGNMENTS
  // =========================

  static Future<List<dynamic>> getAssignments() async {
    final response = await http.get(
      Uri.parse('$baseUrl/assignments/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load assignments');
  }

  static Future<Map<String, dynamic>> createAssignment({
    required int facultyId,
    required int subjectId,
    required int classId,
    required String title,
    String? description,
    required String dueDate,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/assignments/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'faculty_id': facultyId,
        'subject_id': subjectId,
        'class_id': classId,
        'title': title,
        'description': description,
        'due_date': dueDate,
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to create assignment: ${response.body}',
    );
  }

  static Future<Map<String, dynamic>> updateAssignment({
    required int assignmentId,
    required int facultyId,
    required int subjectId,
    required int classId,
    required String title,
    String? description,
    required String dueDate,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/assignments/$assignmentId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'faculty_id': facultyId,
        'subject_id': subjectId,
        'class_id': classId,
        'title': title,
        'description': description,
        'due_date': dueDate,
      }),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to update assignment: ${response.body}',
    );
  }

  static Future<void> deleteAssignment(
    int assignmentId,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/assignments/$assignmentId'),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 204) {
      return;
    }

    throw Exception(
      'Failed to delete assignment: ${response.body}',
    );
  }

  // =========================
  // SUBMISSIONS
  // =========================

  static Future<List<dynamic>> getSubmissions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/submissions/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load submissions');
  }

  static Future<Map<String, dynamic>> createSubmission({
    required int assignmentId,
    required int studentId,
    String? fileUrl,
    required DateTime submissionDate,
    String? status,
    double? marks,
    String? feedback,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/submissions/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'assignment_id': assignmentId,
        'student_id': studentId,
        'file_url': fileUrl,
        'submission_date': submissionDate.toIso8601String(),
        'status': status,
        'marks': marks,
        'feedback': feedback,
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to submit assignment: ${response.body}',
    );
  }

  static Future<Map<String, dynamic>> updateSubmission({
  required int submissionId,
  required int assignmentId,
  required int studentId,
  String? fileUrl,
  required DateTime submissionDate,
  String? status,
  double? marks,
  String? feedback,
}) async {
  final response = await http.put(
    Uri.parse('$baseUrl/submissions/$submissionId'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'assignment_id': assignmentId,
      'student_id': studentId,
      'file_url': fileUrl,
      'submission_date': submissionDate.toIso8601String(),
      'status': status,
      'marks': marks,
      'feedback': feedback,
    }),
  );

  if (response.statusCode == 200) {
    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  throw Exception(
    'Failed to update submission: ${response.body}',
  );
}

  // =========================
  // EXAMS
  // =========================

  static Future<List<dynamic>> getExams() async {
    final response = await http.get(
      Uri.parse('$baseUrl/exams/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load exams');
  }

  // =========================
  // RESULTS
  // =========================

  static Future<List<dynamic>> getResults() async {
    final response = await http.get(
      Uri.parse('$baseUrl/results/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load results');
  }

  static Future<Map<String, dynamic>> createResult(
    Map<String, dynamic> result,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/results/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(result),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to create result: ${response.body}',
    );
  }

  static Future<Map<String, dynamic>> updateResult(
    int resultId,
    Map<String, dynamic> result,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/results/$resultId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(result),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to update result: ${response.body}',
    );
  }

  static Future<void> deleteResult(int resultId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/results/$resultId'),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 204) {
      return;
    }

    throw Exception(
      'Failed to delete result: ${response.body}',
    );
  }

  // =========================
  // NOTICES
  // =========================

  static Future<List<dynamic>> getNotices() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notices/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load notices');
  }

  static Future<Map<String, dynamic>> createNotice(
    Map<String, dynamic> notice,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notices/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(notice),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to create notice: ${response.body}',
    );
  }

  static Future<Map<String, dynamic>> updateNotice(
    int noticeId,
    Map<String, dynamic> notice,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notices/$noticeId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(notice),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to update notice: ${response.body}',
    );
  }

  static Future<void> deleteNotice(int noticeId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/notices/$noticeId'),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 204) {
      return;
    }

    throw Exception(
      'Failed to delete notice: ${response.body}',
    );
  }

  // =========================
  // EVENTS
  // =========================

 // =========================
// EVENTS CRUD
// =========================

static Future<List<dynamic>> getEvents() async {
  final response = await http.get(
    Uri.parse('$baseUrl/events/'),
  );

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded;
    }

    throw Exception('Invalid events response');
  }

  throw Exception(
    'Failed to load events: ${response.body}',
  );
}

// CREATE EVENT
static Future<Map<String, dynamic>> createEvent(
  Map<String, dynamic> data,
) async {
  final response = await http.post(
    Uri.parse('$baseUrl/events/'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode == 200 ||
      response.statusCode == 201) {
    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  throw Exception(
    'Failed to create event: ${response.body}',
  );
}

// UPDATE EVENT
static Future<Map<String, dynamic>> updateEvent(
  int eventId,
  Map<String, dynamic> data,
) async {
  final response = await http.put(
    Uri.parse('$baseUrl/events/$eventId'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode == 200) {
    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  throw Exception(
    'Failed to update event: ${response.body}',
  );
}

// DELETE EVENT
static Future<void> deleteEvent(
  int eventId,
) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/events/$eventId'),
  );

  if (response.statusCode == 200 ||
      response.statusCode == 204) {
    return;
  }

  throw Exception(
    'Failed to delete event: ${response.body}',
  );
}

  // =========================
  // COMPLAINTS
  // =========================

  static Future<List<dynamic>> getComplaints() async {
    final response = await http.get(
      Uri.parse('$baseUrl/complaints/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load complaints');
  }

  static Future<Map<String, dynamic>> createComplaint({
    required int studentId,
    int? assignedTo,
    required String title,
    required String description,
    String? complaintType,
    String? priority,
    String? status,
    DateTime? submittedAt,
    DateTime? resolvedAt,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/complaints/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'student_id': studentId,
        'assigned_to': assignedTo,
        'title': title,
        'description': description,
        'complaint_type': complaintType,
        'priority': priority,
        'status': status,
        'submitted_at': submittedAt?.toIso8601String(),
        'resolved_at': resolvedAt?.toIso8601String(),
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to submit complaint: ${response.body}',
    );
  }

  // ============================================================
// UPDATE COMPLAINT
// ============================================================

static Future<Map<String, dynamic>> updateComplaint(
  int complaintId,
  Map<String, dynamic> data,
) async {
  final response = await http.put(
    Uri.parse('$baseUrl/complaints/$complaintId'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode == 200) {
    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  throw Exception(
    'Failed to update complaint: ${response.body}',
  );
}

// ============================================================
// DELETE COMPLAINT
// ============================================================

static Future<void> deleteComplaint(
  int complaintId,
) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/complaints/$complaintId'),
  );

  if (response.statusCode == 200 ||
      response.statusCode == 204) {
    return;
  }

  throw Exception(
    'Failed to delete complaint: ${response.body}',
  );
}

 // =========================
// NOTIFICATIONS
// =========================

static Future<List<dynamic>> getNotifications() async {
  final response = await http.get(
    Uri.parse('$baseUrl/notifications/'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception(
    'Failed to load notifications: ${response.statusCode}',
  );
}

static Future<Map<String, dynamic>> updateNotification({
  required int notificationId,
  required int userId,
  required String title,
  required String message,
  String? notificationType,
  bool isRead = false,
}) async {
  final response = await http.put(
    Uri.parse('$baseUrl/notifications/$notificationId'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'user_id': userId,
      'title': title,
      'message': message,
      'notification_type': notificationType,
      'is_read': isRead,
    }),
  );

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception(
      'Unexpected response while updating notification.',
    );
  }

  throw Exception(
    'Failed to update notification '
    '(${response.statusCode}): ${response.body}',
  );
}

static Future<void> deleteNotification(
  int notificationId,
) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/notifications/$notificationId'),
  );

  if (response.statusCode == 200 ||
      response.statusCode == 204) {
    return;
  }

  throw Exception(
    'Failed to delete notification '
    '(${response.statusCode}): ${response.body}',
  );
}

// =========================
// CREATE NOTIFICATION
// =========================

static Future<Map<String, dynamic>> createNotification({
  required int userId,
  required String title,
  required String message,
  String? notificationType,
  bool isRead = false,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/notifications/'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'user_id': userId,
      'title': title,
      'message': message,
      'notification_type': notificationType,
      'is_read': isRead,
    }),
  );

  if (response.statusCode == 200 ||
      response.statusCode == 201) {
    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception(
      'Unexpected response while creating notification.',
    );
  }

  throw Exception(
    'Failed to create notification '
    '(${response.statusCode}): ${response.body}',
  );
}

  // =========================
  // LEAVE REQUESTS
  // =========================

  static Future<List<dynamic>> getLeaveRequests() async {
    final response = await http.get(
      Uri.parse('$baseUrl/leave-requests/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load leave requests');
  }

  static Future<Map<String, dynamic>> updateLeaveRequest({
    required int leaveId,
    required int userId,
    required String fromDate,
    required String toDate,
    required String reason,
    required String leaveType,
    required String status,
    int? approvedBy,
    String? remarks,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/leave-requests/$leaveId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'from_date': fromDate,
        'to_date': toDate,
        'reason': reason,
        'leave_type': leaveType,
        'status': status,
        'approved_by': approvedBy,
        'remarks': remarks,
      }),
    );

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Failed to update leave request: ${response.body}',
    );
  }

  // =========================
  // PARENT-STUDENT
  // =========================

  static Future<List<dynamic>> getParentStudentLinks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/parent-student/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load parent-student links',
    );
  }

  // =========================
  // USERS
  // =========================

  static Future<List<dynamic>> getUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load users');
  }
// =========================
// ROLES
// =========================

static Future<List<dynamic>> getRoles() async {
  final response = await http.get(
    Uri.parse('$baseUrl/users/roles'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception('Failed to load roles');
}

// =========================
// ROLE CRUD
// =========================

static Future<Map<String, dynamic>> createRole(
  Map<String, dynamic> data,
) async {
  final response = await http.post(
    Uri.parse('$baseUrl/users/roles'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode == 200 ||
      response.statusCode == 201) {
    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  throw Exception(
    'Failed to create role: ${response.body}',
  );
}

static Future<Map<String, dynamic>> updateRole(
  int roleId,
  Map<String, dynamic> data,
) async {
  final response = await http.put(
    Uri.parse('$baseUrl/users/roles/$roleId'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode == 200) {
    return Map<String, dynamic>.from(
      jsonDecode(response.body),
    );
  }

  throw Exception(
    'Failed to update role: ${response.body}',
  );
}

static Future<void> deleteRole(
  int roleId,
) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/users/roles/$roleId'),
  );

  if (response.statusCode != 200 &&
      response.statusCode != 204) {
    throw Exception(
      'Failed to delete role: ${response.body}',
    );
  }
}

  // =========================
  // CONNECTION TEST
  // =========================

  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/students/'),
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
// STUDENT CRUD
// ============================================================

static Future<Map<String, dynamic>> createStudent(
  Map<String, dynamic> data,
) async {
  final response = await http.post(
    Uri.parse('$baseUrl/students/'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode == 200 ||
      response.statusCode == 201) {
    return jsonDecode(response.body);
  }

  throw Exception(
    'Failed to create student: ${response.body}',
  );
}

static Future<Map<String, dynamic>> updateStudent(
  int studentId,
  Map<String, dynamic> data,
) async {
  final response = await http.put(
    Uri.parse('$baseUrl/students/$studentId'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception(
    'Failed to update student: ${response.body}',
  );
}

static Future<void> deleteStudent(
  int studentId,
) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/students/$studentId'),
  );

  if (response.statusCode != 200 &&
      response.statusCode != 204) {
    throw Exception(
      'Failed to delete student: ${response.body}',
    );
  }
}

// ============================================================
// FACULTY CRUD
// ============================================================

static Future<Map<String, dynamic>> createFaculty(
  Map<String, dynamic> data,
) async {
  final response = await http.post(
    Uri.parse('$baseUrl/faculty/'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode == 200 ||
      response.statusCode == 201) {
    return jsonDecode(response.body);
  }

  throw Exception(
    'Failed to create faculty: ${response.body}',
  );
}

static Future<void> deleteFaculty(
  int facultyId,
) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/faculty/$facultyId'),
  );

  if (response.statusCode != 200 &&
      response.statusCode != 204) {
    throw Exception(
      'Failed to delete faculty: ${response.body}',
    );
  }
}

// ============================================================
// PARENT CRUD
// ============================================================

static Future<Map<String, dynamic>> createParent(
  Map<String, dynamic> data,
) async {
  final response = await http.post(
    Uri.parse('$baseUrl/parents/'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode == 200 ||
      response.statusCode == 201) {
    return jsonDecode(response.body);
  }

  throw Exception(
    'Failed to create parent: ${response.body}',
  );
}

static Future<Map<String, dynamic>> updateParent(
  int parentId,
  Map<String, dynamic> data,
) async {
  final response = await http.put(
    Uri.parse('$baseUrl/parents/$parentId'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception(
    'Failed to update parent: ${response.body}',
  );
}

static Future<void> deleteParent(
  int parentId,
) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/parents/$parentId'),
  );

  if (response.statusCode != 200 &&
      response.statusCode != 204) {
    throw Exception(
      'Failed to delete parent: ${response.body}',
    );
  }
}

// ============================================================
// USER MANAGEMENT CRUD
// ============================================================

static Future<Map<String, dynamic>> createUser(
  Map<String, dynamic> data,
) async {
  final response = await http.post(
    Uri.parse('$baseUrl/users/'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode == 200 ||
      response.statusCode == 201) {
    return jsonDecode(response.body);
  }

  throw Exception(
    'Failed to create user: ${response.body}',
  );
}

static Future<Map<String, dynamic>> updateUser(
  int userId,
  Map<String, dynamic> data,
) async {
  final response = await http.put(
    Uri.parse('$baseUrl/users/$userId'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception(
    'Failed to update user: ${response.body}',
  );
}

static Future<void> deleteUser(
  int userId,
) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/users/$userId'),
  );

  if (response.statusCode != 200 &&
      response.statusCode != 204) {
    throw Exception(
      'Failed to delete user: ${response.body}',
    );
  }
}

static Future<Map<String, dynamic>> uploadSubmission({
  required int assignmentId,
  required int studentId,
  required PlatformFile file,
}) async {
  final bytes = file.bytes;

  if (bytes == null || bytes.isEmpty) {
    throw Exception(
      'File data is missing. Please select the file again.',
    );
  }

  final uri = Uri.parse('$baseUrl/submissions/upload');

  final request = http.MultipartRequest('POST', uri);

  request.fields['assignment_id'] = assignmentId.toString();
  request.fields['student_id'] = studentId.toString();

  request.files.add(
    http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: file.name,
      contentType: _getSubmissionContentType(file.name),
    ),
  );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  throw Exception(
    'Upload failed (${response.statusCode}): ${response.body}',
  );
}

static MediaType _getSubmissionContentType(String filename) {
  final extension = filename.split('.').last.toLowerCase();

  switch (extension) {
    case 'pdf':
      return MediaType('application', 'pdf');
    case 'doc':
      return MediaType('application', 'msword');
    case 'docx':
      return MediaType(
        'application',
        'vnd.openxmlformats-officedocument.wordprocessingml.document',
      );
    case 'ppt':
      return MediaType('application', 'vnd.ms-powerpoint');
    case 'pptx':
      return MediaType(
        'application',
        'vnd.openxmlformats-officedocument.presentationml.presentation',
      );
    case 'xls':
      return MediaType('application', 'vnd.ms-excel');
    case 'xlsx':
      return MediaType(
        'application',
        'vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
    case 'zip':
      return MediaType('application', 'zip');
    case 'txt':
      return MediaType('text', 'plain');
    default:
      return MediaType('application', 'octet-stream');
  }
}
}