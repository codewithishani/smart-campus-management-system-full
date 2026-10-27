import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StudentEventsScreen extends StatefulWidget {
  const StudentEventsScreen({super.key});

  @override
  State<StudentEventsScreen> createState() =>
      _StudentEventsScreenState();
}

class _StudentEventsScreenState
    extends State<StudentEventsScreen> {
  List<dynamic> events = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      final data = await ApiService.getEvents();

      if (!mounted) return;

      setState(() {
        events = data;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load campus events.';
      });
    }
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

  String formatTime(dynamic value) {
    if (value == null) {
      return '--';
    }

    final text = value.toString();
    final parts = text.split(':');

    if (parts.length < 2) {
      return text;
    }

    final hour =
        int.tryParse(parts[0]) ?? 0;

    final minute =
        int.tryParse(parts[1]) ?? 0;

    final period =
        hour >= 12 ? 'PM' : 'AM';

    final displayHour =
        hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String getTimeRange(
    Map<String, dynamic> event,
  ) {
    final startTime =
        formatTime(event['start_time']);

    final endTime =
        formatTime(event['end_time']);

    return '$startTime - $endTime';
  }

  IconData getEventIcon(String type) {
    final value = type.toLowerCase();

    if (value.contains('sport')) {
      return Icons.sports;
    }

    if (value.contains('technical') ||
        value.contains('tech')) {
      return Icons.computer;
    }

    if (value.contains('cultur')) {
      return Icons.theater_comedy;
    }

    if (value.contains('coding')) {
      return Icons.code;
    }

    return Icons.event;
  }

  Widget buildEventCard(
    Map<String, dynamic> event,
  ) {
    final title =
        (event['title'] ?? 'Campus Event').toString();

    final description =
        (event['description'] ?? '').toString();

    final eventType =
        (event['event_type'] ?? 'General').toString();

    final eventDate =
        formatDate(event['event_date']);

    final timeRange =
        getTimeRange(event);

    final venue =
        (event['venue'] ?? 'Venue not specified').toString();

    final targetRole =
        (event['target_role'] ?? '').toString();

    final status =
        (event['status'] ?? '').toString();

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              child: Icon(
                getEventIcon(eventType),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  if (description.isNotEmpty)
                    Text(description),

                  if (description.isNotEmpty)
                    const SizedBox(height: 8),

                  Text(
                    'Type: $eventType',
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    'Date: $eventDate',
                  ),

                  const SizedBox(height: 3),

                  Text(
                    'Time: $timeRange',
                  ),

                  const SizedBox(height: 3),

                  Text(
                    'Venue: $venue',
                  ),

                  if (targetRole.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      'For: $targetRole',
                    ),
                  ],

                  if (status.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      'Status: $status',
                    ),
                  ],
                ],
              ),
            ),
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

                  loadEvents();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (events.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadEvents,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),

            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 60,
                  ),

                  SizedBox(height: 12),

                  Text(
                    'No campus events available.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    'Upcoming events will appear here.',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadEvents,
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event =
              Map<String, dynamic>.from(
            events[index] as Map,
          );

          return buildEventCard(event);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Events'),
      ),
      body: buildBody(),
    );
  }
}