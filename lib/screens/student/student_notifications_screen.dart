
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StudentNotificationsScreen extends StatefulWidget {
  final int studentId;

  const StudentNotificationsScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentNotificationsScreen> createState() =>
      _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState
    extends State<StudentNotificationsScreen> {
  List<dynamic> notifications = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      final student =
          await ApiService.getStudent(widget.studentId);

      final data =
          await ApiService.getNotifications();

      if (!mounted) return;

      final studentUserId =
          student['user_id'] ?? student['userId'];

      final studentNotifications = data.where((item) {
        if (item is! Map) {
          return false;
        }

        final notification =
            Map<String, dynamic>.from(item);

        final notificationUserId =
            notification['user_id'] ??
            notification['userId'];

        // User-specific notification.
        if (notificationUserId != null) {
          return notificationUserId.toString() ==
              studentUserId?.toString();
        }

        // General notifications do not belong to
        // a particular user, so they are visible to students.
        final targetRole =
            (notification['target_role'] ??
                    notification['targetRole'] ??
                    notification['role'] ??
                    '')
                .toString()
                .toLowerCase();

        if (targetRole.isEmpty ||
            targetRole == 'all' ||
            targetRole == 'student' ||
            targetRole == 'students') {
          return true;
        }

        return false;
      }).toList();

      setState(() {
        notifications = studentNotifications;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load notifications.';
      });
    }
  }

  String getTitle(
    Map<String, dynamic> notification,
  ) {
    return (notification['title'] ??
            notification['notification_title'] ??
            'Notification')
        .toString();
  }

  String getMessage(
    Map<String, dynamic> notification,
  ) {
    return (notification['message'] ??
            notification['description'] ??
            notification['content'] ??
            '')
        .toString();
  }

  String getType(
    Map<String, dynamic> notification,
  ) {
    return (notification['notification_type'] ??
            notification['type'] ??
            'General')
        .toString();
  }

  String formatDate(dynamic value) {
    if (value == null) {
      return 'Date not available';
    }

    final date =
        DateTime.tryParse(value.toString());

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

  String getDate(
    Map<String, dynamic> notification,
  ) {
    return formatDate(
      notification['created_at'] ??
          notification['notification_date'] ??
          notification['date'] ??
          notification['sent_at'],
    );
  }

  IconData getNotificationIcon(String type) {
    final value = type.toLowerCase();

    if (value.contains('exam')) {
      return Icons.assignment;
    }

    if (value.contains('attendance')) {
      return Icons.fact_check;
    }

    if (value.contains('assignment')) {
      return Icons.menu_book;
    }

    if (value.contains('event')) {
      return Icons.event;
    }

    if (value.contains('academic')) {
      return Icons.school;
    }

    if (value.contains('alert')) {
      return Icons.warning;
    }

    return Icons.notifications;
  }

  Color getNotificationColor(String type) {
    final value = type.toLowerCase();

    if (value.contains('exam')) {
      return Colors.red;
    }

    if (value.contains('attendance')) {
      return Colors.orange;
    }

    if (value.contains('assignment')) {
      return Colors.blue;
    }

    if (value.contains('event')) {
      return Colors.green;
    }

    if (value.contains('academic')) {
      return Colors.purple;
    }

    if (value.contains('alert')) {
      return Colors.redAccent;
    }

    return Colors.indigo;
  }

  Widget buildNotificationCard(
    Map<String, dynamic> notification,
  ) {
    final title = getTitle(notification);
    final message = getMessage(notification);
    final type = getType(notification);
    final date = getDate(notification);

    final iconColor =
        getNotificationColor(type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          child: Icon(
            getNotificationIcon(type),
            color: iconColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              if (message.isNotEmpty)
                Text(message),

              const SizedBox(height: 8),

              Text(
                'Type: $type',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 3),

              Text('Date: $date'),
            ],
          ),
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
            mainAxisAlignment:
                MainAxisAlignment.center,
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

                  loadNotifications();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadNotifications,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),

            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 60,
                  ),

                  SizedBox(height: 12),

                  Text(
                    'No notifications available.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    'New notifications will appear here.',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadNotifications,
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification =
              Map<String, dynamic>.from(
            notifications[index] as Map,
          );

          return buildNotificationCard(
            notification,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: buildBody(),
    );
  }
}

