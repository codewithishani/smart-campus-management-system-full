import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ParentFacultyContactScreen extends StatefulWidget {
final int parentId;

const ParentFacultyContactScreen({
super.key,
required this.parentId,
});

@override
State<ParentFacultyContactScreen> createState() =>
_ParentFacultyContactScreenState();
}

class _ParentFacultyContactScreenState
extends State<ParentFacultyContactScreen> {
List<Map<String, dynamic>> faculty = [];
List<Map<String, dynamic>> allFaculty = [];
List<Map<String, dynamic>> students = [];
List<Map<String, dynamic>> linkedStudents = [];
List<Map<String, dynamic>> classes = [];
List<Map<String, dynamic>> assignments = [];

int selectedStudentId = 0;
int linkedClassId = 0;
int linkedCourseId = 0;

bool isLoading = true;
String? errorMessage;

@override
void initState() {
super.initState();
loadFacultyContacts();
}

Future<void> loadFacultyContacts() async {
try {
final data = await Future.wait([
ApiService.getParentStudentLinks(),
ApiService.getStudents(),
ApiService.getClasses(),
ApiService.getFaculty(),
ApiService.getAssignments(),
]);


  final linkData = data[0];
  final studentData = data[1];
  final classData = data[2];
  final facultyData = data[3];
  final assignmentData = data[4];

  final studentIds = <int>[];

  for (final item in linkData) {
    if (item is! Map) continue;

    final link = Map<String, dynamic>.from(item);

    final parentId = getIntValue(
      link,
      ['parent_id'],
    );

    if (parentId != widget.parentId) {
      continue;
    }

    final studentId = getIntValue(
      link,
      ['student_id'],
    );

    if (studentId != 0 && !studentIds.contains(studentId)) {
      studentIds.add(studentId);
    }
  }

  final resolvedStudents = <Map<String, dynamic>>[];

  for (final item in studentData) {
    if (item is! Map) continue;

    final student = Map<String, dynamic>.from(item);

    final studentId = getIntValue(
      student,
      ['student_id'],
    );

    if (studentIds.contains(studentId)) {
      resolvedStudents.add(student);
    }
  }

  final resolvedClasses = classData
      .whereType<Map>()
      .map(
        (item) => Map<String, dynamic>.from(item),
      )
      .toList();

  final resolvedFaculty = facultyData
      .whereType<Map>()
      .map(
        (item) => Map<String, dynamic>.from(item),
      )
      .toList();

  final resolvedAssignments = assignmentData
      .whereType<Map>()
      .map(
        (item) => Map<String, dynamic>.from(item),
      )
      .toList();

  int initialStudentId = 0;

  if (resolvedStudents.isNotEmpty) {
    initialStudentId = getIntValue(
      resolvedStudents.first,
      ['student_id'],
    );
  }

  if (!mounted) return;

  setState(() {
    students = resolvedStudents;
    linkedStudents = resolvedStudents;
    classes = resolvedClasses;
    allFaculty = resolvedFaculty;
    assignments = resolvedAssignments;
    selectedStudentId = initialStudentId;
    isLoading = false;
    errorMessage = null;
  });

  await updateSelectedStudent(
    initialStudentId,
    resolvedFaculty,
  );
} catch (e) {
  if (!mounted) return;

  setState(() {
    isLoading = false;
    errorMessage = 'Unable to load faculty information.';
  });
}


}

Future<void> updateSelectedStudent(
int studentId,
List<Map<String, dynamic>> facultyData,
) async {
int classId = 0;
int courseId = 0;


for (final student in students) {
  final currentStudentId = getIntValue(
    student,
    ['student_id'],
  );

  if (currentStudentId == studentId) {
    classId = getIntValue(
      student,
      ['class_id'],
    );

    courseId = getIntValue(
      student,
      ['course_id'],
    );

    break;
  }
}

// Students table does not contain class_id in the current schema,
// so resolve the class using course_id and semester.
if (classId == 0 && courseId != 0) {
  int studentSemester = 0;

  for (final student in students) {
    if (getIntValue(
          student,
          ['student_id'],
        ) ==
        studentId) {
      studentSemester = getIntValue(
        student,
        ['semester'],
      );
      break;
    }
  }

  for (final classData in classes) {
    final currentCourseId = getIntValue(
      classData,
      ['course_id'],
    );

    if (currentCourseId != courseId) {
      continue;
    }

    final currentSemester = getIntValue(
      classData,
      ['semester'],
    );

    if (studentSemester == 0 ||
        currentSemester == 0 ||
        currentSemester == studentSemester) {
      classId = getIntValue(
        classData,
        ['class_id'],
      );

      if (classId != 0) {
        break;
      }
    }
  }
}

final facultyIds = <int>{};
final facultyRoles = <int, String>{};

if (classId != 0) {
  for (final classData in classes) {
    final currentClassId = getIntValue(
      classData,
      ['class_id'],
    );

    if (currentClassId != classId) {
      continue;
    }

    final classTeacherId = getIntValue(
      classData,
      ['class_teacher_id'],
    );

    if (classTeacherId != 0) {
      facultyIds.add(classTeacherId);
      facultyRoles[classTeacherId] = 'Class Teacher';
    }

    break;
  }
}

// Faculty assigned to subjects/assignments for this class.
for (final assignment in assignments) {
  final assignmentClassId = getIntValue(
    assignment,
    ['class_id'],
  );

  final assignmentFacultyId = getIntValue(
    assignment,
    ['faculty_id'],
  );

  if (assignmentClassId == classId &&
      assignmentFacultyId != 0) {
    facultyIds.add(assignmentFacultyId);

    if (!facultyRoles.containsKey(assignmentFacultyId)) {
      facultyRoles[assignmentFacultyId] = 'Subject Faculty';
    }
  }
}

final filteredFaculty = <Map<String, dynamic>>[];

for (final facultyMember in facultyData) {
  final facultyId = getIntValue(
    facultyMember,
    ['faculty_id'],
  );

  if (!facultyIds.contains(facultyId)) {
    continue;
  }

  filteredFaculty.add({
    ...facultyMember,
    '_role': facultyRoles[facultyId] ?? 'Faculty',
  });
}

filteredFaculty.sort(
  (a, b) {
    final roleA = getStringValue(
      a,
      ['_role'],
    );

    final roleB = getStringValue(
      b,
      ['_role'],
    );

    if (roleA == 'Class Teacher' &&
        roleB != 'Class Teacher') {
      return -1;
    }

    if (roleA != 'Class Teacher' &&
        roleB == 'Class Teacher') {
      return 1;
    }

    final nameA = getStringValue(
      a,
      ['name'],
    ).toLowerCase();

    final nameB = getStringValue(
      b,
      ['name'],
    ).toLowerCase();

    return nameA.compareTo(nameB);
  },
);

if (!mounted) return;

setState(() {
  selectedStudentId = studentId;
  linkedClassId = classId;
  linkedCourseId = courseId;
  faculty = filteredFaculty;
});


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

String getStudentName(int studentId) {
for (final student in linkedStudents) {
final currentStudentId = getIntValue(
student,
['student_id'],
);


  if (currentStudentId == studentId) {
    return getStringValue(
      student,
      ['name'],
      defaultValue: 'Student',
    );
  }
}

return 'Student';


}

Widget buildStudentSelector() {
if (linkedStudents.length <= 1) {
return const SizedBox.shrink();
}


return Card(
  margin: const EdgeInsets.only(bottom: 12),
  child: Padding(
    padding: const EdgeInsets.all(14),
    child: DropdownButtonFormField<int>(
  initialValue: selectedStudentId == 0
      ? null
      : selectedStudentId,
      decoration: const InputDecoration(
        labelText: 'Select Student',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
      items: linkedStudents.map<DropdownMenuItem<int>>(
        (student) {
          final studentId = getIntValue(
            student,
            ['student_id'],
          );

          final studentName = getStringValue(
            student,
            ['name'],
            defaultValue: 'Student',
          );

          return DropdownMenuItem<int>(
            value: studentId,
            child: Text(studentName),
          );
        },
      ).toList(),
      onChanged: (value) {
        if (value == null) return;

        // Always use the complete faculty list when switching
        // students so the new student's faculty can be resolved.
        updateSelectedStudent(
          value,
          allFaculty,
        );
      },
    ),
  ),
);


}

Widget buildFacultyCard(
Map<String, dynamic> person,
) {
final name = getStringValue(
person,
['name'],
defaultValue: 'Faculty Member',
);


final role = getStringValue(
  person,
  ['_role'],
  defaultValue: 'Faculty',
);

final designation = getStringValue(
  person,
  ['designation'],
);

final email = getStringValue(
  person,
  ['email'],
);

final phone = getStringValue(
  person,
  ['phone'],
);

final employeeId = getStringValue(
  person,
  ['employee_id'],
);

return Card(
  margin: const EdgeInsets.only(bottom: 12),
  child: ListTile(
    contentPadding: const EdgeInsets.all(12),
    leading: const CircleAvatar(
      radius: 27,
      child: Icon(Icons.person),
    ),
    title: Text(
      name,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    subtitle: Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(role),
          if (designation.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(designation),
          ],
          if (employeeId.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text('Employee ID: $employeeId'),
          ],
          if (email.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(email),
          ],
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(phone),
          ],
        ],
      ),
    ),
    trailing: email.isNotEmpty
        ? IconButton(
            icon: const Icon(Icons.email),
            tooltip: 'Email',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Email: $email'),
                ),
              );
            },
          )
        : null,
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
errorMessage ??
'Unable to load faculty information.',
textAlign: TextAlign.center,
),
const SizedBox(height: 18),
ElevatedButton.icon(
onPressed: () {
setState(() {
isLoading = true;
errorMessage = null;
});


            loadFacultyContacts();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    ),
  ),
);


}

Widget buildBody() {
if (isLoading) {
return buildLoading();
}


if (errorMessage != null) {
  return buildError();
}

if (linkedStudents.isEmpty) {
  return RefreshIndicator(
    onRefresh: loadFacultyContacts,
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: const [
        SizedBox(height: 100),
        Icon(
          Icons.link_off,
          size: 70,
        ),
        SizedBox(height: 18),
        Text(
          'No linked student found.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

if (faculty.isEmpty) {
  return RefreshIndicator(
    onRefresh: loadFacultyContacts,
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 100),
        const Icon(
          Icons.people_outline,
          size: 70,
        ),
        const SizedBox(height: 18),
        const Text(
          'No faculty information found.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          linkedClassId == 0
              ? 'A class could not be resolved for ${getStudentName(selectedStudentId)}.'
              : 'No faculty is currently assigned to ${getStudentName(selectedStudentId)}\'s class.',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

return RefreshIndicator(
  onRefresh: loadFacultyContacts,
  child: ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(16),
    children: [
      buildStudentSelector(),
      Card(
        child: ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.school),
          ),
          title: const Text(
            'Faculty Contact',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            getStudentName(selectedStudentId),
          ),
        ),
      ),
      const SizedBox(height: 12),
      ...faculty.map(buildFacultyCard),
      const SizedBox(height: 20),
    ],
  ),
);

}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Faculty Contact'),
),
body: buildBody(),
);
}
}
