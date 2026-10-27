import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'faculty_dashboard.dart';

class FacultyLeaveRequestsScreen extends StatefulWidget {
  const FacultyLeaveRequestsScreen({super.key});

  @override
  State<FacultyLeaveRequestsScreen> createState() =>
      _FacultyLeaveRequestsScreenState();
}

class _FacultyLeaveRequestsScreenState
    extends State<FacultyLeaveRequestsScreen> {
  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> leaveRequests = [];

  int? get facultyId => FacultyDashboard.currentFacultyId;

  int getIntValue(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value is int) {
        return value;
      }

      final parsed = int.tryParse(value?.toString() ?? '');

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

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return defaultValue;
  }

  @override
  void initState() {
    super.initState();
    loadLeaveRequests();
  }

  Future<void> loadLeaveRequests() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (facultyId == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          errorMessage =
              'Faculty session not found. Please login again.';
        });
        return;
      }

      final results = await Future.wait([
        ApiService.getLeaveRequests(),
        ApiService.getFaculty(),
        ApiService.getStudents(),
        ApiService.getClasses(),
        ApiService.getAssignments(),
      ]);

      final leaveData = results[0];
      final facultyData = results[1];
      final studentData = results[2];
      final classData = results[3];
      final assignmentData = results[4];

      final faculties = facultyData
          .map(
            (item) => Map<String, dynamic>.from(item as Map),
          )
          .toList();

      final students = studentData
          .map(
            (item) => Map<String, dynamic>.from(item as Map),
          )
          .toList();

      final classes = classData
          .map(
            (item) => Map<String, dynamic>.from(item as Map),
          )
          .toList();

      final assignments = assignmentData
          .map(
            (item) => Map<String, dynamic>.from(item as Map),
          )
          .toList();

      final currentFaculty = faculties.firstWhere(
        (faculty) {
          return getIntValue(
                faculty,
                [
                  'faculty_id',
                  'id',
                ],
              ) ==
              facultyId;
        },
        orElse: () => <String, dynamic>{},
      );

      if (currentFaculty.isEmpty) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          errorMessage =
              'Faculty information could not be found.';
        });
        return;
      }

      final facultyClassIds = <int>{};

      for (final classData in classes) {
        final classId = getIntValue(
          classData,
          [
            'class_id',
            'id',
          ],
        );

        final classTeacherId = getIntValue(
          classData,
          [
            'class_teacher_id',
          ],
        );

        if (classId > 0 && classTeacherId == facultyId) {
          facultyClassIds.add(classId);
        }
      }

      for (final assignment in assignments) {
        final assignmentFacultyId = getIntValue(
          assignment,
          [
            'faculty_id',
          ],
        );

        final assignmentClassId = getIntValue(
          assignment,
          [
            'class_id',
          ],
        );

        if (assignmentFacultyId == facultyId &&
            assignmentClassId > 0) {
          facultyClassIds.add(assignmentClassId);
        }
      }

      if (facultyClassIds.isEmpty) {
        if (!mounted) return;

        setState(() {
          leaveRequests = [];
          isLoading = false;
        });
        return;
      }

      final facultyCourseIds = classes
          .where(
            (classData) {
              final classId = getIntValue(
                classData,
                [
                  'class_id',
                  'id',
                ],
              );

              return facultyClassIds.contains(classId);
            },
          )
          .map(
            (classData) => getIntValue(
              classData,
              [
                'course_id',
              ],
            ),
          )
          .where((id) => id > 0)
          .toSet();

      final facultyStudentUserIds = students
          .where(
            (student) {
              final studentCourseId = getIntValue(
                student,
                [
                  'course_id',
                ],
              );

              return facultyCourseIds.contains(studentCourseId);
            },
          )
          .map(
            (student) => getIntValue(
              student,
              [
                'user_id',
              ],
            ),
          )
          .where((id) => id > 0)
          .toSet();

      final filteredRequests = leaveData
          .map(
            (item) => Map<String, dynamic>.from(item as Map),
          )
          .where(
            (request) {
              final requestUserId = getIntValue(
                request,
                [
                  'user_id',
                ],
              );

              return facultyStudentUserIds.contains(requestUserId);
            },
          )
          .toList();

      if (!mounted) return;

      setState(() {
        leaveRequests = filteredRequests;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load leave requests. Please check the backend server.';
      });
    }
  }

  int getTotalCount() {
    return leaveRequests.length;
  }

  int getPendingCount() {
    return leaveRequests.where((request) {
      return getStringValue(
            request,
            ['status'],
          ).toLowerCase() ==
          'pending';
    }).length;
  }

  int getApprovedCount() {
    return leaveRequests.where((request) {
      return getStringValue(
            request,
            ['status'],
          ).toLowerCase() ==
          'approved';
    }).length;
  }

  int getRejectedCount() {
    return leaveRequests.where((request) {
      return getStringValue(
            request,
            ['status'],
          ).toLowerCase() ==
          'rejected';
    }).length;
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> updateLeaveStatus({
    required Map<String, dynamic> request,
    required String status,
  }) async {
    final currentFacultyId = facultyId;

    if (currentFacultyId == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Faculty session not found. Please login again.',
          ),
        ),
      );
      return;
    }

    final leaveId = getIntValue(
      request,
      ['leave_id'],
    );

    final userId = getIntValue(
      request,
      ['user_id'],
    );

    final fromDate = getStringValue(
      request,
      ['from_date'],
      defaultValue: '',
    );

    final toDate = getStringValue(
      request,
      ['to_date'],
      defaultValue: '',
    );

    final reason = getStringValue(
      request,
      ['reason'],
      defaultValue: '',
    );

    final leaveType = getStringValue(
      request,
      ['leave_type'],
      defaultValue: '',
    );

    final existingRemarks = getStringValue(
      request,
      ['remarks'],
      defaultValue: '',
    );

    if (leaveId <= 0 || userId <= 0) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid leave request information.',
          ),
        ),
      );
      return;
    }

    try {
      await ApiService.updateLeaveRequest(
        leaveId: leaveId,
        userId: userId,
        fromDate: fromDate,
        toDate: toDate,
        reason: reason,
        leaveType: leaveType,
        status: status,
        approvedBy: currentFacultyId,
        remarks: existingRemarks,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'Approved'
                ? 'Leave request approved successfully.'
                : 'Leave request rejected successfully.',
          ),
        ),
      );

      await loadLeaveRequests();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update leave request: $e',
          ),
        ),
      );
    }
  }

  Future<void> confirmLeaveAction({
    required Map<String, dynamic> request,
    required String status,
  }) async {
    final isApprove = status == 'Approved';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isApprove
                ? 'Approve Leave Request'
                : 'Reject Leave Request',
          ),
          content: Text(
            isApprove
                ? 'Are you sure you want to approve this leave request?'
                : 'Are you sure you want to reject this leave request?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                isApprove ? 'Approve' : 'Reject',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await updateLeaveStatus(
      request: request,
      status: status,
    );
  }

  void showLeaveDetails(
    Map<String, dynamic> request,
  ) {
    final leaveId = getIntValue(
      request,
      ['leave_id'],
    );

    final userId = getIntValue(
      request,
      ['user_id'],
    );

    final leaveType = getStringValue(
      request,
      ['leave_type'],
      defaultValue: '-',
    );

    final fromDate = getStringValue(
      request,
      ['from_date'],
      defaultValue: '-',
    );

    final toDate = getStringValue(
      request,
      ['to_date'],
      defaultValue: '-',
    );

    final reason = getStringValue(
      request,
      ['reason'],
      defaultValue: '-',
    );

    final status = getStringValue(
      request,
      ['status'],
      defaultValue: 'Unknown',
    );

    final remarks = getStringValue(
      request,
      ['remarks'],
      defaultValue: '-',
    );

    final isPending = status.toLowerCase() == 'pending';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Leave Request Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Leave ID: $leaveId',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Student User ID: $userId'),
                const SizedBox(height: 8),
                Text('Leave Type: $leaveType'),
                const SizedBox(height: 8),
                Text('From: $fromDate'),
                const SizedBox(height: 8),
                Text('To: $toDate'),
                const SizedBox(height: 8),
                Text('Reason: $reason'),
                const SizedBox(height: 8),
                Text('Remarks: $remarks'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Status: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor(status)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: getStatusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (isPending) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetContext);

                            confirmLeaveAction(
                              request: request,
                              status: 'Rejected',
                            );
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetContext);

                            confirmLeaveAction(
                              request: request,
                              status: 'Approved',
                            );
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Approve'),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildSummaryCard(
    String title,
    int count,
    IconData icon,
  ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(
                icon,
                size: 26,
              ),
              const SizedBox(height: 6),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLeaveCard(
    Map<String, dynamic> request,
  ) {
    final leaveId = getIntValue(
      request,
      ['leave_id'],
    );

    final userId = getIntValue(
      request,
      ['user_id'],
    );

    final leaveType = getStringValue(
      request,
      ['leave_type'],
      defaultValue: 'Leave',
    );

    final fromDate = getStringValue(
      request,
      ['from_date'],
      defaultValue: '-',
    );

    final toDate = getStringValue(
      request,
      ['to_date'],
      defaultValue: '-',
    );

    final reason = getStringValue(
      request,
      ['reason'],
      defaultValue: '-',
    );

    final status = getStringValue(
      request,
      ['status'],
      defaultValue: 'Unknown',
    );

    final isPending = status.toLowerCase() == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showLeaveDetails(request);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.event_note,
                    size: 26,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      leaveType,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor(status)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: getStatusColor(status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Leave ID: $leaveId',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text('Student User ID: $userId'),
              const SizedBox(height: 5),
              Text('From: $fromDate'),
              Text('To: $toDate'),
              const SizedBox(height: 6),
              Text(
                'Reason: $reason',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              if (isPending)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          confirmLeaveAction(
                            request: request,
                            status: 'Rejected',
                          );
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          confirmLeaveAction(
                            request: request,
                            status: 'Approved',
                          );
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Approve'),
                      ),
                    ),
                  ],
                )
              else
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Tap to view details',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Requests'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: isLoading ? null : loadLeaveRequests,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 50,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: loadLeaveRequests,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadLeaveRequests,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        children: [
                          buildSummaryCard(
                            'Total',
                            getTotalCount(),
                            Icons.list_alt,
                          ),
                          const SizedBox(width: 8),
                          buildSummaryCard(
                            'Pending',
                            getPendingCount(),
                            Icons.pending_actions,
                          ),
                          const SizedBox(width: 8),
                          buildSummaryCard(
                            'Approved',
                            getApprovedCount(),
                            Icons.check_circle_outline,
                          ),
                          const SizedBox(width: 8),
                          buildSummaryCard(
                            'Rejected',
                            getRejectedCount(),
                            Icons.cancel_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (leaveRequests.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: 50,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'No leave requests found.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'There are currently no leave requests available for your assigned students.',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...leaveRequests.map(buildLeaveCard),
                    ],
                  ),
                ),
    );
  }
}