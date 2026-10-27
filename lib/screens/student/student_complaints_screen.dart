
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class StudentComplaintsScreen extends StatefulWidget {
  final int studentId;

  const StudentComplaintsScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentComplaintsScreen> createState() =>
      _StudentComplaintsScreenState();
}

class _StudentComplaintsScreenState
    extends State<StudentComplaintsScreen> {
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();

  String selectedType = 'General';
  String selectedPriority = 'Medium';

  bool isSubmitting = false;

  @override
  void dispose() {
    subjectController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> submitComplaint() async {
    final title = subjectController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields.'),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await ApiService.createComplaint(
        studentId: widget.studentId,
        title: title,
        description: description,
        complaintType: selectedType,
        priority: selectedPriority,
        status: 'Submitted',
        submittedAt: DateTime.now(),
      );

      if (!mounted) return;

      subjectController.clear();
      descriptionController.clear();

      setState(() {
        selectedType = 'General';
        selectedPriority = 'Medium';
        isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complaint submitted successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to submit complaint. Please try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Submit a Complaint',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Submit an issue or request to the college administration.',
            ),

            const SizedBox(height: 20),

            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Complaint Subject',
                prefixIcon: Icon(Icons.subject),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: selectedType,
              decoration: const InputDecoration(
                labelText: 'Complaint Type',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'General',
                  child: Text('General'),
                ),
                DropdownMenuItem(
                  value: 'Academic',
                  child: Text('Academic'),
                ),
                DropdownMenuItem(
                  value: 'Infrastructure',
                  child: Text('Infrastructure'),
                ),
                DropdownMenuItem(
                  value: 'Technical',
                  child: Text('Technical'),
                ),
                DropdownMenuItem(
                  value: 'Library',
                  child: Text('Library'),
                ),
                DropdownMenuItem(
                  value: 'Hostel',
                  child: Text('Hostel'),
                ),
                DropdownMenuItem(
                  value: 'Transport',
                  child: Text('Transport'),
                ),
                DropdownMenuItem(
                  value: 'Other',
                  child: Text('Other'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedType = value;
                });
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                prefixIcon: Icon(Icons.flag),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Low',
                  child: Text('Low'),
                ),
                DropdownMenuItem(
                  value: 'Medium',
                  child: Text('Medium'),
                ),
                DropdownMenuItem(
                  value: 'High',
                  child: Text('High'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedPriority = value;
                });
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: descriptionController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Complaint Description',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : submitComplaint,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  isSubmitting
                      ? 'Submitting...'
                      : 'Submit Complaint',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

