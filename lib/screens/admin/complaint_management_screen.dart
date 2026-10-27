import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ComplaintManagementScreen extends StatefulWidget {
  const ComplaintManagementScreen({super.key});

  @override
  State<ComplaintManagementScreen> createState() =>
      _ComplaintManagementScreenState();
}

class _ComplaintManagementScreenState
    extends State<ComplaintManagementScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _complaints = [];

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  // ============================================================
  // LOAD COMPLAINTS
  // ============================================================

  Future<void> _loadComplaints() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ApiService.getComplaints();

      if (!mounted) return;

      setState(() {
        _complaints = List<dynamic>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _value(
    dynamic item,
    String key, {
    String fallback = '',
  }) {
    if (item is! Map) return fallback;

    final value = item[key];

    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }

    return value.toString();
  }

  int? _complaintId(dynamic complaint) {
    return int.tryParse(
      _value(complaint, 'complaint_id'),
    );
  }

  String _formatDate(String value) {
    if (value.isEmpty) return 'Not available';

    try {
      final date = DateTime.parse(value);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];

      return '${date.day.toString().padLeft(2, '0')} '
          '${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return value;
    }
  }

  String _formatDateTime(String value) {
    if (value.isEmpty) return 'Not available';

    try {
      final date = DateTime.parse(value);
      return '${_formatDate(value)} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value;
    }
  }

  String _pretty(String value) {
    if (value.isEmpty) return 'Not specified';

    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase().replaceAll('_', ' ')) {
      case 'resolved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'rejected':
      case 'closed':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'urgent':
      case 'critical':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  // ============================================================
  // ADD / EDIT COMPLAINT
  // ============================================================

  Future<void> _showComplaintForm({dynamic complaint}) async {
    final isEditing = complaint != null;
    final formKey = GlobalKey<FormState>();

    final studentController = TextEditingController(
      text: isEditing ? _value(complaint, 'student_id') : '',
    );

    final assignedController = TextEditingController(
      text: isEditing
          ? _value(complaint, 'assigned_to')
          : '',
    );

    final titleController = TextEditingController(
      text: isEditing ? _value(complaint, 'title') : '',
    );

    final descriptionController = TextEditingController(
      text: isEditing ? _value(complaint, 'description') : '',
    );

    final submittedAtController = TextEditingController(
      text: isEditing
          ? _value(complaint, 'submitted_at')
          : DateTime.now().toIso8601String(),
    );

    final resolvedAtController = TextEditingController(
      text: isEditing
          ? _value(complaint, 'resolved_at')
          : '',
    );

    const complaintTypes = [
      'Academic',
      'Infrastructure',
      'Hostel',
      'Transport',
      'Fees',
      'Other',
    ];

    const priorities = [
      'Low',
      'Medium',
      'High',
      'Urgent',
    ];

    const statuses = [
      'Pending',
      'In Progress',
      'Resolved',
      'Rejected',
      'Closed',
    ];

    String complaintType = _value(
      complaint,
      'complaint_type',
      fallback: 'Other',
    );

    String priority = _value(
      complaint,
      'priority',
      fallback: 'Medium',
    );

    String status = _value(
      complaint,
      'status',
      fallback: 'Pending',
    );

    if (!complaintTypes.any(
      (e) => e.toLowerCase() == complaintType.toLowerCase(),
    )) {
      complaintType = 'Other';
    } else {
      complaintType = complaintTypes.firstWhere(
        (e) => e.toLowerCase() == complaintType.toLowerCase(),
      );
    }

    if (!priorities.any(
      (e) => e.toLowerCase() == priority.toLowerCase(),
    )) {
      priority = 'Medium';
    } else {
      priority = priorities.firstWhere(
        (e) => e.toLowerCase() == priority.toLowerCase(),
      );
    }

    if (!statuses.any(
      (e) => e.toLowerCase() == status.toLowerCase(),
    )) {
      status = 'Pending';
    } else {
      status = statuses.firstWhere(
        (e) => e.toLowerCase() == status.toLowerCase(),
      );
    }

    bool isSaving = false;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              Future<void> saveComplaint() async {
                if (isSaving) return;

                if (!formKey.currentState!.validate()) {
                  return;
                }

                final studentId = int.tryParse(
                  studentController.text.trim(),
                );

                final assignedText =
                    assignedController.text.trim();

                final assignedTo = assignedText.isEmpty
                    ? null
                    : int.tryParse(assignedText);

                if (studentId == null || studentId <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter a valid student ID.'),
                    ),
                  );
                  return;
                }

                if (assignedText.isNotEmpty &&
                    (assignedTo == null || assignedTo <= 0)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Assigned To must be a valid user ID.',
                      ),
                    ),
                  );
                  return;
                }

                DateTime? submittedAt;
                DateTime? resolvedAt;

                try {
                  submittedAt = DateTime.parse(
                    submittedAtController.text.trim(),
                  );

                  if (resolvedAtController.text.trim().isNotEmpty) {
                    resolvedAt = DateTime.parse(
                      resolvedAtController.text.trim(),
                    );
                  }
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Enter valid ISO date/time values.',
                      ),
                    ),
                  );
                  return;
                }

                final payload = <String, dynamic>{
                  'student_id': studentId,
                  'assigned_to': assignedTo,
                  'title': titleController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'complaint_type': complaintType,
                  'priority': priority.toLowerCase(),
                  'status': status.toLowerCase().replaceAll(' ', '_'),
                  'submitted_at': submittedAt.toIso8601String(),
                  'resolved_at': resolvedAt?.toIso8601String(),
                };

                setDialogState(() {
                  isSaving = true;
                });

                try {
                  if (isEditing) {
                    final id = _complaintId(complaint);

                    if (id == null) {
                      throw Exception('Invalid complaint ID.');
                    }

                    await ApiService.updateComplaint(
                      id,
                      payload,
                    );
                  } else {
                    await ApiService.createComplaint(
                      studentId: studentId,
                      assignedTo: assignedTo,
                      title: titleController.text.trim(),
                      description:
                          descriptionController.text.trim(),
                      complaintType: complaintType,
                      priority: priority.toLowerCase(),
                      status:
                          status.toLowerCase().replaceAll(' ', '_'),
                      submittedAt: submittedAt,
                      resolvedAt: resolvedAt,
                    );
                  }

                  if (!dialogContext.mounted) return;

                  Navigator.of(dialogContext).pop();

                  if (!mounted) return;

                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEditing
                            ? 'Complaint updated successfully.'
                            : 'Complaint created successfully.',
                      ),
                    ),
                  );

                  await _loadComplaints();
                } catch (e) {
                  if (!dialogContext.mounted) return;

                  setDialogState(() {
                    isSaving = false;
                  });

                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Unable to save complaint: $e'),
                    ),
                  );
                }
              }

              return AlertDialog(
                title: Text(
                  isEditing ? 'Edit Complaint' : 'Add Complaint',
                ),
                content: SizedBox(
                  width: 480,
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: studentController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Student ID *',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final id = int.tryParse(
                                value?.trim() ?? '',
                              );

                              if (id == null || id <= 0) {
                                return 'Enter a valid student ID';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: assignedController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Assigned To User ID',
                              prefixIcon: Icon(Icons.assignment_ind),
                              helperText:
                                  'Optional. Leave blank if unassigned.',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: titleController,
                            textCapitalization:
                                TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: 'Complaint Title *',
                              prefixIcon: Icon(Icons.title),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Enter a complaint title';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: descriptionController,
                            textCapitalization:
                                TextCapitalization.sentences,
                            minLines: 3,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              labelText: 'Description *',
                              prefixIcon: Icon(Icons.description),
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Enter a description';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          DropdownButtonFormField<String>(
                            initialValue:complaintType,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Complaint Type',
                              border: OutlineInputBorder(),
                            ),
                            items: complaintTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() {
                                  complaintType = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 12),

                          DropdownButtonFormField<String>(
                           initialValue: priority,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Priority',
                              border: OutlineInputBorder(),
                            ),
                            items: priorities.map((item) {
                              return DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() {
                                  priority = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 12),

                          DropdownButtonFormField<String>(
                           initialValue: status,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(),
                            ),
                            items: statuses.map((item) {
                              return DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() {
                                  status = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: submittedAtController,
                            decoration: const InputDecoration(
                              labelText: 'Submitted At (ISO Date/Time) *',
                              hintText: '2026-10-16T10:30:00',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Submitted date/time is required';
                              }

                              if (DateTime.tryParse(value.trim()) == null) {
                                return 'Enter a valid ISO date/time';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: resolvedAtController,
                            decoration: const InputDecoration(
                              labelText: 'Resolved At (Optional)',
                              hintText: '2026-10-16T12:30:00',
                              prefixIcon: Icon(Icons.check_circle_outline),
                              helperText:
                                  'Leave blank if not resolved.',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return null;
                              }

                              if (DateTime.tryParse(value.trim()) == null) {
                                return 'Enter a valid ISO date/time';
                              }

                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isSaving
                        ? null
                        : () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  FilledButton.icon(
                    onPressed: isSaving ? null : saveComplaint,
                    icon: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      isSaving ? 'Saving...' : 'Save',
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      studentController.dispose();
      assignedController.dispose();
      titleController.dispose();
      descriptionController.dispose();
      submittedAtController.dispose();
      resolvedAtController.dispose();
    }
  }

  // ============================================================
  // DELETE COMPLAINT
  // ============================================================

  Future<void> _deleteComplaint(dynamic complaint) async {
    final id = _complaintId(complaint);

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid complaint ID.'),
        ),
      );
      return;
    }

    final title = _value(
      complaint,
      'title',
      fallback: 'this complaint',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Complaint?'),
          content: Text(
            'Are you sure you want to delete "$title"? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await ApiService.deleteComplaint(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complaint deleted successfully.'),
        ),
      );

      await _loadComplaints();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to delete complaint: $e'),
        ),
      );
    }
  }

  // ============================================================
  // DETAILS
  // ============================================================

  void _showDetails(dynamic complaint) {
    final title = _value(
      complaint,
      'title',
      fallback: 'Complaint Details',
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _detailRow(
                    'Complaint ID',
                    _value(complaint, 'complaint_id'),
                  ),
                  _detailRow(
                    'Student ID',
                    _value(complaint, 'student_id'),
                  ),
                  _detailRow(
                    'Assigned To',
                    _value(
                      complaint,
                      'assigned_to',
                      fallback: 'Unassigned',
                    ),
                  ),
                  _detailRow(
                    'Type',
                    _pretty(_value(complaint, 'complaint_type')),
                  ),
                  _detailRow(
                    'Priority',
                    _pretty(_value(complaint, 'priority')),
                  ),
                  _detailRow(
                    'Status',
                    _pretty(_value(complaint, 'status')),
                  ),
                  _detailRow(
                    'Submitted At',
                    _formatDateTime(
                      _value(complaint, 'submitted_at'),
                    ),
                  ),
                  _detailRow(
                    'Resolved At',
                    _formatDateTime(
                      _value(complaint, 'resolved_at'),
                    ),
                  ),
                  _detailRow(
                    'Description',
                    _value(
                      complaint,
                      'description',
                      fallback: 'No description available',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _showComplaintForm(complaint: complaint);
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(value.isEmpty ? 'Not specified' : value),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _statusChip(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _pretty(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _priorityChip(String priority) {
    if (priority.isEmpty) return const SizedBox.shrink();

    final color = _priorityColor(priority);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${_pretty(priority)} Priority',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // COMPLAINT CARD
  // ============================================================

  Widget _buildComplaintCard(dynamic complaint) {
    if (complaint is! Map) {
      return const SizedBox.shrink();
    }

    final title = _value(
      complaint,
      'title',
      fallback: 'Complaint',
    );

    final description = _value(
      complaint,
      'description',
      fallback: 'No description available',
    );

    final status = _value(
      complaint,
      'status',
      fallback: 'pending',
    );

    final priority = _value(
      complaint,
      'priority',
      fallback: '',
    );

    final studentId = _value(
      complaint,
      'student_id',
      fallback: 'N/A',
    );

    final submittedAt = _value(
      complaint,
      'submitted_at',
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDetails(complaint),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: _statusColor(status)
                        .withValues(alpha: 0.12),
                    child: Icon(
                      Icons.report_problem_outlined,
                      color: _statusColor(status),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Complaint #${_value(complaint, 'complaint_id', fallback: 'N/A')}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Complaint actions',
                    onSelected: (value) {
                      if (value == 'details') {
                        _showDetails(complaint);
                      } else if (value == 'edit') {
                        _showComplaintForm(complaint: complaint);
                      } else if (value == 'delete') {
                        _deleteComplaint(complaint);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'details',
                        child: ListTile(
                          dense: true,
                          leading: Icon(Icons.info_outline),
                          title: Text('View Details'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          dense: true,
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Edit'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          dense: true,
                          leading: Icon(Icons.delete_outline),
                          title: Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _statusChip(status),
                  _priorityChip(priority),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 17,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text('Student ID: $studentId'),
                  ),
                ],
              ),
              if (submittedAt.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Submitted: ${_formatDateTime(submittedAt)}',
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOADING / ERROR / EMPTY
  // ============================================================

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading complaints...'),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to Load Complaints',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? 'An unexpected error occurred.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _loadComplaints,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return RefreshIndicator(
      onRefresh: _loadComplaints,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 100),
          Icon(
            Icons.inbox_outlined,
            size: 72,
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              'No complaints found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 8),
          Center(
            child: Text(
              'Tap Add Complaint to create a record.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAIN BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) return _buildLoading();

    if (_errorMessage != null) return _buildError();

    if (_complaints.isEmpty) return _buildEmpty();

    return RefreshIndicator(
      onRefresh: _loadComplaints,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.support_agent,
                    size: 34,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complaint Management',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_complaints.length} complaint'
                          '${_complaints.length == 1 ? '' : 's'} found',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._complaints.map(_buildComplaintCard),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Management'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadComplaints,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showComplaintForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Complaint'),
      ),
      body: _buildBody(),
    );
  }
}