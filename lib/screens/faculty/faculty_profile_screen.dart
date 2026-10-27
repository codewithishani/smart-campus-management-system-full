import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class FacultyProfileScreen extends StatefulWidget {
  final int facultyId;

  const FacultyProfileScreen({
    super.key,
    required this.facultyId,
  });

  @override
  State<FacultyProfileScreen> createState() =>
      _FacultyProfileScreenState();
}

class _FacultyProfileScreenState
    extends State<FacultyProfileScreen> {
  Map<String, dynamic>? faculty;
  String? departmentName;

  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadFaculty();
  }

  Future<void> loadFaculty() async {
    try {
      final results = await Future.wait([
        ApiService.getFaculty(),
        ApiService.getDepartments(),
      ]);

      final facultyData = results[0];
      final departmentData = results[1];

      Map<String, dynamic>? currentFaculty;

      for (final item in facultyData) {
        if (item is! Map) continue;

        final data =
            Map<String, dynamic>.from(item);

        final id = _toInt(
          data['faculty_id'] ?? data['id'],
        );

        if (id == widget.facultyId) {
          currentFaculty = data;
          break;
        }
      }

      String? currentDepartmentName;

      if (currentFaculty != null) {
        final departmentId = _toInt(
          currentFaculty['department_id'] ??
              currentFaculty['departmentId'],
        );

        for (final item in departmentData) {
          if (item is! Map) continue;

          final department =
              Map<String, dynamic>.from(item);

          final id = _toInt(
            department['department_id'] ??
                department['id'],
          );

          if (id == departmentId) {
            final name =
                department['name'] ??
                department['department_name'];

            if (name != null &&
                name.toString().trim().isNotEmpty) {
              currentDepartmentName =
                  name.toString();
            }

            break;
          }
        }
      }

      if (!mounted) return;

      setState(() {
        faculty = currentFaculty;
        departmentName = currentDepartmentName;
        isLoading = false;

        errorMessage = currentFaculty == null
            ? 'Faculty information not found.'
            : null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load faculty profile.';
      });
    }
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
  }

  String getValue(
    List<String> keys, {
    String fallback = 'Not available',
  }) {
    if (faculty == null) {
      return fallback;
    }

    for (final key in keys) {
      final value = faculty![key];

      if (value != null &&
          value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }

  String getName() {
    return getValue(
      ['name'],
    );
  }

  String getEmployeeId() {
    return getValue(
      ['employee_id', 'employeeId'],
    );
  }

  String getEmail() {
    return getValue(
      ['email'],
    );
  }

  String getPhone() {
    return getValue(
      ['phone'],
    );
  }

  String getDesignation() {
    return getValue(
      ['designation'],
    );
  }

  String getDepartment() {
    if (departmentName != null &&
        departmentName!.trim().isNotEmpty) {
      return departmentName!;
    }

    return getValue(
      ['department_name', 'department'],
    );
  }

  Future<void> showEditProfileDialog() async {
    if (faculty == null) return;

    final nameController =
        TextEditingController(
      text: getName() == 'Not available'
          ? ''
          : getName(),
    );

    final emailController =
        TextEditingController(
      text: getEmail() == 'Not available'
          ? ''
          : getEmail(),
    );

    final phoneController =
        TextEditingController(
      text: getPhone() == 'Not available'
          ? ''
          : getPhone(),
    );

    final designationController =
        TextEditingController(
      text: getDesignation() == 'Not available'
          ? ''
          : getDesignation(),
    );

    String? validationMessage;

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder:
                (context, setDialogState) {
              return AlertDialog(
                title: const Text(
                  'Edit Faculty Profile',
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration:
                            const InputDecoration(
                          labelText: 'Name',
                          prefixIcon:
                              Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        keyboardType:
                            TextInputType.emailAddress,
                        decoration:
                            const InputDecoration(
                          labelText: 'Email',
                          prefixIcon:
                              Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phoneController,
                        keyboardType:
                            TextInputType.phone,
                        decoration:
                            const InputDecoration(
                          labelText: 'Phone',
                          prefixIcon:
                              Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller:
                            designationController,
                        decoration:
                            const InputDecoration(
                          labelText: 'Designation',
                          prefixIcon:
                              Icon(Icons.school_outlined),
                        ),
                      ),
                      if (validationMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          validationMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isSaving
                        ? null
                        : () {
                            Navigator.pop(
                              dialogContext,
                            );
                          },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            final name =
                                nameController.text
                                    .trim();
                            final email =
                                emailController.text
                                    .trim();
                            final phone =
                                phoneController.text
                                    .trim();
                            final designation =
                                designationController
                                    .text
                                    .trim();

                            if (name.isEmpty ||
                                email.isEmpty) {
                              setDialogState(() {
                                validationMessage =
                                    'Name and email are required.';
                              });
                              return;
                            }

                            final userId = _toInt(
                              faculty!['user_id'] ??
                                  faculty!['userId'],
                            );

                            final departmentId =
                                _toInt(
                              faculty!['department_id'] ??
                                  faculty![
                                      'departmentId'],
                            );

                            final employeeId =
                                getEmployeeId();

                            if (userId == null ||
                                departmentId == null ||
                                employeeId ==
                                    'Not available' ||
                                employeeId.trim().isEmpty) {
                              setDialogState(() {
                                validationMessage =
                                    'Required faculty information is missing.';
                              });
                              return;
                            }

                            setDialogState(() {
                              validationMessage = null;
                            });

                            setState(() {
                              isSaving = true;
                            });

                            try {
                              final updated =
                                  await ApiService
                                      .updateFaculty(
                                facultyId:
                                    widget.facultyId,
                                userId: userId,
                                employeeId:
                                    employeeId,
                                name: name,
                                email: email,
                                phone: phone.isEmpty
                                    ? null
                                    : phone,
                                departmentId:
                                    departmentId,
                                designation:
                                    designation.isEmpty
                                        ? null
                                        : designation,
                              );

                              if (!context.mounted) {
                                return;
                              }

                              setState(() {
                                faculty =
                                    Map<String, dynamic>
                                        .from(updated);
                                isSaving = false;
                              });

                              if (!dialogContext.mounted) {
                                return;
                              }

                              Navigator.pop(
                                dialogContext,
                              );

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Faculty profile updated successfully.',
                                  ),
                                ),
                              );

                              await loadFaculty();
                            } catch (e) {
                              if (!context.mounted) {
                                return;
                              }

                              setState(() {
                                isSaving = false;
                              });

                              if (!dialogContext.mounted) {
                                return;
                              }

                              setDialogState(() {
                                validationMessage =
                                    'Unable to update profile. Please try again.';
                              });
                            }
                          },
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Save'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
      emailController.dispose();
      phoneController.dispose();
      designationController.dispose();
    }
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
                size: 55,
              ),
              const SizedBox(height: 14),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });

                  loadFaculty();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final name = getName();

    return RefreshIndicator(
      onRefresh: loadFaculty,
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            const CircleAvatar(
              radius: 48,
              child: Icon(
                Icons.person,
                size: 55,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Employee ID: ${getEmployeeId()}',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _info(
                      Icons.person,
                      'Name',
                      name,
                    ),

                    _info(
                      Icons.badge_outlined,
                      'Employee ID',
                      getEmployeeId(),
                    ),

                    _info(
                      Icons.email_outlined,
                      'Email',
                      getEmail(),
                    ),

                    _info(
                      Icons.phone_outlined,
                      'Phone',
                      getPhone(),
                    ),

                    _info(
                      Icons.apartment,
                      'Department',
                      getDepartment(),
                    ),
                  ],
                ),
              ),
            ),

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Professional Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _info(
                      Icons.school_outlined,
                      'Designation',
                      getDesignation(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: isSaving
                  ? null
                  : showEditProfileDialog,
              icon: const Icon(Icons.edit),
              label:
                  const Text('Edit Profile'),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Faculty Profile'),
      ),
      body: buildBody(),
    );
  }

  static Widget _info(
    IconData icon,
    String title,
    String value,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}