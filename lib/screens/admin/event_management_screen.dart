import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class EventManagementScreen extends StatefulWidget {
  const EventManagementScreen({super.key});

  @override
  State<EventManagementScreen> createState() =>
      _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  // ============================================================
  // LOAD EVENTS
  // ============================================================

  Future<void> _loadEvents() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ApiService.getEvents();

      if (!mounted) return;

      setState(() {
        _events = data;
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
  // SAFE VALUE HELPERS
  // ============================================================

  String _getValue(
    dynamic event,
    String key, {
    String fallback = '',
  }) {
    if (event is! Map) return fallback;

    final value = event[key];

    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }

    return value.toString();
  }

  int? _getEventId(dynamic event) {
    final value = _getValue(event, 'event_id');
    return int.tryParse(value);
  }

  String _formatDate(String value) {
    if (value.isEmpty) return 'Date not available';

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

  String _formatTime(String value) {
    if (value.isEmpty) return '';

    try {
      final parts = value.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour % 12 == 0 ? 12 : hour % 12;

      return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return value;
    }
  }

  String _displayValue(String value) {
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

  // ============================================================
  // ADD / EDIT EVENT FORM
  // ============================================================

  Future<void> _showEventForm({dynamic event}) async {
    final isEditing = event != null;

    final formKey = GlobalKey<FormState>();

    final titleController = TextEditingController(
      text: isEditing ? _getValue(event, 'title') : '',
    );

    final descriptionController = TextEditingController(
      text: isEditing ? _getValue(event, 'description') : '',
    );

    final venueController = TextEditingController(
      text: isEditing ? _getValue(event, 'venue') : '',
    );

    final createdByController = TextEditingController(
      text: isEditing ? _getValue(event, 'created_by') : '',
    );

    DateTime selectedDate = DateTime.now();

    final existingDate =
        isEditing ? _getValue(event, 'event_date') : '';

    if (existingDate.isNotEmpty) {
      try {
        selectedDate = DateTime.parse(existingDate);
      } catch (_) {
        // Keep today's date if the existing date is invalid.
      }
    }

    TimeOfDay selectedStartTime = const TimeOfDay(
      hour: 10,
      minute: 0,
    );

    TimeOfDay selectedEndTime = const TimeOfDay(
      hour: 16,
      minute: 0,
    );

    if (isEditing) {
      selectedStartTime = _parseTime(
        _getValue(event, 'start_time'),
        selectedStartTime,
      );

      selectedEndTime = _parseTime(
        _getValue(event, 'end_time'),
        selectedEndTime,
      );
    }

    String selectedEventType = _getValue(
      event,
      'event_type',
      fallback: 'Cultural',
    );

    const eventTypes = [
      'Cultural',
      'Academic',
      'Sports',
      'Workshop',
      'Seminar',
      'Other',
    ];

    if (!eventTypes.contains(selectedEventType)) {
      selectedEventType = 'Other';
    }

    String selectedTargetRole = _getValue(
      event,
      'target_role',
      fallback: 'all',
    );

    const targetRoles = [
      'all',
      'student',
      'faculty',
      'parent',
      'admin',
    ];

    if (!targetRoles.contains(selectedTargetRole)) {
      selectedTargetRole = 'all';
    }

    String selectedStatus = _getValue(
      event,
      'status',
      fallback: 'upcoming',
    );

    const statuses = [
      'upcoming',
      'ongoing',
      'completed',
      'cancelled',
    ];

    if (!statuses.contains(selectedStatus)) {
      selectedStatus = 'upcoming';
    }

    bool isSaving = false;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              Future<void> pickDate() async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (picked != null) {
                  setDialogState(() {
                    selectedDate = picked;
                  });
                }
              }

              Future<void> pickStartTime() async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: selectedStartTime,
                );

                if (picked != null) {
                  setDialogState(() {
                    selectedStartTime = picked;
                  });
                }
              }

              Future<void> pickEndTime() async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: selectedEndTime,
                );

                if (picked != null) {
                  setDialogState(() {
                    selectedEndTime = picked;
                  });
                }
              }

              Future<void> saveEvent() async {
                if (isSaving) return;

                if (!formKey.currentState!.validate()) {
                  return;
                }

                final startMinutes =
                    selectedStartTime.hour * 60 +
                    selectedStartTime.minute;

                final endMinutes =
                    selectedEndTime.hour * 60 +
                    selectedEndTime.minute;

                if (endMinutes <= startMinutes) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'End time must be later than start time.',
                      ),
                    ),
                  );
                  return;
                }

                final createdBy =
                    int.tryParse(createdByController.text.trim());

                if (createdBy == null || createdBy <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Enter a valid Created By user ID.',
                      ),
                    ),
                  );
                  return;
                }

                final eventDate =
                    '${selectedDate.year}-'
                    '${selectedDate.month.toString().padLeft(2, '0')}-'
                    '${selectedDate.day.toString().padLeft(2, '0')}';

                String formatTime(TimeOfDay time) {
                  return '${time.hour.toString().padLeft(2, '0')}:'
                      '${time.minute.toString().padLeft(2, '0')}:00';
                }

                final payload = <String, dynamic>{
                  'created_by': createdBy,
                  'title': titleController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'event_type': selectedEventType,
                  'event_date': eventDate,
                  'start_time': formatTime(selectedStartTime),
                  'end_time': formatTime(selectedEndTime),
                  'venue': venueController.text.trim().isEmpty
                      ? null
                      : venueController.text.trim(),
                  'target_role': selectedTargetRole,
                  'status': selectedStatus,
                };

                setDialogState(() {
                  isSaving = true;
                });

                try {
                  if (isEditing) {
                    final eventId = _getEventId(event);

                    if (eventId == null) {
                      throw Exception('Invalid event ID');
                    }

                    await ApiService.updateEvent(
                      eventId,
                      payload,
                    );
                  } else {
                    await ApiService.createEvent(payload);
                  }

                  if (!dialogContext.mounted) return;

                  Navigator.of(dialogContext).pop();

                  if (!mounted) return;

                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEditing
                            ? 'Event updated successfully.'
                            : 'Event created successfully.',
                      ),
                    ),
                  );

                  await _loadEvents();
                } catch (e) {
                  if (!dialogContext.mounted) return;

                  setDialogState(() {
                    isSaving = false;
                  });

                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Unable to save event: $e',
                      ),
                    ),
                  );
                }
              }

              return AlertDialog(
                title: Text(
                  isEditing ? 'Edit Event' : 'Add Event',
                ),
                content: SizedBox(
                  width: 500,
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: titleController,
                            decoration: const InputDecoration(
                              labelText: 'Event Title *',
                              prefixIcon: Icon(Icons.event),
                              border: OutlineInputBorder(),
                            ),
                            textCapitalization:
                                TextCapitalization.sentences,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Enter an event title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description *',
                              prefixIcon: Icon(Icons.description),
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                            minLines: 2,
                            maxLines: 4,
                            textCapitalization:
                                TextCapitalization.sentences,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Enter a description';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: createdByController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Created By User ID *',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                              helperText:
                                  'Enter an existing user ID from your database.',
                            ),
                            validator: (value) {
                              final id = int.tryParse(
                                value?.trim() ?? '',
                              );

                              if (id == null || id <= 0) {
                                return 'Enter a valid user ID';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          DropdownButtonFormField<String>(
                            initialValue: selectedEventType,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Event Type',
                              border: OutlineInputBorder(),
                            ),
                            items: eventTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() {
                                  selectedEventType = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 14),

                          InkWell(
                            onTap: pickDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Event Date *',
                                prefixIcon:
                                    Icon(Icons.calendar_month),
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _formatDate(
                                  selectedDate.toIso8601String(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: pickStartTime,
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Start Time',
                                      prefixIcon: Icon(Icons.schedule),
                                      border: OutlineInputBorder(),
                                    ),
                                    child: Text(
                                      selectedStartTime.format(context),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: pickEndTime,
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'End Time',
                                      prefixIcon:
                                          Icon(Icons.access_time),
                                      border: OutlineInputBorder(),
                                    ),
                                    child: Text(
                                      selectedEndTime.format(context),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: venueController,
                            decoration: const InputDecoration(
                              labelText: 'Venue',
                              prefixIcon: Icon(Icons.location_on),
                              border: OutlineInputBorder(),
                            ),
                            textCapitalization:
                                TextCapitalization.words,
                          ),
                          const SizedBox(height: 14),

                          DropdownButtonFormField<String>(
                            initialValue:  selectedTargetRole,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Target Audience',
                              prefixIcon: Icon(Icons.groups),
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'all',
                                child: Text('Everyone'),
                              ),
                              DropdownMenuItem(
                                value: 'student',
                                child: Text('Students'),
                              ),
                              DropdownMenuItem(
                                value: 'faculty',
                                child: Text('Faculty'),
                              ),
                              DropdownMenuItem(
                                value: 'parent',
                                child: Text('Parents'),
                              ),
                              DropdownMenuItem(
                                value: 'admin',
                                child: Text('Admins'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() {
                                  selectedTargetRole = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 14),

                          DropdownButtonFormField<String>(
                           initialValue:  selectedStatus,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              prefixIcon: Icon(Icons.flag_outlined),
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'upcoming',
                                child: Text('Upcoming'),
                              ),
                              DropdownMenuItem(
                                value: 'ongoing',
                                child: Text('Ongoing'),
                              ),
                              DropdownMenuItem(
                                value: 'completed',
                                child: Text('Completed'),
                              ),
                              DropdownMenuItem(
                                value: 'cancelled',
                                child: Text('Cancelled'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() {
                                  selectedStatus = value;
                                });
                              }
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
                    onPressed: isSaving ? null : saveEvent,
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
                      isSaving ? 'Saving...' : 'Save Event',
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      titleController.dispose();
      descriptionController.dispose();
      venueController.dispose();
      createdByController.dispose();
    }
  }

  TimeOfDay _parseTime(
    String value,
    TimeOfDay fallback,
  ) {
    try {
      final parts = value.split(':');

      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (_) {
      return fallback;
    }
  }

  // ============================================================
  // DELETE EVENT
  // ============================================================

  Future<void> _deleteEvent(dynamic event) async {
    final eventId = _getEventId(event);

    if (eventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete event: invalid event ID.'),
        ),
      );
      return;
    }

    final title = _getValue(
      event,
      'title',
      fallback: 'this event',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Event?'),
          content: Text(
            'Are you sure you want to delete "$title"? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await ApiService.deleteEvent(eventId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event deleted successfully.'),
        ),
      );

      await _loadEvents();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to delete event: $e'),
        ),
      );
    }
  }

  // ============================================================
  // EVENT DETAILS
  // ============================================================

  void _showEventDetails(dynamic event) {
    final title = _getValue(
      event,
      'title',
      fallback: 'Event Details',
    );

    final description = _getValue(event, 'description');
    final eventId = _getValue(event, 'event_id');
    final createdBy = _getValue(event, 'created_by');
    final eventType = _getValue(event, 'event_type');
    final eventDate = _getValue(event, 'event_date');
    final startTime = _getValue(event, 'start_time');
    final endTime = _getValue(event, 'end_time');
    final venue = _getValue(event, 'venue');
    final targetRole = _getValue(event, 'target_role');
    final status = _getValue(event, 'status');
    final createdAt = _getValue(event, 'created_at');

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _detailRow('Event ID', eventId),
                  _detailRow('Created By User ID', createdBy),
                  _detailRow(
                    'Event Type',
                    _displayValue(eventType),
                  ),
                  _detailRow(
                    'Date',
                    _formatDate(eventDate),
                  ),
                  _detailRow(
                    'Start Time',
                    _formatTime(startTime),
                  ),
                  _detailRow(
                    'End Time',
                    _formatTime(endTime),
                  ),
                  _detailRow('Venue', venue),
                  _detailRow(
                    'Target Audience',
                    _displayValue(targetRole),
                  ),
                  _detailRow(
                    'Status',
                    _displayValue(status),
                  ),
                  _detailRow(
                    'Created At',
                    createdAt.isEmpty
                        ? 'Not available'
                        : createdAt,
                  ),
                  _detailRow(
                    'Description',
                    description,
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
                _showEventForm(event: event);
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
          Text(
            value.isEmpty ? 'Not specified' : value,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EVENT STATUS CHIP
  // ============================================================

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Colors.blue;
      case 'ongoing':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _statusChip(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _displayValue(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // EVENT CARD
  // ============================================================

  Widget _buildEventCard(dynamic event) {
    final title = _getValue(
      event,
      'title',
      fallback: 'Untitled Event',
    );

    final description = _getValue(event, 'description');
    final eventDate = _getValue(event, 'event_date');
    final startTime = _getValue(event, 'start_time');
    final endTime = _getValue(event, 'end_time');
    final venue = _getValue(event, 'venue');
    final eventType = _getValue(event, 'event_type');
    final status = _getValue(
      event,
      'status',
      fallback: 'upcoming',
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showEventDetails(event),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 24,
                    child: Icon(Icons.event_available),
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
                        if (eventType.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _displayValue(eventType),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    tooltip: 'Event actions',
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEventForm(event: event);
                      } else if (value == 'delete') {
                        _deleteEvent(event);
                      } else if (value == 'details') {
                        _showEventDetails(event);
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
              const SizedBox(height: 14),

              if (eventDate.isNotEmpty)
                _eventInfoRow(
                  Icons.calendar_month,
                  _formatDate(eventDate),
                ),

              if (startTime.isNotEmpty || endTime.isNotEmpty)
                _eventInfoRow(
                  Icons.schedule,
                  '${_formatTime(startTime)}'
                  '${startTime.isNotEmpty && endTime.isNotEmpty ? ' - ' : ''}'
                  '${_formatTime(endTime)}',
                ),

              if (venue.isNotEmpty)
                _eventInfoRow(
                  Icons.location_on_outlined,
                  venue,
                ),

              if (description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: _statusChip(status),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _eventInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOADING / ERROR / EMPTY STATES
  // ============================================================

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading events...'),
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
            Text(
              'Unable to Load Events',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? 'An unexpected error occurred.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _loadEvents,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.event_busy_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'No events found.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Tap "Add Event" to create your first event.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAIN UI
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) return _buildLoading();

    if (_errorMessage != null) return _buildError();

    if (_events.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: _loadEvents,
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
                    Icons.event_note,
                    size: 34,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Event Management',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_events.length} event'
                          '${_events.length == 1 ? '' : 's'} available',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          ..._events.map(_buildEventCard),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Management'),
        actions: [
          IconButton(
            tooltip: 'Refresh Events',
            onPressed: _isLoading ? null : _loadEvents,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEventForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
      ),
      body: _buildBody(),
    );
  }
}