import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StudentNoticesScreen extends StatefulWidget {
  const StudentNoticesScreen({super.key});

  @override
  State<StudentNoticesScreen> createState() =>
      _StudentNoticesScreenState();
}

class _StudentNoticesScreenState
    extends State<StudentNoticesScreen> {
  List<dynamic> notices = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadNotices();
  }

  Future<void> loadNotices() async {
    try {
      final data = await ApiService.getNotices();

      if (!mounted) return;

      setState(() {
        notices = data;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load notices.';
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

  IconData getNoticeIcon(String type) {
    final value = type.toLowerCase();

    if (value.contains('exam')) {
      return Icons.assignment;
    }

    if (value.contains('event')) {
      return Icons.event;
    }

    if (value.contains('academic')) {
      return Icons.school;
    }

    if (value.contains('attendance')) {
      return Icons.fact_check;
    }

    if (value.contains('assignment')) {
      return Icons.menu_book;
    }

    return Icons.notifications;
  }

  Color getNoticeColor(String type) {
    final value = type.toLowerCase();

    if (value.contains('exam')) {
      return Colors.red;
    }

    if (value.contains('event')) {
      return Colors.blue;
    }

    if (value.contains('academic')) {
      return Colors.green;
    }

    if (value.contains('assignment')) {
      return Colors.orange;
    }

    return Colors.indigo;
  }

  Widget buildNoticeCard(
    Map<String, dynamic> notice,
  ) {
    final title =
        (notice['title'] ?? 'Notice').toString();

    final description =
        (notice['description'] ?? '').toString();

    final noticeType =
        (notice['notice_type'] ?? 'General').toString();

    final publishDate =
        formatDate(notice['publish_date']);

    final expiryDate =
        notice['expiry_date'];

    final status =
        (notice['status'] ?? '').toString();

    final iconColor =
        getNoticeColor(noticeType);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.all(14),

        leading: CircleAvatar(
          child: Icon(
            getNoticeIcon(noticeType),
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
          padding:
              const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(description),

              const SizedBox(height: 8),

              Text(
                'Type: $noticeType',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                'Published: $publishDate',
              ),

              if (expiryDate != null) ...[
                const SizedBox(height: 3),
                Text(
                  'Expires: ${formatDate(expiryDate)}',
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

        isThreeLine: true,
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

                  loadNotices();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (notices.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadNotices,
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
                    'No notices available.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    'New college notices will appear here.',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadNotices,
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(16),
        itemCount: notices.length,
        itemBuilder: (context, index) {
          final notice =
              Map<String, dynamic>.from(
            notices[index] as Map,
          );

          return buildNoticeCard(notice);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notices'),
      ),
      body: buildBody(),
    );
  }
}