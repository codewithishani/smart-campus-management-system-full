import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DepartmentManagementScreen extends StatefulWidget {
  const DepartmentManagementScreen({super.key});

  @override
  State<DepartmentManagementScreen> createState() =>
      _DepartmentManagementScreenState();
}

class _DepartmentManagementScreenState
    extends State<DepartmentManagementScreen> {
  List<Map<String, dynamic>> departments = [];
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> faculty = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadDepartments();
  }

  // ============================================================
  // LOAD DEPARTMENTS, STUDENTS AND FACULTY
  // ============================================================

  Future<void> loadDepartments() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getDepartments(),
        ApiService.getStudents(),
        ApiService.getFaculty(),
      ]);

      final departmentData = results[0]
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      final studentData = results[1]
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      final facultyData = results[2]
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      if (!mounted) return;

      setState(() {
        departments = departmentData;
        students = studentData;
        faculty = facultyData;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load departments.\n$e';
      });
    }
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  int getIntValue(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value is int) return value;

      final parsed = int.tryParse(value?.toString() ?? '');

      if (parsed != null) return parsed;
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

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return defaultValue;
  }

  int getStudentCount(int departmentId) {
    if (departmentId == 0) return 0;

    return students.where((student) {
      return getIntValue(student, ['department_id']) == departmentId;
    }).length;
  }

  int getFacultyCount(int departmentId) {
    if (departmentId == 0) return 0;

    return faculty.where((person) {
      return getIntValue(person, ['department_id']) == departmentId;
    }).length;
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  // ============================================================
  // VIEW DEPARTMENT DETAILS
  // ============================================================

  Future<void> showDepartmentDetails(
    Map<String, dynamic> department,
  ) async {
    final departmentId = getIntValue(
      department,
      ['department_id', 'id'],
    );

    final name = getStringValue(
      department,
      ['department_name'],
      defaultValue: 'Department',
    );

    final description = getStringValue(
      department,
      ['description'],
      defaultValue: 'No description available',
    );

    final hodName = getStringValue(
      department,
      ['hod_name'],
      defaultValue: 'Not assigned',
    );

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          scrollable: true,
          title: Text(name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              detailRow(
                'Department ID',
                departmentId == 0 ? 'N/A' : '$departmentId',
              ),
              detailRow('Department Name', name),
              detailRow('Description', description),
              detailRow('Head of Department', hodName),
              detailRow(
                'Students',
                '${getStudentCount(departmentId)}',
              ),
              detailRow(
                'Faculty',
                '${getFacultyCount(departmentId)}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(value),
        ],
      ),
    );
  }

  // ============================================================
  // ADD / EDIT DEPARTMENT
  // ============================================================

  Future<void> showDepartmentForm({
    Map<String, dynamic>? department,
  }) async {
    final isEdit = department != null;

    final departmentId = isEdit
        ? getIntValue(department, ['department_id', 'id'])
        : 0;

    final nameController = TextEditingController(
      text: isEdit
          ? getStringValue(department, ['department_name'])
          : '',
    );

    final descriptionController = TextEditingController(
      text: isEdit
          ? getStringValue(department, ['description'])
          : '',
    );

    final hodController = TextEditingController(
      text: isEdit
          ? getStringValue(department, ['hod_name'])
          : '',
    );

    final formKey = GlobalKey<FormState>();

    bool saving = false;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return AlertDialog(
                scrollable: true,
                title: Text(
                  isEdit ? 'Edit Department' : 'Add Department',
                ),
                content: SizedBox(
                  width: 440,
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          enabled: !saving,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Department Name *',
                            prefixIcon: Icon(Icons.business),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter department name';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionController,
                          enabled: !saving,
                          maxLines: 3,
                          minLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            alignLabelWithHint: true,
                            prefixIcon: Icon(Icons.description),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: hodController,
                          enabled: !saving,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Head of Department',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: saving
                        ? null
                        : () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton.icon(
                    onPressed: saving
                        ? null
                        : () async {
                            if (!(formKey.currentState?.validate() ??
                                false)) {
                              return;
                            }

                            if (isEdit && departmentId == 0) {
                              showMessage('Invalid department ID.');
                              return;
                            }

                            setDialogState(() {
                              saving = true;
                            });

                            try {
                              final data = <String, dynamic>{
                                'department_name':
                                    nameController.text.trim(),
                                'description':
                                    descriptionController.text.trim().isEmpty
                                        ? null
                                        : descriptionController.text.trim(),
                                'hod_name':
                                    hodController.text.trim().isEmpty
                                        ? null
                                        : hodController.text.trim(),
                              };

                              if (isEdit) {
                                await ApiService.updateDepartment(
                                  departmentId,
                                  data,
                                );
                              } else {
                                await ApiService.createDepartment(data);
                              }

                              if (!dialogContext.mounted) return;

                              Navigator.pop(dialogContext);

                              await loadDepartments();

                              if (!mounted) return;

                              showMessage(
                                isEdit
                                    ? 'Department updated successfully.'
                                    : 'Department created successfully.',
                              );
                            } catch (e) {
                              if (!dialogContext.mounted) return;

                              setDialogState(() {
                                saving = false;
                              });

                              showMessage(
                                'Unable to ${isEdit ? 'update' : 'create'} '
                                'department: $e',
                              );
                            }
                          },
                    icon: saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(isEdit ? Icons.save : Icons.add),
                    label: Text(
                      saving
                          ? 'Saving...'
                          : isEdit
                              ? 'Update'
                              : 'Add Department',
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
      descriptionController.dispose();
      hodController.dispose();
    }
  }

  // ============================================================
  // DELETE DEPARTMENT
  // ============================================================

  Future<void> deleteDepartment(
    Map<String, dynamic> department,
  ) async {
    final departmentId = getIntValue(
      department,
      ['department_id', 'id'],
    );

    final departmentName = getStringValue(
      department,
      ['department_name'],
      defaultValue: 'Department',
    );

    if (departmentId == 0) {
      showMessage('Invalid department ID.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Delete Department?'),
          content: Text(
            'Are you sure you want to delete "$departmentName"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await ApiService.deleteDepartment(departmentId);

      await loadDepartments();

      if (!mounted) return;

      showMessage('Department deleted successfully.');
    } catch (e) {
      if (!mounted) return;

      showMessage('Unable to delete department: $e');
    }
  }

  // ============================================================
  // LOADING STATE
  // ============================================================

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget buildError() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Could not load departments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            SelectableText(
              errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: loadDepartments,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget buildEmpty() {
    return RefreshIndicator(
      onRefresh: loadDepartments,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 90),
          const Icon(
            Icons.business_outlined,
            size: 72,
          ),
          const SizedBox(height: 20),
          const Text(
            'No Departments Found',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a department to get started.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => showDepartmentForm(),
              icon: const Icon(Icons.add),
              label: const Text('Add Department'),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DEPARTMENT CARD
  // ============================================================

  Widget buildDepartmentCard(
    Map<String, dynamic> department,
  ) {
    final departmentId = getIntValue(
      department,
      ['department_id', 'id'],
    );

    final name = getStringValue(
      department,
      ['department_name'],
      defaultValue: 'Department',
    );

    final description = getStringValue(
      department,
      ['description'],
    );

    final hodName = getStringValue(
      department,
      ['hod_name'],
      defaultValue: 'Not assigned',
    );

    final studentCount = getStudentCount(departmentId);
    final facultyCount = getFacultyCount(departmentId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  child: Icon(Icons.business),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Department ID: '
                        '${departmentId == 0 ? 'N/A' : departmentId}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _infoChip(
                  Icons.school_outlined,
                  '$studentCount Students',
                ),
                _infoChip(
                  Icons.people_outline,
                  '$facultyCount Faculty',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'HOD: $hodName',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const Divider(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                OutlinedButton.icon(
                  onPressed: () => showDepartmentDetails(department),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('View'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    showDepartmentForm(department: department);
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  onPressed: () => deleteDepartment(department),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 5),
          Text(label),
        ],
      ),
    );
  }

  // ============================================================
  // DEPARTMENT LIST
  // ============================================================

  Widget buildDepartmentList() {
    return RefreshIndicator(
      onRefresh: loadDepartments,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
        itemCount: departments.length,
        itemBuilder: (context, index) {
          return buildDepartmentCard(departments[index]);
        },
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
        title: const Text('Department Management'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: isLoading ? null : loadDepartments,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? buildLoading()
          : errorMessage != null
              ? buildError()
              : departments.isEmpty
                  ? buildEmpty()
                  : buildDepartmentList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDepartmentForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Department'),
      ),
    );
  }
}