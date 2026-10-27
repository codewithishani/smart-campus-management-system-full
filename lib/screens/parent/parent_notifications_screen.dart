import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ParentNotificationsScreen extends StatefulWidget {
  final int parentId;

  const ParentNotificationsScreen({
    super.key,
    required this.parentId,
  });

  @override
  State<ParentNotificationsScreen> createState() =>
      _ParentNotificationsScreenState();
}

class _ParentNotificationsScreenState
    extends State<ParentNotificationsScreen> {
  List<Map<String, dynamic>> notifications = [];

  int parentUserId = 0;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      final data = await Future.wait([
        ApiService.getNotifications(),
        ApiService.getParents(),
      ]);

      final notificationData = data[0];
      final parentData = data[1];

      int resolvedParentUserId = 0;

      for (final item in parentData) {
        if (item is! Map) continue;

        final parent = Map<String, dynamic>.from(item);

        final currentParentId = getIntValue(
          parent,
          ['parent_id'],
        );

        if (currentParentId == widget.parentId) {
          resolvedParentUserId = getIntValue(
            parent,
            ['user_id'],
          );
          break;
        }
      }

      if (resolvedParentUserId == 0) {
        throw Exception(
          'Parent user account not found.',
        );
      }

      final filteredNotifications =
          <Map<String, dynamic>>[];

      for (final item in notificationData) {
        if (item is! Map) continue;

        final notification =
            Map<String, dynamic>.from(item);

        final notificationUserId = getIntValue(
          notification,
          [
            'user_id',
            'recipient_user_id',
            'receiver_user_id',
          ],
        );

        if (notificationUserId == resolvedParentUserId) {
          filteredNotifications.add(
            notification,
          );
        }
      }

      filteredNotifications.sort(
        (a, b) {
          final dateA = getStringValue(
            a,
            [
              'created_at',
              'notification_date',
              'date',
              'created_on',
            ],
          );

          final dateB = getStringValue(
            b,
            [
              'created_at',
              'notification_date',
              'date',
              'created_on',
            ],
          );

          final parsedA = DateTime.tryParse(dateA);
          final parsedB = DateTime.tryParse(dateB);

          if (parsedA == null && parsedB == null) {
            return 0;
          }

          if (parsedA == null) {
            return 1;
          }

          if (parsedB == null) {
            return -1;
          }

          return parsedB.compareTo(parsedA);
        },
      );

      if (!mounted) return;

      setState(() {
        parentUserId = resolvedParentUserId;
        notifications = filteredNotifications;
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

  String formatDateTime(String value) {
    if (value.isEmpty) {
      return '';
    }

    try {
      final date = DateTime.parse(value);

      final day =
          date.day.toString().padLeft(2, '0');
      final month =
          date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      final hour = date.hour == 0
          ? 12
          : date.hour > 12
              ? date.hour - 12
              : date.hour;

      final minute =
          date.minute.toString().padLeft(2, '0');

      final period =
          date.hour >= 12 ? 'PM' : 'AM';

      return '$day/$month/$year '
          '$hour:$minute $period';
    } catch (_) {
      return value;
    }
  }

  String getNotificationTitle(
    Map<String, dynamic> notification,
  ) {
    return getStringValue(
      notification,
      [
        'title',
        'notification_title',
        'subject',
      ],
      defaultValue: 'Notification',
    );
  }

  String getNotificationMessage(
    Map<String, dynamic> notification,
  ) {
    return getStringValue(
      notification,
      [
        'message',
        'description',
        'content',
        'notification_message',
      ],
      defaultValue:
          'You have a new notification.',
    );
  }

  String getNotificationType(
    Map<String, dynamic> notification,
  ) {
    return getStringValue(
      notification,
      [
        'notification_type',
        'type',
        'category',
      ],
      defaultValue: 'General',
    );
  }

  String getNotificationDate(
    Map<String, dynamic> notification,
  ) {
    return getStringValue(
      notification,
      [
        'created_at',
        'notification_date',
        'date',
        'created_on',
      ],
    );
  }

  IconData getNotificationIcon(String type) {
    final value = type.toLowerCase();

    if (value.contains('assignment')) {
      return Icons.assignment;
    }

    if (value.contains('attendance')) {
      return Icons.fact_check;
    }

    if (value.contains('exam')) {
      return Icons.event_note;
    }

    if (value.contains('notice')) {
      return Icons.campaign;
    }

    if (value.contains('leave')) {
      return Icons.event_busy;
    }

    if (value.contains('result') ||
        value.contains('mark')) {
      return Icons.assessment;
    }

    return Icons.notifications;
  }

  Widget buildNotificationCard(
    Map<String, dynamic> notification,
  ) {
    final title =
        getNotificationTitle(notification);

    final message =
        getNotificationMessage(notification);

    final type =
        getNotificationType(notification);

    final date =
        getNotificationDate(notification);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.all(12),
        leading: CircleAvatar(
          child: Icon(
            getNotificationIcon(type),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(
            top: 6,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (date.isNotEmpty) ...[
                    const Text(' • '),
                    Text(
                      formatDateTime(date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ],
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
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 55,
            ),
            const SizedBox(height: 14),
            Text(
              errorMessage ??
                  'Unable to load notifications.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });

                loadNotifications();
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

    if (notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadNotifications,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 100),
            Icon(
              Icons.notifications_none,
              size: 70,
            ),
            SizedBox(height: 18),
            Text(
              'No notifications found.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Notifications sent to this parent will appear here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadNotifications,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(
                  Icons.notifications,
                ),
              ),
              title: const Text(
                'Notifications',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${notifications.length} notification'
                '${notifications.length == 1 ? '' : 's'} available',
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...notifications.map(
            buildNotificationCard,
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
        title: const Text(
          'Notifications',
        ),
      ),
      body: buildBody(),
    );
  }
}