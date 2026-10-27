import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StudentProfileScreen extends StatefulWidget {
  final int studentId;

  const StudentProfileScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentProfileScreen> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  Map<String, dynamic>? studentData;
  bool isLoading = true;
  String? errorMessage;

  Future<void> loadStudent() async {
    try {
      final data = await ApiService.getStudent(widget.studentId);

      if (!mounted) {
        return;
      }

      setState(() {
        studentData = data;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load student profile.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadStudent();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (studentData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Student Profile'),
        ),
        body: Center(
          child: Text(
            errorMessage ?? 'Unable to load student profile.',
          ),
        ),
      );
    }

    final name = studentData!['name'] ?? 'N/A';
    final email = studentData!['email'] ?? 'N/A';
    final phone = studentData!['phone'] ?? 'N/A';
    final rollNo = studentData!['roll_no'] ?? 'N/A';
    final semester =
        studentData!['semester']?.toString() ?? 'N/A';
    final departmentId =
        studentData!['department_id']?.toString() ?? 'N/A';
    final courseId =
        studentData!['course_id']?.toString() ?? 'N/A';
    final address = studentData!['address'] ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
      ),
      body: RefreshIndicator(
        onRefresh: loadStudent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 48,
                child: Icon(
                  Icons.person,
                  size: 55,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text('Student ID: ${widget.studentId}'),
              Text('Roll Number: $rollNo'),
              const SizedBox(height: 20),

              _section(
                'Personal Information',
                [
                  _row(
                    Icons.person,
                    'Name',
                    name,
                  ),
                  _row(
                    Icons.email,
                    'Email',
                    email,
                  ),
                  _row(
                    Icons.phone,
                    'Phone',
                    phone,
                  ),
                  _row(
                    Icons.location_on,
                    'Address',
                    address,
                  ),
                ],
              ),

              _section(
                'Academic Information',
                [
                  _row(
                    Icons.school,
                    'Course',
                    'Course ID: $courseId',
                  ),
                  _row(
                    Icons.calendar_month,
                    'Semester',
                    semester,
                  ),
                  _row(
                    Icons.apartment,
                    'Department',
                    'Department ID: $departmentId',
                  ),
                  _row(
                    Icons.badge,
                    'Roll Number',
                    rollNo,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _section(
    String title,
    List<Widget> children,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  static Widget _row(
    IconData icon,
    String title,
    String value,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}