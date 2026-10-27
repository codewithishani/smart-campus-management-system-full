
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ParentProfileScreen extends StatefulWidget {
  final int parentId;

  const ParentProfileScreen({
    super.key,
    required this.parentId,
  });

  @override
  State<ParentProfileScreen> createState() =>
      _ParentProfileScreenState();
}

class _ParentProfileScreenState
    extends State<ParentProfileScreen> {
  Map<String, dynamic>? parent;

  List<Map<String, dynamic>> linkedStudents = [];
  List<Map<String, dynamic>> parentLinks = [];

  int selectedStudentId = 0;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final results = await Future.wait([
        ApiService.getParents(),
        ApiService.getParentStudentLinks(),
        ApiService.getStudents(),
      ]);

      final parents = results[0];
      final links = results[1];
      final students = results[2];

      Map<String, dynamic>? foundParent;

      for (final item in parents) {
        if (item is! Map) continue;

        final data = Map<String, dynamic>.from(item);

        final id = getIntValue(
          data,
          ['parent_id', 'id'],
        );

        if (id == widget.parentId) {
          foundParent = data;
          break;
        }
      }

      if (foundParent == null) {
        throw Exception('Parent not found');
      }

      final resolvedLinks = <Map<String, dynamic>>[];
      final studentIds = <int>[];

      for (final item in links) {
        if (item is! Map) continue;

        final link = Map<String, dynamic>.from(item);

        final currentParentId = getIntValue(
          link,
          ['parent_id'],
        );

        if (currentParentId != widget.parentId) {
          continue;
        }

        final studentId = getIntValue(
          link,
          ['student_id'],
        );

        if (studentId == 0) continue;

        resolvedLinks.add(link);

        if (!studentIds.contains(studentId)) {
          studentIds.add(studentId);
        }
      }

      final resolvedStudents = <Map<String, dynamic>>[];

      for (final studentId in studentIds) {
        for (final item in students) {
          if (item is! Map) continue;

          final student = Map<String, dynamic>.from(item);

          final currentStudentId = getIntValue(
            student,
            ['student_id', 'id'],
          );

          if (currentStudentId == studentId) {
            resolvedStudents.add(student);
            break;
          }
        }
      }

      int initialStudentId = 0;

      if (resolvedStudents.isNotEmpty) {
        initialStudentId = getIntValue(
          resolvedStudents.first,
          ['student_id', 'id'],
        );
      }

      if (!mounted) return;

      setState(() {
        parent = foundParent;
        parentLinks = resolvedLinks;
        linkedStudents = resolvedStudents;
        selectedStudentId = initialStudentId;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load parent profile.';
      });
    }
  }

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
    String defaultValue = 'Not available',
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

  String getParentName() {
    if (parent == null) {
      return 'Parent';
    }

    return getStringValue(
      parent!,
      ['name'],
      defaultValue: 'Parent',
    );
  }

  String getParentIdText() {
    return widget.parentId.toString();
  }

  String getEmail() {
    if (parent == null) {
      return 'Not available';
    }

    return getStringValue(
      parent!,
      ['email'],
    );
  }

  String getPhone() {
    if (parent == null) {
      return 'Not available';
    }

    return getStringValue(
      parent!,
      ['phone'],
    );
  }

  String getAddress() {
    if (parent == null) {
      return 'Not available';
    }

    return getStringValue(
      parent!,
      ['address'],
    );
  }

  String getSelectedStudentName() {
    for (final student in linkedStudents) {
      final studentId = getIntValue(
        student,
        ['student_id', 'id'],
      );

      if (studentId == selectedStudentId) {
        return getStringValue(
          student,
          ['name'],
          defaultValue: 'Linked Student',
        );
      }
    }

    return 'No student linked';
  }

  String getSelectedStudentRollNo() {
    for (final student in linkedStudents) {
      final studentId = getIntValue(
        student,
        ['student_id', 'id'],
      );

      if (studentId == selectedStudentId) {
        return getStringValue(
          student,
          ['roll_no'],
          defaultValue: '',
        );
      }
    }

    return '';
  }

  String getSelectedRelationship() {
    for (final link in parentLinks) {
      final studentId = getIntValue(
        link,
        ['student_id'],
      );

      if (studentId == selectedStudentId) {
        return getStringValue(
          link,
          ['relationship_type'],
          defaultValue: 'Not specified',
        );
      }
    }

    return 'Not specified';
  }

  Widget buildStudentSelector() {
    if (linkedStudents.length <= 1) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child:DropdownButtonFormField<int>(
  initialValue: selectedStudentId == 0
      ? null
      : selectedStudentId,
          decoration: const InputDecoration(
            labelText: 'Select Student',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          items: linkedStudents.map((student) {
            final studentId = getIntValue(
              student,
              ['student_id', 'id'],
            );

            final name = getStringValue(
              student,
              ['name'],
              defaultValue: 'Student',
            );

            final rollNo = getStringValue(
              student,
              ['roll_no'],
              defaultValue: '',
            );

            return DropdownMenuItem<int>(
              value: studentId,
              child: Text(
                rollNo.isEmpty
                    ? name
                    : '$name ($rollNo)',
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              selectedStudentId = value;
            });
          },
        ),
      ),
    );
  }

  Widget buildInfoCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 55,
            ),
            const SizedBox(height: 14),
            Text(
              errorMessage ?? 'Unable to load profile.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });

                loadProfile();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfile() {
    return RefreshIndicator(
      onRefresh: loadProfile,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 10),

          const CircleAvatar(
            radius: 48,
            child: Icon(
              Icons.person,
              size: 55,
            ),
          ),

          const SizedBox(height: 16),

          Center(
            child: Text(
              getParentName(),
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 6),

          Center(
            child: Text(
              'Parent ID: ${getParentIdText()}',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 22),

          buildInfoCard(
            'Parent ID',
            getParentIdText(),
            Icons.badge_outlined,
          ),

          buildInfoCard(
            'Email',
            getEmail(),
            Icons.email_outlined,
          ),

          buildInfoCard(
            'Phone',
            getPhone(),
            Icons.phone_outlined,
          ),

          buildInfoCard(
            'Address',
            getAddress(),
            Icons.home_outlined,
          ),

          const SizedBox(height: 6),

          buildStudentSelector(),

          buildInfoCard(
            'Linked Student',
            getSelectedStudentName(),
            Icons.school_outlined,
          ),

          if (getSelectedStudentRollNo().isNotEmpty)
            buildInfoCard(
              'Student Roll No.',
              getSelectedStudentRollNo(),
              Icons.badge_outlined,
            ),

          if (linkedStudents.isNotEmpty)
            buildInfoCard(
              'Relationship',
              getSelectedRelationship(),
              Icons.family_restroom,
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Profile'),
      ),
      body: isLoading
          ? buildLoading()
          : errorMessage != null
              ? buildError()
              : buildProfile(),
    );
  }
}

