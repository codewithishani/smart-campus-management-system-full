import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/api_service.dart';

class StudentNotesScreen extends StatefulWidget {
  final int studentId;

  const StudentNotesScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentNotesScreen> createState() =>
      _StudentNotesScreenState();
}

class _StudentNotesScreenState
    extends State<StudentNotesScreen> {
  List<dynamic> notes = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final results = await Future.wait([
        ApiService.getStudent(widget.studentId),
        ApiService.getSubjects(),
        ApiService.getNotes(),
      ]);

      final student =
          results[0] as Map<String, dynamic>;

      final allSubjects =
          results[1] as List<dynamic>;

      final allNotes =
          results[2] as List<dynamic>;

      final studentCourseId = student['course_id'];
      final studentSemester = student['semester'];

      final studentSubjectIds = allSubjects
          .where((subject) {
        if (subject is! Map) {
          return false;
        }

        final subjectData =
            Map<String, dynamic>.from(subject);

        final courseMatches =
            subjectData['course_id']?.toString() ==
                studentCourseId?.toString();

        final semester =
            subjectData['semester'];

        final semesterMatches =
            semester == null ||
            semester.toString().isEmpty ||
            semester.toString() ==
                studentSemester?.toString();

        return courseMatches && semesterMatches;
      })
          .map((subject) {
        final subjectData =
            Map<String, dynamic>.from(subject as Map);

        return subjectData['subject_id'];
      })
          .where((id) => id != null)
          .map((id) => id.toString())
          .toSet();

      final filteredNotes = allNotes.where((note) {
        if (note is! Map) {
          return false;
        }

        final noteData =
            Map<String, dynamic>.from(note);

        final noteStudentId =
            noteData['student_id'] ??
            noteData['studentId'];

        if (noteStudentId != null) {
          return noteStudentId.toString() ==
              widget.studentId.toString();
        }

        final noteSubjectId =
            noteData['subject_id'] ??
            noteData['subjectId'];

        if (noteSubjectId != null) {
          return studentSubjectIds.contains(
            noteSubjectId.toString(),
          );
        }

        return false;
      }).toList();

      if (!mounted) {
        return;
      }

      setState(() {
        notes = filteredNotes;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load notes.';
      });
    }
  }

  String getNoteTitle(
    Map<String, dynamic> note,
  ) {
    return (
      note['title'] ??
      note['note_title'] ??
      note['name'] ??
      'Untitled Note'
    ).toString();
  }

  String getNoteDescription(
    Map<String, dynamic> note,
  ) {
    return (
      note['description'] ??
      note['content'] ??
      note['details'] ??
      note['topic'] ??
      'Study resource'
    ).toString();
  }

  String getSubjectName(
    Map<String, dynamic> note,
  ) {
    return (
      note['subject_name'] ??
      note['subject'] ??
      ''
    ).toString();
  }

  String? getFileUrl(
    Map<String, dynamic> note,
  ) {
    final value =
        note['file_url'] ??
        note['fileUrl'] ??
        note['url'] ??
        note['file'];

    if (value == null) {
      return null;
    }

    final url = value.toString().trim();

    if (url.isEmpty) {
      return null;
    }

    return url;
  }

  IconData getNoteIcon(
    Map<String, dynamic> note,
  ) {
    final title =
        getNoteTitle(note).toLowerCase();

    if (title.contains('database') ||
        title.contains('sql')) {
      return Icons.storage;
    }

    if (title.contains('web')) {
      return Icons.web;
    }

    if (title.contains('network')) {
      return Icons.lan;
    }

    if (title.contains('software')) {
      return Icons.engineering;
    }

    if (title.contains('data')) {
      return Icons.data_object;
    }

    return Icons.description;
  }

  Future<void> openNote(
    Map<String, dynamic> note,
  ) async {
    final title = getNoteTitle(note);
    final fileUrl = getFileUrl(note);

    if (fileUrl == null) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No file is attached to this note.',
          ),
        ),
      );

      return;
    }

    String finalUrl = fileUrl;

    /*
     * If backend returns a relative path such as:
     * /uploads/notes/example.pdf
     *
     * convert it into:
     * http://127.0.0.1:8000/uploads/notes/example.pdf
     */
    if (finalUrl.startsWith('/')) {
      finalUrl =
          '${ApiService.baseUrl}$finalUrl';
    }

    final uri = Uri.tryParse(finalUrl);

    if (uri == null ||
        uri.scheme.isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid file URL.',
          ),
        ),
      );

      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to open "$title".',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to open "$title".',
          ),
        ),
      );
    }
  }

  void showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget buildNoteCard(
    Map<String, dynamic> note,
  ) {
    final title = getNoteTitle(note);
    final description =
        getNoteDescription(note);
    final subjectName =
        getSubjectName(note);

    final fileUrl = getFileUrl(note);
    final hasFile = fileUrl != null;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.all(12),
        leading: CircleAvatar(
          child: Icon(
            getNoteIcon(note),
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
              Text(description),
              if (subjectName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Subject: $subjectName',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                hasFile
                    ? 'File attached • Tap to open'
                    : 'No file attached',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: hasFile
                      ? Colors.green
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
        trailing: Icon(
          hasFile
              ? Icons.open_in_new
              : Icons.info_outline,
        ),
        onTap: hasFile
            ? () => openNote(note)
            : () => showMessage(
                  'No file is attached to this note.',
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
          padding:
              const EdgeInsets.all(24),
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
                textAlign:
                    TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: loadNotes,
                child:
                    const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (notes.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadNotes,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 60,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No notes available.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Study notes and resources '
                    'will appear here.',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadNotes,
      child: ListView.builder(
        padding:
            const EdgeInsets.all(16),
        physics:
            const AlwaysScrollableScrollPhysics(),
        itemCount: notes.length,
        itemBuilder:
            (context, index) {
          final note =
              Map<String, dynamic>.from(
            notes[index] as Map,
          );

          return buildNoteCard(note);
        },
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notes & Resources',
        ),
      ),
      body: buildBody(),
    );
  }
}