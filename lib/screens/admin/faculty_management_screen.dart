import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class FacultyManagementScreen extends StatefulWidget {
  const FacultyManagementScreen({super.key});

  @override
  State<FacultyManagementScreen> createState() =>
      _FacultyManagementScreenState();
}

class _FacultyManagementScreenState
    extends State<FacultyManagementScreen> {
  List<Map<String, dynamic>> faculty = [];
  List<Map<String, dynamic>> departments = [];

  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadFaculty();
  }

  Future<void> loadFaculty() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final results = await Future.wait([
        ApiService.getFaculty(),
        ApiService.getDepartments(),
      ]);

      final facultyData = results[0]
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();

      final departmentData = results[1]
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        faculty = facultyData;
        departments = departmentData;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  int getInt(
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

  String getString(
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

  String getDepartmentName(int departmentId) {
    for (final department in departments) {
      final id = getInt(
        department,
        ['department_id', 'id'],
      );

      if (id == departmentId) {
        return getString(
          department,
          [
            'department_name',
            'name',
            'title',
          ],
          defaultValue: 'Department $departmentId',
        );
      }
    }

    return departmentId == 0
        ? 'Not assigned'
        : 'Department $departmentId';
  }

  List<Map<String, dynamic>> get filteredFaculty {
    if (searchQuery.trim().isEmpty) {
      return faculty;
    }

    final query = searchQuery.toLowerCase().trim();

    return faculty.where((person) {
      final name = getString(
        person,
        ['name'],
      ).toLowerCase();

      final employeeId = getString(
        person,
        ['employee_id'],
      ).toLowerCase();

      final email = getString(
        person,
        ['email'],
      ).toLowerCase();

      final designation = getString(
        person,
        ['designation'],
      ).toLowerCase();

      return name.contains(query) ||
          employeeId.contains(query) ||
          email.contains(query) ||
          designation.contains(query);
    }).toList();
  }

  // ============================================================
  // VIEW
  // ============================================================

  Future<void> viewFaculty(
    Map<String, dynamic> person,
  ) async {
    final facultyId = getInt(
      person,
      ['faculty_id'],
    );

    final userId = getInt(
      person,
      ['user_id'],
    );

    final employeeId = getString(
      person,
      ['employee_id'],
      defaultValue: 'Not available',
    );

    final name = getString(
      person,
      ['name'],
      defaultValue: 'Faculty',
    );

    final email = getString(
      person,
      ['email'],
      defaultValue: 'Not available',
    );

    final phone = getString(
      person,
      ['phone'],
      defaultValue: 'Not available',
    );

    final designation = getString(
      person,
      ['designation'],
      defaultValue: 'Not available',
    );

    final departmentId = getInt(
      person,
      ['department_id'],
    );

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                detailRow(
                  'Faculty ID',
                  facultyId.toString(),
                ),
                detailRow(
                  'User ID',
                  userId.toString(),
                ),
                detailRow(
                  'Employee ID',
                  employeeId,
                ),
                detailRow(
                  'Email',
                  email,
                ),
                detailRow(
                  'Phone',
                  phone,
                ),
                detailRow(
                  'Designation',
                  designation,
                ),
                detailRow(
                  'Department',
                  getDepartmentName(departmentId),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(value),
        ],
      ),
    );
  }

  // ============================================================
  // ADD
  // ============================================================

  Future<void> addFaculty() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return FacultyFormDialog(
          departments: departments,
          onSubmit: (data) async {
            await ApiService.createFaculty(data);
          },
        );
      },
    );

    if (result == true) {
      await loadFaculty();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Faculty added successfully.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // EDIT
  // ============================================================

  Future<void> editFaculty(
    Map<String, dynamic> person,
  ) async {
    final facultyId = getInt(
      person,
      ['faculty_id'],
    );

    if (facultyId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid Faculty ID.',
          ),
        ),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return FacultyFormDialog(
          departments: departments,
          initialData: person,
          onSubmit: (data) async {
            await ApiService.updateFaculty(
              facultyId: facultyId,
              userId: data['user_id'] as int,
              employeeId:
                  data['employee_id'] as String,
              name: data['name'] as String,
              email: data['email'] as String,
              phone: data['phone'] as String?,
              departmentId:
                  data['department_id'] as int,
              designation:
                  data['designation'] as String?,
            );
          },
        );
      },
    );

    if (result == true) {
      await loadFaculty();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Faculty updated successfully.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteFaculty(
    Map<String, dynamic> person,
  ) async {
    final facultyId = getInt(
      person,
      ['faculty_id'],
    );

    final name = getString(
      person,
      ['name'],
      defaultValue: 'this faculty',
    );

    if (facultyId == 0) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Faculty',
          ),
          content: Text(
            'Are you sure you want to delete "$name"?',
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
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

    if (confirmed != true) {
      return;
    }

    try {
      await ApiService.deleteFaculty(
        facultyId,
      );

      await loadFaculty();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Faculty deleted successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Delete failed: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        8,
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText:
              'Search faculty...',
          prefixIcon: const Icon(
            Icons.search,
          ),
          suffixIcon: searchQuery.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    setState(() {
                      searchQuery = '';
                    });
                  },
                  icon: const Icon(
                    Icons.clear,
                  ),
                ),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FACULTY LIST
  // ============================================================

  Widget facultyList() {
    final list = filteredFaculty;

    if (list.isEmpty) {
      return const Center(
        child: Text(
          'No matching faculty found.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadFaculty,
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          100,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final person = list[index];

          final name = getString(
            person,
            ['name'],
            defaultValue: 'Faculty',
          );

          final employeeId = getString(
            person,
            ['employee_id'],
            defaultValue: 'No Employee ID',
          );

          final designation = getString(
            person,
            ['designation'],
            defaultValue: 'Faculty',
          );

          final departmentId = getInt(
            person,
            ['department_id'],
          );

          return Card(
            margin: const EdgeInsets.only(
              bottom: 12,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(
                        Icons.person,
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '$employeeId\n'
                      '$designation\n'
                      '${getDepartmentName(departmentId)}',
                    ),
                    isThreeLine: true,
                    onTap: () {
                      viewFaculty(person);
                    },
                  ),

                  const Divider(),

                  // IMPORTANT:
                  // Buttons are directly visible.
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            viewFaculty(
                              person,
                            );
                          },
                          icon: const Icon(
                            Icons.visibility,
                          ),
                          label: const Text(
                            'View',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            editFaculty(
                              person,
                            );
                          },
                          icon: const Icon(
                            Icons.edit,
                          ),
                          label: const Text(
                            'Edit',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip:
                            'Delete Faculty',
                        onPressed: () {
                          deleteFaculty(
                            person,
                          );
                        },
                        icon: const Icon(
                          Icons.delete,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Faculty Management',
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: isLoading
                ? null
                : loadFaculty,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Text(
                          'Unable to load faculty.',
                          textAlign:
                              TextAlign.center,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          errorMessage!,
                          textAlign:
                              TextAlign.center,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton.icon(
                          onPressed:
                              loadFaculty,
                          icon: const Icon(
                            Icons.refresh,
                          ),
                          label: const Text(
                            'Retry',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    searchBar(),
                    Expanded(
                      child: faculty.isEmpty
                          ? const Center(
                              child: Text(
                                'No faculty found.',
                              ),
                            )
                          : facultyList(),
                    ),
                  ],
                ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: addFaculty,
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Add Faculty',
        ),
      ),
    );
  }
}

// ==================================================================
// FACULTY FORM
// ==================================================================

class FacultyFormDialog extends StatefulWidget {
  final List<Map<String, dynamic>> departments;
  final Map<String, dynamic>? initialData;

  final Future<void> Function(
    Map<String, dynamic> data,
  ) onSubmit;

  const FacultyFormDialog({
    super.key,
    required this.departments,
    required this.onSubmit,
    this.initialData,
  });

  @override
  State<FacultyFormDialog> createState() =>
      _FacultyFormDialogState();
}

class _FacultyFormDialogState
    extends State<FacultyFormDialog> {
  final formKey =
      GlobalKey<FormState>();

  late TextEditingController userIdController;
  late TextEditingController employeeIdController;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController designationController;

  int? selectedDepartmentId;

  bool submitting = false;

  bool get isEdit =>
      widget.initialData != null;

  @override
  void initState() {
    super.initState();

    final data =
        widget.initialData ?? {};

    userIdController =
        TextEditingController(
      text: valueAsString(
        data,
        'user_id',
      ),
    );

    employeeIdController =
        TextEditingController(
      text: valueAsString(
        data,
        'employee_id',
      ),
    );

    nameController =
        TextEditingController(
      text: valueAsString(
        data,
        'name',
      ),
    );

    emailController =
        TextEditingController(
      text: valueAsString(
        data,
        'email',
      ),
    );

    phoneController =
        TextEditingController(
      text: valueAsString(
        data,
        'phone',
      ),
    );

    designationController =
        TextEditingController(
      text: valueAsString(
        data,
        'designation',
      ),
    );

    selectedDepartmentId =
        valueAsInt(
      data,
      'department_id',
    );
  }

  String valueAsString(
    Map<String, dynamic> data,
    String key,
  ) {
    return data[key]?.toString() ?? '';
  }

  int? valueAsInt(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];

    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    userIdController.dispose();
    employeeIdController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    designationController.dispose();

    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedDepartmentId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please select department.',
          ),
        ),
      );
      return;
    }

    final userId = int.tryParse(
      userIdController.text.trim(),
    );

    if (userId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'User ID must be a number.',
          ),
        ),
      );
      return;
    }

    setState(() {
      submitting = true;
    });

    final data = {
      'user_id': userId,
      'employee_id':
          employeeIdController.text.trim(),
      'name':
          nameController.text.trim(),
      'email':
          emailController.text.trim(),
      'phone':
          phoneController.text.trim().isEmpty
              ? null
              : phoneController.text.trim(),
      'department_id':
          selectedDepartmentId,
      'designation':
          designationController.text.trim().isEmpty
              ? null
              : designationController.text.trim(),
    };

    try {
      await widget.onSubmit(data);

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        submitting = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Operation failed:\n$e',
          ),
        ),
      );
    }
  }

  String? requiredField(
    String? value,
    String name,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return '$name is required';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        isEdit
            ? 'Edit Faculty'
            : 'Add Faculty',
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                TextFormField(
                  controller:
                      userIdController,
                  enabled: !isEdit,
                  keyboardType:
                      TextInputType.number,
                  decoration:
                      const InputDecoration(
                    labelText: 'User ID',
                    hintText:
                        'Existing User ID',
                    prefixIcon:
                        Icon(Icons.person),
                  ),
                  validator: (value) {
                    final error =
                        requiredField(
                      value,
                      'User ID',
                    );

                    if (error != null) {
                      return error;
                    }

                    if (int.tryParse(
                          value!.trim(),
                        ) ==
                        null) {
                      return 'Enter valid User ID';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 12,
                ),

                TextFormField(
                  controller:
                      employeeIdController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Employee ID',
                    prefixIcon:
                        Icon(Icons.badge),
                  ),
                  validator: (value) =>
                      requiredField(
                    value,
                    'Employee ID',
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                TextFormField(
                  controller:
                      nameController,
                  decoration:
                      const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(
                      Icons.person_outline,
                    ),
                  ),
                  validator: (value) =>
                      requiredField(
                    value,
                    'Name',
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                TextFormField(
                  controller:
                      emailController,
                  keyboardType:
                      TextInputType.emailAddress,
                  decoration:
                      const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                    ),
                  ),
                  validator: (value) {
                    final error =
                        requiredField(
                      value,
                      'Email',
                    );

                    if (error != null) {
                      return error;
                    }

                    if (!value!.contains('@')) {
                      return 'Enter valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 12,
                ),

                TextFormField(
                  controller:
                      phoneController,
                  keyboardType:
                      TextInputType.phone,
                  decoration:
                      const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                DropdownButtonFormField<int>(
                  initialValue:
                      selectedDepartmentId,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Department',
                    prefixIcon: Icon(
                      Icons.account_tree,
                    ),
                  ),
                  items: widget.departments
                      .map((department) {
                    final id =
                        valueAsInt(
                      department,
                      'department_id',
                    );

                    final name =
                        valueAsString(
                      department,
                      'department_name',
                    );

                    if (id == null) {
                      return null;
                    }

                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text(
                        name.isEmpty
                            ? 'Department $id'
                            : name,
                      ),
                    );
                  })
                      .whereType<
                          DropdownMenuItem<int>>()
                      .toList(),
                  onChanged: submitting
                      ? null
                      : (value) {
                          setState(() {
                            selectedDepartmentId =
                                value;
                          });
                        },
                  validator: (value) {
                    if (value == null) {
                      return 'Select department';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 12,
                ),

                TextFormField(
                  controller:
                      designationController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Designation',
                    prefixIcon: Icon(
                      Icons.work_outline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: submitting
              ? null
              : () {
                  Navigator.pop(
                    context,
                    false,
                  );
                },
          child: const Text(
            'Cancel',
          ),
        ),
        ElevatedButton.icon(
          onPressed:
              submitting ? null : submit,
          icon: submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Icon(
                  isEdit
                      ? Icons.save
                      : Icons.add,
                ),
          label: Text(
            submitting
                ? 'Saving...'
                : isEdit
                    ? 'Update'
                    : 'Add',
          ),
        ),
      ],
    );
  }
}