import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ParentNoticesScreen extends StatefulWidget {
  const ParentNoticesScreen({super.key});

  @override
  State<ParentNoticesScreen> createState() =>
      _ParentNoticesScreenState();
}

class _ParentNoticesScreenState extends State<ParentNoticesScreen> {
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

      final filteredNotices = data.where((item) {
        if (item is! Map) return false;

        final notice = Map<String, dynamic>.from(item);

        final targetRole = getStringValue(
          notice,
          ['target_role', 'target_audience', 'audience'],
        ).trim().toLowerCase();

        // Show notices meant for parents, everyone/general,
        // or notices without a specific target role.
        if (targetRole.isEmpty) {
          return true;
        }

        return targetRole == 'parent' ||
            targetRole == 'parents' ||
            targetRole == 'general' ||
            targetRole == 'all' ||
            targetRole == 'everyone' ||
            targetRole == 'all users' ||
            targetRole == 'all students and parents';
      }).toList();

      if (!mounted) return;

      setState(() {
        notices = filteredNotices;
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

  Widget buildNoticeCard(
    Map<String, dynamic> notice,
  ) {
    final title = getStringValue(
      notice,
      ['title', 'notice_title'],
      defaultValue: 'Notice',
    );

    final description = getStringValue(
      notice,
      [
        'description',
        'message',
        'content',
      ],
      defaultValue: 'No description available.',
    );

    final noticeType = getStringValue(
      notice,
      [
        'notice_type',
        'type',
      ],
      defaultValue: 'General',
    );

    final targetRole = getStringValue(
      notice,
      ['target_role'],
    );

    final publishDate = getStringValue(
      notice,
      [
        'publish_date',
        'created_at',
        'date',
      ],
    );

    final status = getStringValue(
      notice,
      ['status'],
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  child: Icon(Icons.campaign),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Chip(
                  label: Text(noticeType),
                  avatar: const Icon(
                    Icons.info_outline,
                    size: 18,
                  ),
                ),
                if (targetRole.isNotEmpty)
                  Chip(
                    label: Text(targetRole),
                  ),
                if (status.isNotEmpty)
                  Chip(
                    label: Text(status),
                  ),
              ],
            ),
            if (publishDate.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Published: ${formatDate(publishDate)}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
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
              errorMessage ?? 'Unable to load notices.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });

                loadNotices();
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

    if (notices.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadNotices,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 100),
            Icon(
              Icons.campaign_outlined,
              size: 70,
            ),
            SizedBox(height: 18),
            Text(
              'No notices found.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'New college notices for parents will appear here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final noticeList = notices
        .map(
          (item) => Map<String, dynamic>.from(item as Map),
        )
        .toList();

    return RefreshIndicator(
      onRefresh: loadNotices,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.campaign),
              ),
              title: const Text(
                'College Notices',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${noticeList.length} notice${noticeList.length == 1 ? '' : 's'} available',
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...noticeList.map(buildNoticeCard),
          const SizedBox(height: 20),
        ],
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