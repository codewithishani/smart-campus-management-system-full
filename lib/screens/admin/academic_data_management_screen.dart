import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AcademicDataManagementScreen extends StatefulWidget {
  const AcademicDataManagementScreen({super.key});

  @override
  State<AcademicDataManagementScreen> createState() =>
      _AcademicDataManagementScreenState();
}

class _AcademicDataManagementScreenState
    extends State<AcademicDataManagementScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  int _students = 0;
  int _attendance = 0;
  int _assignments = 0;
  int _submissions = 0;
  int _results = 0;
  int _exams = 0;

  @override
  void initState() {
    super.initState();
    _loadAcademicData();
  }

  // ============================================================
  // LOAD ACADEMIC DATA
  // ============================================================

  Future<void> _loadAcademicData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await Future.wait([
        ApiService.getStudents(),
        ApiService.getAttendance(),
        ApiService.getAssignments(),
        ApiService.getSubmissions(),
        ApiService.getResults(),
        ApiService.getExams(),
      ]);

      if (!mounted) return;

      setState(() {
        _students = data[0].length;
        _attendance = data[1].length;
        _assignments = data[2].length;
        _submissions = data[3].length;
        _results = data[4].length;
        _exams = data[5].length;

        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load academic data.\n$e';
      });
    }
  }

  // ============================================================
  // ACADEMIC DATA ITEMS
  // ============================================================

  List<Map<String, dynamic>> _buildAcademicData() {
    return [
      {
        'title': 'Students',
        'value': _students,
        'icon': Icons.people_outline,
        'description': 'Student records in the database',
      },
      {
        'title': 'Attendance Records',
        'value': _attendance,
        'icon': Icons.fact_check_outlined,
        'description': 'Recorded attendance entries',
      },
      {
        'title': 'Assignment Records',
        'value': _assignments,
        'icon': Icons.assignment_outlined,
        'description': 'Available assignments',
      },
      {
        'title': 'Assignment Submissions',
        'value': _submissions,
        'icon': Icons.upload_file_outlined,
        'description': 'Submitted assignment records',
      },
      {
        'title': 'Marks / Results',
        'value': _results,
        'icon': Icons.grade_outlined,
        'description': 'Available result records',
      },
      {
        'title': 'Examinations',
        'value': _exams,
        'icon': Icons.event_note_outlined,
        'description': 'Examination records',
      },
    ];
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildAcademicCard(Map<String, dynamic> item) {
    final title = item['title'] as String;
    final value = item['value'] as int;
    final icon = item['icon'] as IconData;
    final description = item['description'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              child: Icon(icon, size: 25),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 36,
                maxWidth: 100,
              ),
              child: Text(
                value.toString(),
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOADING STATE
  // ============================================================

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading academic data...'),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildError() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to Load Academic Data',
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
            ElevatedButton.icon(
              onPressed: _loadAcademicData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY / DATA LIST
  // ============================================================

  Widget _buildDataList() {
    final academicData = _buildAcademicData();

    return RefreshIndicator(
      onRefresh: _loadAcademicData,
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
                    Icons.analytics_outlined,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Academic Overview',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Summary of available academic records.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...academicData.map(_buildAcademicCard),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh the data.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAIN SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Data'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadAcademicData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoading()
          : _errorMessage != null
              ? _buildError()
              : _buildDataList(),
    );
  }
}