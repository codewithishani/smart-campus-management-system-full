
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StudentComplaintStatusScreen extends StatefulWidget {
  final int studentId;

  const StudentComplaintStatusScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentComplaintStatusScreen> createState() =>
      _StudentComplaintStatusScreenState();
}

class _StudentComplaintStatusScreenState
    extends State<StudentComplaintStatusScreen> {
  List<dynamic> complaints = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadComplaints();
  }

  Future<void> loadComplaints() async {
    try {
      final data = await ApiService.getComplaints();

      if (!mounted) return;

      final studentComplaints = data.where((item) {
        if (item is! Map) {
          return false;
        }

        final complaint = Map<String, dynamic>.from(item);

        final complaintStudentId =
            complaint['student_id'] ??
            complaint['studentId'];

        return complaintStudentId?.toString() ==
            widget.studentId.toString();
      }).toList();

      setState(() {
        complaints = studentComplaints;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load complaint status.';
      });
    }
  }

  Color getStatusColor(String status) {
    final value = status.toLowerCase();

    if (value.contains('resolved') ||
        value.contains('closed') ||
        value.contains('completed')) {
      return Colors.green;
    }

    if (value.contains('progress') ||
        value.contains('processing')) {
      return Colors.orange;
    }

    if (value.contains('rejected')) {
      return Colors.red;
    }

    return Colors.blue;
  }

  IconData getStatusIcon(String status) {
    final value = status.toLowerCase();

    if (value.contains('resolved') ||
        value.contains('closed') ||
        value.contains('completed')) {
      return Icons.check_circle;
    }

    if (value.contains('progress') ||
        value.contains('processing')) {
      return Icons.pending;
    }

    if (value.contains('rejected')) {
      return Icons.cancel;
    }

    return Icons.info;
  }

  String formatDate(dynamic value) {
    if (value == null) {
      return 'Not available';
    }

    final date = DateTime.tryParse(value.toString());

    if (date == null) {
      return value.toString();
    }

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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget buildComplaintCard(
    Map<String, dynamic> complaint,
  ) {
    final complaintId = complaint['complaint_id'] ??
        complaint['complaintId'];

    final title =
        (complaint['title'] ?? 'Complaint').toString();

    final description =
        (complaint['description'] ?? '').toString();

    final complaintType =
        (complaint['complaint_type'] ??
                complaint['complaintType'] ??
                '')
            .toString();

    final priority =
        (complaint['priority'] ?? '').toString();

    final status =
        (complaint['status'] ?? 'Submitted').toString();

    final submittedAt =
        complaint['submitted_at'] ??
        complaint['submittedAt'];

    final resolvedAt =
        complaint['resolved_at'] ??
        complaint['resolvedAt'];

    final statusColor = getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  child: Icon(
                    getStatusIcon(status),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Complaint ID: ${complaintId ?? '-'}',
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Flexible(
                  child: Text(
                    status,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            if (description.isNotEmpty) ...[
              const SizedBox(height: 14),

              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],

            const SizedBox(height: 12),

            if (complaintType.isNotEmpty)
              Text(
                'Type: $complaintType',
              ),

            if (priority.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Priority: $priority',
              ),
            ],

            if (submittedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Submitted: ${formatDate(submittedAt)}',
              ),
            ],

            if (resolvedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Resolved: ${formatDate(resolvedAt)}',
              ),
            ],
          ],
        ),
      ),
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
            mainAxisAlignment: MainAxisAlignment.center,
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
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });

                  loadComplaints();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (complaints.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadComplaints,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),

            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 60,
                  ),

                  SizedBox(height: 12),

                  Text(
                    'No complaints found.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    'Your complaint status will appear here.',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadComplaints,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          final complaint =
              Map<String, dynamic>.from(
            complaints[index] as Map,
          );

          return buildComplaintCard(complaint);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Status'),
      ),
      body: buildBody(),
    );
  }
}
