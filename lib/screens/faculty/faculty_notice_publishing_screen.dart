import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../services/api_service.dart';
import 'faculty_dashboard.dart';

class FacultyNoticePublishingScreen extends StatefulWidget {
  const FacultyNoticePublishingScreen({super.key});

  @override
  State<FacultyNoticePublishingScreen> createState() =>
      _FacultyNoticePublishingScreenState();
}

class _FacultyNoticePublishingScreenState
    extends State<FacultyNoticePublishingScreen> {
  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController messageController =
      TextEditingController();

  List<dynamic> notices = [];
  List<dynamic> facultyData = [];

  bool isLoading = true;
  bool isPublishing = false;
  int? deletingNoticeId;

  String? errorMessage;

  int? get facultyId => FacultyDashboard.currentFacultyId;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      if (facultyId == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          errorMessage = 'Faculty session not found.';
        });

        return;
      }

      final results = await Future.wait([
        ApiService.getFaculty(),
        ApiService.getNotices(),
      ]);

      if (!mounted) return;

      setState(() {
        facultyData = results[0];
        notices = results[1];
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

  int getIntValue(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value is int) {
        return value;
      }

      if (value is num) {
        return value.toInt();
      }

      final parsed = int.tryParse(
        value?.toString().trim() ?? '',
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

  Map<String, dynamic>? getCurrentFaculty() {
    final currentId = facultyId;

    if (currentId == null) {
      return null;
    }

    for (final item in facultyData) {
      if (item is! Map) {
        continue;
      }

      final faculty =
          Map<String, dynamic>.from(item);

      final id = getIntValue(
        faculty,
        [
          'faculty_id',
          'id',
          'facultyId',
        ],
      );

      if (id == currentId) {
        return faculty;
      }
    }

    return null;
  }

  int getFacultyUserId() {
    final faculty = getCurrentFaculty();

    if (faculty == null) {
      return 0;
    }

    return getIntValue(
      faculty,
      [
        'user_id',
        'userId',
      ],
    );
  }

  String getFacultyName() {
    final faculty = getCurrentFaculty();

    if (faculty == null) {
      return 'Faculty';
    }

    return getStringValue(
      faculty,
      [
        'name',
        'faculty_name',
        'full_name',
        'facultyName',
      ],
      defaultValue: 'Faculty',
    );
  }

  int getNoticeId(
    Map<String, dynamic> notice,
  ) {
    return getIntValue(
      notice,
      [
        'notice_id',
        'id',
      ],
    );
  }

  String getNoticeTitle(
    Map<String, dynamic> notice,
  ) {
    return getStringValue(
      notice,
      [
        'title',
      ],
      defaultValue: 'Notice',
    );
  }

  String getNoticeDescription(
    Map<String, dynamic> notice,
  ) {
    return getStringValue(
      notice,
      [
        'description',
      ],
    );
  }

  String getNoticeType(
    Map<String, dynamic> notice,
  ) {
    return getStringValue(
      notice,
      [
        'notice_type',
      ],
      defaultValue: 'General',
    );
  }

  String getTargetRole(
    Map<String, dynamic> notice,
  ) {
    return getStringValue(
      notice,
      [
        'target_role',
      ],
      defaultValue: 'Student',
    );
  }

  String getNoticeStatus(
    Map<String, dynamic> notice,
  ) {
    return getStringValue(
      notice,
      [
        'status',
      ],
      defaultValue: 'Published',
    );
  }

  int getNoticeUserId(
    Map<String, dynamic> notice,
  ) {
    return getIntValue(
      notice,
      [
        'user_id',
      ],
    );
  }

  bool isNoticeCreatedByCurrentFaculty(
    Map<String, dynamic> notice,
  ) {
    final currentUserId = getFacultyUserId();

    if (currentUserId <= 0) {
      return false;
    }

    return getNoticeUserId(notice) == currentUserId;
  }

  List<Map<String, dynamic>> getFacultyNotices() {
    final filtered = <Map<String, dynamic>>[];

    for (final item in notices) {
      if (item is! Map) {
        continue;
      }

      final notice =
          Map<String, dynamic>.from(item);

      if (isNoticeCreatedByCurrentFaculty(notice)) {
        filtered.add(notice);
      }
    }

    filtered.sort((a, b) {
      final aDate = getStringValue(
        a,
        [
          'publish_date',
          'created_at',
        ],
      );

      final bDate = getStringValue(
        b,
        [
          'publish_date',
          'created_at',
        ],
      );

      return bDate.compareTo(aDate);
    });

    return filtered;
  }

  String getPublishDate(
    Map<String, dynamic> notice,
  ) {
    final value = getStringValue(
      notice,
      [
        'publish_date',
      ],
    );

    if (value.isEmpty) {
      return 'Date not available';
    }

    try {
      final date = DateTime.parse(value);

      return '${date.day.toString().padLeft(2, '0')} '
          '${_monthName(date.month)} '
          '${date.year}';
    } catch (_) {
      return value;
    }
  }

  String _monthName(int month) {
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

    if (month < 1 || month > 12) {
      return '';
    }

    return months[month - 1];
  }

  String _errorFromResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map &&
          decoded['detail'] != null) {
        return decoded['detail'].toString();
      }
    } catch (_) {}

    return 'Request failed with status ${response.statusCode}.';
  }

  Future<void> publishNotice() async {
    final title = titleController.text.trim();
    final message = messageController.text.trim();

    if (facultyId == null) {
      _showMessage(
        'Faculty session not found.',
      );
      return;
    }

    if (title.isEmpty || message.isEmpty) {
      _showMessage(
        'Please enter both the notice title and message.',
      );
      return;
    }

    final userId = getFacultyUserId();

    if (userId <= 0) {
      _showMessage(
        'Unable to identify the faculty user.',
      );
      return;
    }

    setState(() {
      isPublishing = true;
    });

    try {
      final today = DateTime.now();

      final payload = {
        'user_id': userId,
        'title': title,
        'description': message,
        'notice_type': 'General',
        'target_role': 'Student',
        'publish_date':
            '${today.year.toString().padLeft(4, '0')}-'
            '${today.month.toString().padLeft(2, '0')}-'
            '${today.day.toString().padLeft(2, '0')}',
        'expiry_date': null,
        'status': 'Published',
      };

      final response = await http.post(
        Uri.parse(
          '${ApiService.baseUrl}/notices/',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          _errorFromResponse(response),
        );
      }

      titleController.clear();
      messageController.clear();

      await loadData();

      if (!mounted) return;

      _showMessage(
        'Notice published successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      isPublishing = false;
    });
  }

  Future<void> deleteNotice(
    Map<String, dynamic> notice,
  ) async {
    final noticeId = getNoticeId(notice);

    if (noticeId <= 0) {
      _showMessage('Invalid notice ID.');
      return;
    }

    final shouldDelete =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Notice'),
          content: const Text(
            'Are you sure you want to delete this notice?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() {
      deletingNoticeId = noticeId;
    });

    try {
      final response = await http.delete(
        Uri.parse(
          '${ApiService.baseUrl}/notices/$noticeId',
        ),
      );

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          _errorFromResponse(response),
        );
      }

      await loadData();

      if (!mounted) return;

      _showMessage(
        'Notice deleted successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      deletingNoticeId = null;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  Widget buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildErrorState() {
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
                  'Unable to load notices.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });

                loadData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFacultyInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              child: Icon(Icons.person),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Logged-in Faculty',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    getFacultyName(),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Faculty ID: ${facultyId ?? '-'}',
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPublishForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Publish Notice',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              enabled: !isPublishing,
              decoration: const InputDecoration(
                labelText: 'Notice Title',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              enabled: !isPublishing,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Notice Message',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.campaign),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    isPublishing
                        ? null
                        : publishNotice,
                icon: isPublishing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.publish),
                label: Text(
                  isPublishing
                      ? 'Publishing...'
                      : 'Publish Notice',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildExistingNotices() {
    final facultyNotices =
        getFacultyNotices();

    if (facultyNotices.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(Icons.info_outline),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'You have not published any notices yet.',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'My Published Notices',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...facultyNotices.map(
          (notice) {
            final title =
                getNoticeTitle(notice);

            final description =
                getNoticeDescription(notice);

            final type =
                getNoticeType(notice);

            final target =
                getTargetRole(notice);

            final status =
                getNoticeStatus(notice);

            final publishDate =
                getPublishDate(notice);

            final noticeId =
                getNoticeId(notice);

            final isDeleting =
                deletingNoticeId == noticeId;

            return Card(
              margin:
                  const EdgeInsets.only(
                bottom: 12,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          child: Icon(
                            Icons.campaign_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          onPressed:
                              isDeleting
                                  ? null
                                  : () {
                                      deleteNotice(
                                        notice,
                                      );
                                    },
                          icon: isDeleting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons
                                      .delete_outline,
                                ),
                        ),
                      ],
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(description),
                    ],
                    const SizedBox(height: 10),
                    Text('Type: $type'),
                    Text('Audience: $target'),
                    Text(
                      'Published: $publishDate',
                    ),
                    Text('Status: $status'),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return buildLoadingState();
    }

    if (errorMessage != null) {
      return buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: loadData,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          buildFacultyInfo(),
          const SizedBox(height: 16),
          buildPublishForm(),
          const SizedBox(height: 24),
          buildExistingNotices(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notice Publishing'),
      ),
      body: buildBody(),
    );
  }
}