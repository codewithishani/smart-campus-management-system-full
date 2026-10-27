import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class NoticeManagementScreen extends StatefulWidget {
  const NoticeManagementScreen({super.key});

  @override
  State<NoticeManagementScreen> createState() =>
      _NoticeManagementScreenState();
}

class _NoticeManagementScreenState extends State<NoticeManagementScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  List<dynamic> _notices = [];

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ApiService.getNotices();

      if (!mounted) return;

      setState(() {
        _notices = List<dynamic>.from(data);
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

  String _readValue(
    Map<dynamic, dynamic> item,
    List<String> keys, {
    String fallback = 'N/A',
  }) {
    for (final key in keys) {
      final value = item[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }

  int? _readId(Map<dynamic, dynamic> item) {
    final value = item['notice_id'] ?? item['noticeId'] ?? item['id'];

    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }

  String _title(Map<dynamic, dynamic> item) {
    return _readValue(
      item,
      [
        'title',
        'notice_title',
        'noticeTitle',
        'name',
      ],
      fallback: 'Notice',
    );
  }

  String _content(Map<dynamic, dynamic> item) {
    return _readValue(
      item,
      [
        'content',
        'description',
        'message',
        'notice_content',
        'noticeContent',
      ],
      fallback: 'No content available',
    );
  }

  String _status(Map<dynamic, dynamic> item) {
    return _readValue(
      item,
      [
        'status',
        'notice_status',
        'noticeStatus',
      ],
      fallback: 'Published',
    );
  }

  String _date(Map<dynamic, dynamic> item) {
    return _readValue(
      item,
      [
        'created_at',
        'createdAt',
        'notice_date',
        'noticeDate',
        'date',
      ],
      fallback: 'Date not available',
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return Colors.green;

      case 'draft':
        return Colors.orange;

      case 'archived':
      case 'closed':
        return Colors.grey;

      default:
        return Colors.blue;
    }
  }

  Future<void> _showNoticeDialog({
    Map<dynamic, dynamic>? notice,
  }) async {
    final titleController = TextEditingController(
      text: notice == null ? '' : _title(notice),
    );

    final contentController = TextEditingController(
      text: notice == null ? '' : _content(notice),
    );

    String selectedStatus =
        notice == null ? 'Published' : _status(notice);

    if (![
      'Published',
      'Draft',
      'Archived',
    ].contains(selectedStatus)) {
      selectedStatus = 'Published';
    }

    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogBuilderContext, setDialogState) {
            return AlertDialog(
              title: Text(
                notice == null
                    ? 'Create Notice'
                    : 'Edit Notice',
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
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter notice title';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: contentController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Content',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter notice content';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Published',
                              child: Text('Published'),
                            ),
                            DropdownMenuItem(
                              value: 'Draft',
                              child: Text('Draft'),
                            ),
                            DropdownMenuItem(
                              value: 'Archived',
                              child: Text('Archived'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;

                            setDialogState(() {
                              selectedStatus = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    try {
                      final noticeId =
                          notice == null ? null : _readId(notice);

                      if (notice != null && noticeId == null) {
                        throw Exception(
                          'Notice ID is missing',
                        );
                      }

                      if (notice == null) {
                        await ApiService.createNotice({
                          'title': titleController.text.trim(),
                          'content': contentController.text.trim(),
                          'status': selectedStatus,
                        });
                      } else {
                        await ApiService.updateNotice(
                          noticeId!,
                          {
                            'title': titleController.text.trim(),
                            'content': contentController.text.trim(),
                            'status': selectedStatus,
                          },
                        );
                      }

                      if (!mounted) return;

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            notice == null
                                ? 'Notice created successfully'
                                : 'Notice updated successfully',
                          ),
                        ),
                      );

                      await _loadNotices();
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Operation failed: $e',
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    notice == null ? 'Create' : 'Update',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    contentController.dispose();
  }

  Future<void> _deleteNotice(
    Map<dynamic, dynamic> notice,
  ) async {
    final noticeId = _readId(notice);

    if (noticeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notice ID is missing'),
        ),
      );
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Notice'),
          content: Text(
            'Are you sure you want to delete "${_title(notice)}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
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

    try {
      await ApiService.deleteNotice(noticeId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notice deleted successfully'),
        ),
      );

      await _loadNotices();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete notice: $e'),
        ),
      );
    }
  }

  Widget _buildNoticeCard(dynamic value) {
    if (value is! Map) {
      return const SizedBox.shrink();
    }

    final notice = Map<dynamic, dynamic>.from(value);

    final title = _title(notice);
    final content = _content(notice);
    final status = _status(notice);
    final date = _date(notice);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(
          child: Icon(Icons.campaign_outlined),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(status).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        color: _statusColor(status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (menuValue) {
            if (menuValue == 'edit') {
              _showNoticeDialog(notice: notice);
            } else if (menuValue == 'delete') {
              _deleteNotice(notice);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to load notices',
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
                onPressed: _loadNotices,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_notices.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadNotices,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Center(
              child: Icon(
                Icons.campaign_outlined,
                size: 64,
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'No notices found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotices,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _notices.length,
        itemBuilder: (context, index) {
          return _buildNoticeCard(_notices[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notice Management'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadNotices,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNoticeDialog();
        },
        child: const Icon(Icons.add),
      ),
      body: _buildBody(),
    );
  }
}