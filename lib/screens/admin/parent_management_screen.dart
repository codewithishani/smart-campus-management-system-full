import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ParentManagementScreen extends StatefulWidget {
  const ParentManagementScreen({super.key});

  @override
  State<ParentManagementScreen> createState() =>
      _ParentManagementScreenState();
}

class _ParentManagementScreenState
    extends State<ParentManagementScreen> {
  List<Map<String, dynamic>> parents = [];
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> parentStudentLinks = [];

  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadParents();
  }

  // =========================
  // LOAD DATA
  // =========================

  Future<void> loadParents() async {
    try {
      final data = await Future.wait([
        ApiService.getParents(),
        ApiService.getStudents(),
        ApiService.getParentStudentLinks(),
      ]);

      final parentData = data[0]
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();

      final studentData = data[1]
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();

      final linkData = data[2]
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        parents = parentData;
        students = studentData;
        parentStudentLinks = linkData;
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

  // =========================
  // HELPERS
  // =========================

  int getIntValue(
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

  List<Map<String, dynamic>> getLinkedStudents(
    int parentId,
  ) {
    final studentIds = <int>{};

    for (final link in parentStudentLinks) {
      final linkedParentId = getIntValue(
        link,
        ['parent_id'],
      );

      if (linkedParentId == parentId) {
        final studentId = getIntValue(
          link,
          ['student_id'],
        );

        if (studentId != 0) {
          studentIds.add(studentId);
        }
      }
    }

    return students.where((student) {
      final studentId = getIntValue(
        student,
        ['student_id'],
      );

      return studentIds.contains(studentId);
    }).toList();
  }

  List<Map<String, dynamic>> get filteredParents {
    if (searchQuery.trim().isEmpty) {
      return parents;
    }

    final query = searchQuery.toLowerCase().trim();

    return parents.where((parent) {
      final name = getStringValue(
        parent,
        ['name'],
      ).toLowerCase();

      final email = getStringValue(
        parent,
        ['email'],
      ).toLowerCase();

      final phone = getStringValue(
        parent,
        ['phone'],
      ).toLowerCase();

      final id = getIntValue(
        parent,
        ['parent_id'],
      ).toString();

      return name.contains(query) ||
          email.contains(query) ||
          phone.contains(query) ||
          id.contains(query);
    }).toList();
  }

  // =========================
  // VIEW
  // =========================

  Future<void> showParentDetails(
    Map<String, dynamic> parent,
  ) async {
    final parentId = getIntValue(
      parent,
      ['parent_id'],
    );

    final userId = getIntValue(
      parent,
      ['user_id'],
    );

    final name = getStringValue(
      parent,
      ['name'],
      defaultValue: 'Parent',
    );

    final email = getStringValue(
      parent,
      ['email'],
      defaultValue: 'Not available',
    );

    final phone = getStringValue(
      parent,
      ['phone'],
      defaultValue: 'Not available',
    );

    final address = getStringValue(
      parent,
      ['address'],
      defaultValue: 'Not available',
    );

    final linkedStudents =
        getLinkedStudents(parentId);

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow(
                  'Parent ID',
                  parentId == 0
                      ? 'Not available'
                      : parentId.toString(),
                ),
                _detailRow(
                  'User ID',
                  userId == 0
                      ? 'Not available'
                      : userId.toString(),
                ),
                _detailRow('Email', email),
                _detailRow('Phone', phone),
                _detailRow('Address', address),
                const SizedBox(height: 8),
                const Text(
                  'Linked Students',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                if (linkedStudents.isEmpty)
                  const Text(
                    'No linked students.',
                  )
                else
                  ...linkedStudents.map(
                    (student) {
                      final studentName =
                          getStringValue(
                        student,
                        ['name'],
                        defaultValue: 'Student',
                      );

                      final rollNo =
                          getStringValue(
                        student,
                        ['roll_no'],
                        defaultValue:
                            'No roll number',
                      );

                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 8,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.school,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$studentName • $rollNo',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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

  // =========================
  // ADD
  // =========================

  Future<void> addParent() async {
    final result = await showParentForm();

    if (result == null) return;

    try {
      await ApiService.createParent(result);

      if (!mounted) return;

      await loadParents();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Parent added successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add parent: $e',
          ),
        ),
      );
    }
  }

  // =========================
  // EDIT
  // =========================

  Future<void> editParent(
    Map<String, dynamic> parent,
  ) async {
    final parentId = getIntValue(
      parent,
      ['parent_id'],
    );

    final result = await showParentForm(
      parent: parent,
    );

    if (result == null) return;

    try {
      await ApiService.updateParent(
        parentId,
        result,
      );

      if (!mounted) return;

      await loadParents();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Parent updated successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update parent: $e',
          ),
        ),
      );
    }
  }

  // =========================
  // DELETE
  // =========================

  Future<void> deleteParent(
    Map<String, dynamic> parent,
  ) async {
    final parentId = getIntValue(
      parent,
      ['parent_id'],
    );

    final name = getStringValue(
      parent,
      ['name'],
      defaultValue: 'this parent',
    );

    if (parentId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid parent ID.',
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Parent'),
          content: Text(
            'Are you sure you want to delete $name?',
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

    if (confirmed != true) return;

    try {
      await ApiService.deleteParent(parentId);

      if (!mounted) return;

      await loadParents();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Parent deleted successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete parent: $e',
          ),
        ),
      );
    }
  }

  // =========================
  // ADD / EDIT FORM
  // =========================

  Future<Map<String, dynamic>?> showParentForm({
    Map<String, dynamic>? parent,
  }) async {
    final isEdit = parent != null;

    final userIdController = TextEditingController(
      text: isEdit
          ? getIntValue(
              parent,
              ['user_id'],
            ).toString()
          : '',
    );

    final nameController = TextEditingController(
      text: isEdit
          ? getStringValue(
              parent,
              ['name'],
            )
          : '',
    );

    final emailController = TextEditingController(
      text: isEdit
          ? getStringValue(
              parent,
              ['email'],
            )
          : '',
    );

    final phoneController = TextEditingController(
      text: isEdit
          ? getStringValue(
              parent,
              ['phone'],
            )
          : '',
    );

    final addressController = TextEditingController(
      text: isEdit
          ? getStringValue(
              parent,
              ['address'],
            )
          : '',
    );

    final formKey = GlobalKey<FormState>();

    final result =
        await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isEdit
                ? 'Edit Parent'
                : 'Add Parent',
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: userIdController,
                    keyboardType:
                        TextInputType.number,
                    decoration:
                        const InputDecoration(
                      labelText: 'User ID',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final id =
                          int.tryParse(
                        value?.trim() ?? '',
                      );

                      if (id == null || id <= 0) {
                        return 'Enter a valid User ID';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(
                      labelText: 'Parent Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Enter parent name';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    keyboardType:
                        TextInputType.emailAddress,
                    decoration:
                        const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Enter email';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    keyboardType:
                        TextInputType.phone,
                    decoration:
                        const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressController,
                    maxLines: 3,
                    decoration:
                        const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!
                    .validate()) {
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  {
                    'user_id': int.parse(
                      userIdController.text
                          .trim(),
                    ),
                    'name':
                        nameController.text.trim(),
                    'email':
                        emailController.text.trim(),
                    'phone':
                        phoneController.text.trim(),
                    'address':
                        addressController.text.trim(),
                  },
                );
              },
              child: Text(
                isEdit ? 'Update' : 'Add',
              ),
            ),
          ],
        );
      },
    );

    userIdController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();

    return result;
  }

  // =========================
  // UI HELPERS
  // =========================

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 10),
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
          const SizedBox(height: 2),
          Text(value),
        ],
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
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
            ),
            const SizedBox(height: 14),
            Text(
              errorMessage ??
                  'Unable to load parents.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });

                loadParents();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmpty() {
    return RefreshIndicator(
      onRefresh: loadParents,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 120),
          Icon(
            Icons.family_restroom,
            size: 70,
          ),
          SizedBox(height: 18),
          Text(
            'No parents found.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildParentList() {
    final visibleParents =
        filteredParents;

    if (visibleParents.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadParents,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 150),
            Center(
              child: Text(
                'No matching parents found.',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadParents,
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          100,
        ),
        itemCount: visibleParents.length,
        itemBuilder: (context, index) {
          final parent =
              visibleParents[index];

          final parentId = getIntValue(
            parent,
            ['parent_id'],
          );

          final name = getStringValue(
            parent,
            ['name'],
            defaultValue: 'Parent',
          );

          final email = getStringValue(
            parent,
            ['email'],
            defaultValue: 'No email',
          );

          final linkedStudents =
              getLinkedStudents(parentId);

          final studentNames =
              linkedStudents
                  .map(
                    (student) =>
                        getStringValue(
                      student,
                      ['name'],
                      defaultValue:
                          'Student',
                    ),
                  )
                  .toList();

          final studentText =
              studentNames.isEmpty
                  ? 'No linked students'
                  : studentNames.join(', ');

          return Card(
            margin:
                const EdgeInsets.only(
              bottom: 12,
            ),
            child: Padding(
              padding:
                  const EdgeInsets.all(12),
              child: Column(
                children: [
                  ListTile(
                    contentPadding:
                        EdgeInsets.zero,
                    leading:
                        const CircleAvatar(
                      child: Icon(
                        Icons.family_restroom,
                      ),
                    ),
                    title: Text(
                      name,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Parent ID: ${parentId == 0 ? 'Not available' : parentId}'
                      '\n$email'
                      '\nStudent: $studentText',
                    ),
                    isThreeLine: true,
                  ),

                  const Divider(),

                  Row(
                    children: [
                      Expanded(
                        child:
                            OutlinedButton.icon(
                          onPressed: () =>
                              showParentDetails(
                            parent,
                          ),
                          icon: const Icon(
                            Icons.visibility,
                          ),
                          label:
                              const Text('View'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child:
                            ElevatedButton.icon(
                          onPressed: () =>
                              editParent(
                            parent,
                          ),
                          icon: const Icon(
                            Icons.edit,
                          ),
                          label:
                              const Text('Edit'),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        tooltip:
                            'Delete Parent',
                        onPressed: () =>
                            deleteParent(
                          parent,
                        ),
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

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Parent Management'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              setState(() {
                isLoading = true;
                errorMessage = null;
              });

              loadParents();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: isLoading
          ? buildLoading()
          : errorMessage != null
              ? buildError()
              : parents.isEmpty
                  ? buildEmpty()
                  : Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets
                                  .fromLTRB(
                            16,
                            12,
                            16,
                            4,
                          ),
                          child:
                              TextField(
                            decoration:
                                InputDecoration(
                              hintText:
                                  'Search parent...',
                              prefixIcon:
                                  const Icon(
                                Icons.search,
                              ),
                              suffixIcon:
                                  searchQuery
                                          .isEmpty
                                      ? null
                                      : IconButton(
                                          onPressed:
                                              () {
                                            setState(
                                              () {
                                                searchQuery =
                                                    '';
                                              },
                                            );
                                          },
                                          icon:
                                              const Icon(
                                            Icons
                                                .clear,
                                          ),
                                        ),
                              border:
                                  const OutlineInputBorder(),
                            ),
                            onChanged:
                                (value) {
                              setState(() {
                                searchQuery =
                                    value;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child:
                              buildParentList(),
                        ),
                      ],
                    ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: addParent,
        icon: const Icon(Icons.add),
        label: const Text('Add Parent'),
      ),
    );
  }
}