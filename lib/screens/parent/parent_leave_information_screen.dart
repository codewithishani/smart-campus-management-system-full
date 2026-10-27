import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ParentLeaveInformationScreen extends StatefulWidget {
final int parentId;

const ParentLeaveInformationScreen(
this.parentId, {
super.key,
});

@override
State<ParentLeaveInformationScreen> createState() =>
_ParentLeaveInformationScreenState();
}

class _ParentLeaveInformationScreenState
extends State<ParentLeaveInformationScreen> {
List<Map<String, dynamic>> leaves = [];
List<Map<String, dynamic>> linkedStudents = [];

int selectedStudentId = 0;

bool isLoading = true;
String? errorMessage;

@override
void initState() {
super.initState();
loadLeaveRequests();
}

Future<void> loadLeaveRequests() async {
try {
final data = await Future.wait([
ApiService.getParentStudentLinks(),
ApiService.getLeaveRequests(),
ApiService.getStudents(),
]);


  final linkData = data[0];
  final leaveData = data[1];
  final studentData = data[2];

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

  final resolvedLeaves = <Map<String, dynamic>>[];

  for (final item in leaveData) {
    if (item is! Map) continue;

    resolvedLeaves.add(
      Map<String, dynamic>.from(item),
    );
  }

  int initialStudentId = 0;

  if (resolvedStudents.isNotEmpty) {
    initialStudentId = getIntValue(
      resolvedStudents.first,
      ['student_id'],
    );
  }

  if (!mounted) return;

  setState(() {
    leaves = resolvedLeaves;
    linkedStudents = resolvedStudents;
    selectedStudentId = initialStudentId;
    isLoading = false;
    errorMessage = null;
  });
} catch (e) {
  if (!mounted) return;

  setState(() {
    isLoading = false;
    errorMessage = 'Unable to load leave information.';
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

Map<String, dynamic>? getSelectedStudent() {
for (final student in linkedStudents) {
if (getIntValue(
student,
['student_id'],
) ==
selectedStudentId) {
return student;
}
}


return null;


}

String getStudentName(int studentId) {
for (final student in linkedStudents) {
if (getIntValue(
student,
['student_id'],
) ==
studentId) {
return getStringValue(
student,
['name'],
defaultValue: 'Student',
);
}
}


return 'Student';


}

List<Map<String, dynamic>> getStudentLeaves() {
final student = getSelectedStudent();

if (student == null) {
  return [];
}

final studentUserId = getIntValue(
  student,
  ['user_id'],
);

if (studentUserId == 0) {
  return [];
}

return leaves.where((leave) {
  final leaveUserId = getIntValue(
    leave,
    ['user_id'],
  );

  return leaveUserId == studentUserId;
}).toList();


}

String formatDate(String value) {
if (value.isEmpty) {
return '';
}


try {
  final date = DateTime.parse(value);

  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();

  return '$day/$month/$year';
} catch (_) {
  return value;
}


}

Color getStatusColor(String status) {
switch (status.toLowerCase()) {
case 'approved':
case 'approve':
return Colors.green;


  case 'rejected':
  case 'reject':
    return Colors.red;

  case 'pending':
    return Colors.orange;

  default:
    return Colors.grey;
}


}

IconData getStatusIcon(String status) {
switch (status.toLowerCase()) {
case 'approved':
case 'approve':
return Icons.check_circle;


  case 'rejected':
  case 'reject':
    return Icons.cancel;

  case 'pending':
    return Icons.pending;

  default:
    return Icons.info;
}

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

        setState(() {
          selectedStudentId = value;
        });
      },
    ),
  ),
);


}

Widget buildLeaveCard(
Map<String, dynamic> leave,
) {
final leaveType = getStringValue(
leave,
[
'leave_type',
'type',
'leave_category',
],
defaultValue: 'Leave Request',
);


final reason = getStringValue(
  leave,
  [
    'reason',
    'description',
    'remarks',
  ],
);

final startDate = getStringValue(
  leave,
  [
    'start_date',
    'from_date',
    'leave_start_date',
  ],
);

final endDate = getStringValue(
  leave,
  [
    'end_date',
    'to_date',
    'leave_end_date',
  ],
);

final status = getStringValue(
  leave,
  ['status'],
  defaultValue: 'Pending',
);

final color = getStatusColor(status);

return Card(
  margin: const EdgeInsets.only(bottom: 12),
  child: Padding(
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              getStatusIcon(status),
              color: color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                leaveType,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (startDate.isNotEmpty || endDate.isNotEmpty)
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${formatDate(startDate)}'
                  '${endDate.isNotEmpty ? ' to ${formatDate(endDate)}' : ''}',
                ),
              ),
            ],
          ),
        if (reason.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Reason: $reason',
          ),
        ],
      ],
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
errorMessage ??
'Unable to load leave information.',
textAlign: TextAlign.center,
),
const SizedBox(height: 18),
ElevatedButton.icon(
onPressed: () {
setState(() {
isLoading = true;
errorMessage = null;
});


            loadLeaveRequests();
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
    onRefresh: loadLeaveRequests,
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

final studentLeaves = getStudentLeaves();

return RefreshIndicator(
  onRefresh: loadLeaveRequests,
  child: ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(16),
    children: [
      buildStudentSelector(),
      Card(
        child: ListTile(
          leading: const CircleAvatar(
            child: Icon(
              Icons.event_available,
            ),
          ),
          title: const Text(
            'Leave Information',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${getStudentName(selectedStudentId)} • '
            '${studentLeaves.length} leave request'
            '${studentLeaves.length == 1 ? '' : 's'}',
          ),
        ),
      ),
      const SizedBox(height: 12),
      if (studentLeaves.isEmpty)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              SizedBox(height: 50),
              Icon(
                Icons.event_available,
                size: 65,
              ),
              SizedBox(height: 16),
              Text(
                'No leave requests found.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Leave request information for this student will appear here.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
      else
        ...studentLeaves.map(buildLeaveCard),
      const SizedBox(height: 20),
    ],
  ),
);

}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text(
'Leave Information',
),
),
body: buildBody(),
);
}
}
