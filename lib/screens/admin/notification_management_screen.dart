import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class NotificationManagementScreen extends StatefulWidget {
  const NotificationManagementScreen({super.key});

  @override
  State<NotificationManagementScreen> createState() =>
      _NotificationManagementScreenState();
}

class _NotificationManagementScreenState
    extends State<NotificationManagementScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  String _searchQuery = '';
  String _filter = 'All';

  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // =========================
  // LOAD NOTIFICATIONS
  // =========================

  Future<void> _loadNotifications() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ApiService.getNotifications();

      if (!mounted) return;

      setState(() {
        _notifications = List<dynamic>.from(data);
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

  // =========================
  // HELPER METHODS
  // =========================

  String _value(
    Map<dynamic, dynamic> item,
    String key, {
    String fallback = '',
  }) {
    final value = item[key];

    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }

    return value.toString();
  }

  int? _intValue(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  bool _isRead(Map<dynamic, dynamic> item) {
    final value = item['is_read'];

    if (value is bool) return value;

    return value?.toString().toLowerCase() == 'true';
  }

  String _formatDate(String value) {
    if (value.isEmpty) {
      return 'Date unavailable';
    }

    final date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    final localDate = date.toLocal();

    String twoDigits(int number) {
      return number.toString().padLeft(2, '0');
    }

    return '${twoDigits(localDate.day)}/'
        '${twoDigits(localDate.month)}/'
        '${localDate.year} '
        '${twoDigits(localDate.hour)}:'
        '${twoDigits(localDate.minute)}';
  }

  Color _statusColor(bool isRead) {
    return isRead ? Colors.green : Colors.orange;
  }

  // =========================
  // SEARCH AND FILTER
  // =========================

  List<dynamic> get _filteredNotifications {
    final query = _searchQuery.trim().toLowerCase();

    return _notifications.where((notification) {
      if (notification is! Map) {
        return false;
      }

      final title = _value(
        notification,
        'title',
      ).toLowerCase();

      final message = _value(
        notification,
        'message',
      ).toLowerCase();

      final type = _value(
        notification,
        'notification_type',
      ).toLowerCase();

      final userId = _value(
        notification,
        'user_id',
      );

      final matchesSearch = query.isEmpty ||
          title.contains(query) ||
          message.contains(query) ||
          type.contains(query) ||
          userId.contains(query);

      final isRead = _isRead(notification);

      final matchesFilter = _filter == 'All' ||
          (_filter == 'Read' && isRead) ||
          (_filter == 'Unread' && !isRead);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  // =========================
  // ADD / EDIT NOTIFICATION
  // =========================

  Future<void> _showNotificationDialog({
    Map<dynamic, dynamic>? notification,
  }) async {
    final bool isEditing = notification != null;

    final formKey = GlobalKey<FormState>();

    final userIdController = TextEditingController(
      text: isEditing ? _value(notification, 'user_id') : '',
    );

    final titleController = TextEditingController(
      text: isEditing ? _value(notification, 'title') : '',
    );

    final messageController = TextEditingController(
      text: isEditing ? _value(notification, 'message') : '',
    );

    final typeController = TextEditingController(
      text: isEditing
          ? _value(notification, 'notification_type')
          : '',
    );

    bool isRead = isEditing ? _isRead(notification) : false;
    bool isSaving = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEditing
                    ? 'Edit Notification'
                    : 'Create Notification',
              ),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // USER ID
                        TextFormField(
                          controller: userIdController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'User ID *',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final id = int.tryParse(
                              value?.trim() ?? '',
                            );

                            if (id == null || id <= 0) {
                              return 'Enter a valid User ID';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // TITLE
                        TextFormField(
                          controller: titleController,
                          maxLength: 150,
                          decoration: const InputDecoration(
                            labelText: 'Title *',
                            prefixIcon: Icon(Icons.title),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Title is required';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 8),

                        // MESSAGE
                        TextFormField(
                          controller: messageController,
                          minLines: 3,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Message *',
                            alignLabelWithHint: true,
                            prefixIcon: Icon(
                              Icons.message_outlined,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Message is required';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // NOTIFICATION TYPE
                        TextFormField(
                          controller: typeController,
                          decoration: const InputDecoration(
                            labelText: 'Notification Type',
                            hintText: 'General, Academic, Attendance',
                            prefixIcon: Icon(
                              Icons.category_outlined,
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // READ STATUS
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Mark as read'),
                          subtitle: Text(
                            isRead
                                ? 'Notification is read'
                                : 'Notification is unread',
                          ),
                          value: isRead,
                          onChanged: (value) {
                            setDialogState(() {
                              isRead = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                // CANCEL
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop(false);
                        },
                  child: const Text('Cancel'),
                ),

                // SAVE
                FilledButton.icon(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          final userId = int.tryParse(
                            userIdController.text.trim(),
                          );

                          if (userId == null) {
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            final title =
                                titleController.text.trim();

                            final message =
                                messageController.text.trim();

                            final type =
                                typeController.text.trim();

                            if (isEditing) {
                              final notificationId = _intValue(
                                notification['notification_id'],
                              );

                              if (notificationId == null) {
                                throw Exception(
                                  'Notification ID is missing.',
                                );
                              }

                              await ApiService.updateNotification(
                                notificationId: notificationId,
                                userId: userId,
                                title: title,
                                message: message,
                                notificationType:
                                    type.isEmpty ? null : type,
                                isRead: isRead,
                              );
                            } else {
                              await ApiService.createNotification(
                                userId: userId,
                                title: title,
                                message: message,
                                notificationType:
                                    type.isEmpty ? null : type,
                                isRead: isRead,
                              );
                            }

                            if (!dialogContext.mounted) {
                              return;
                            }

                            Navigator.of(dialogContext).pop(true);
                          } catch (e) {
                            setDialogState(() {
                              isSaving = false;
                            });

                            ScaffoldMessenger.of(
                              dialogContext,
                            ).showSnackBar(
                              SnackBar(
                                content: Text('Save failed: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
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

    userIdController.dispose();
    titleController.dispose();
    messageController.dispose();
    typeController.dispose();

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Notification updated successfully'
                : 'Notification created successfully',
          ),
        ),
      );

      await _loadNotifications();
    }
  }

  // =========================
  // DELETE NOTIFICATION
  // =========================

  Future<void> _deleteNotification(
    Map<dynamic, dynamic> notification,
  ) async {
    final notificationId = _intValue(
      notification['notification_id'],
    );

    if (notificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification ID is missing'),
        ),
      );

      return;
    }

    final title = _value(
      notification,
      'title',
      fallback: 'this notification',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Notification?'),
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

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await ApiService.deleteNotification(notificationId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification deleted successfully'),
        ),
      );

      await _loadNotifications();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================
  // NOTIFICATION CARD
  // =========================

  Widget _buildNotificationCard(dynamic item) {
    if (item is! Map) {
      return const SizedBox.shrink();
    }

    final title = _value(
      item,
      'title',
      fallback: 'Notification',
    );

    final message = _value(
      item,
      'message',
      fallback: 'No message available',
    );

    final type = _value(
      item,
      'notification_type',
      fallback: 'General',
    );

    final userId = _value(
      item,
      'user_id',
      fallback: 'N/A',
    );

    final date = _formatDate(
      _value(item, 'created_at'),
    );

    final notificationId = _value(
      item,
      'notification_id',
      fallback: 'N/A',
    );

    final isRead = _isRead(item);
    final color = _statusColor(isRead);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.5),
                child: Icon(
                  isRead
                      ? Icons.mark_email_read_outlined
                      : Icons.notifications_active_outlined,
                  color: color,
                ),
              ),
              title: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(message),
              ),
              trailing: PopupMenuButton<String>(
                tooltip: 'Notification actions',
                onSelected: (value) {
                  if (value == 'edit') {
                    _showNotificationDialog(
                      notification: item,
                    );
                  } else if (value == 'delete') {
                    _deleteNotification(item);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _infoChip(
                  Icons.person_outline,
                  'User ID: $userId',
                ),
                _infoChip(
                  Icons.category_outlined,
                  type,
                ),
                _infoChip(
                  Icons.access_time,
                  date,
                ),
                _infoChip(
                  Icons.tag,
                  'ID: $notificationId',
                ),
                _infoChip(
                  isRead
                      ? Icons.mark_email_read
                      : Icons.mark_email_unread,
                  isRead ? 'Read' : 'Unread',
                  color: color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // INFORMATION CHIP
  // =========================

  Widget _infoChip(
    IconData icon,
    String label, {
    Color? color,
  }) {
    final chipColor = color ?? Colors.blueGrey;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: chipColor,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // BODY
  // =========================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 56,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to load notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadNotifications,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final notifications = _filteredNotifications;

    return Column(
      children: [
        // SEARCH
        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            8,
          ),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search notifications...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // FILTER
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'All',
                  label: Text('All'),
                  icon: Icon(Icons.notifications_outlined),
                ),
                ButtonSegment(
                  value: 'Unread',
                  label: Text('Unread'),
                  icon: Icon(Icons.mark_email_unread_outlined),
                ),
                ButtonSegment(
                  value: 'Read',
                  label: Text('Read'),
                  icon: Icon(Icons.mark_email_read_outlined),
                ),
              ],
              selected: {_filter},
              onSelectionChanged: (selection) {
                setState(() {
                  _filter = selection.first;
                });
              },
            ),
          ),
        ),

        // COUNT
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${notifications.length} notification(s)',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        // LIST
        Expanded(
          child: notifications.isEmpty
              ? RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 110),
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                      ),
                      SizedBox(height: 12),
                      Center(
                        child: Text(
                          'No matching notifications found',
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(
                        notifications[index],
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Management'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading
                ? null
                : _loadNotifications,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNotificationDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Notification'),
      ),
      body: _buildBody(),
    );
  }
}