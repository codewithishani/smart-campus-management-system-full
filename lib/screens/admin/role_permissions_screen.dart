import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RolePermissionsScreen extends StatefulWidget {
  const RolePermissionsScreen({super.key});

  @override
  State<RolePermissionsScreen> createState() =>
      _RolePermissionsScreenState();
}

class _RolePermissionsScreenState
    extends State<RolePermissionsScreen> {
  List<Map<String, dynamic>> roles = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadRoles();
  }

  // ============================================================
  // LOAD ROLES
  // ============================================================

  Future<void> loadRoles() async {
    try {
      final data = await ApiService.getRoles();

      final roleData = data
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        roles = roleData;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load roles: $e';
      });
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

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

  // ============================================================
  // VIEW ROLE
  // ============================================================

  Future<void> showRoleDetails(
    Map<String, dynamic> role,
  ) async {
    final roleId = getIntValue(
      role,
      ['role_id', 'id'],
    );

    final roleName = getStringValue(
      role,
      ['role_name', 'name', 'title'],
      defaultValue: 'Role',
    );

    final description = getStringValue(
      role,
      ['description'],
      defaultValue: 'No description',
    );

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(roleName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _detailRow(
                'Role ID',
                roleId == 0
                    ? 'Not available'
                    : roleId.toString(),
              ),
              _detailRow(
                'Role Name',
                roleName,
              ),
              _detailRow(
                'Description',
                description,
              ),
              const SizedBox(height: 8),
              const Text(
                'Permissions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Permission-level configuration is not '
                'implemented in the current backend.',
              ),
            ],
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

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
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
          const SizedBox(height: 2),
          Text(value),
        ],
      ),
    );
  }

  // ============================================================
  // ADD ROLE
  // ============================================================

  Future<void> showAddRoleDialog() async {
    final nameController =
        TextEditingController();

    final descriptionController =
        TextEditingController();

    bool isSaving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            dialogContext,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text('Add Role'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      TextField(
                        controller:
                            nameController,
                        decoration:
                            const InputDecoration(
                          labelText: 'Role Name',
                          prefixIcon:
                              Icon(Icons.security),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller:
                            descriptionController,
                        maxLines: 3,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Description',
                          prefixIcon:
                              Icon(Icons.description),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
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
                ElevatedButton.icon(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final roleName =
                              nameController.text
                                  .trim();

                          final description =
                              descriptionController
                                  .text
                                  .trim();

                          if (roleName.isEmpty) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Role name is required.',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            await ApiService
                                .createRole({
                              'role_name': roleName,
                              'description':
                                  description.isEmpty
                                      ? null
                                      : description,
                            });

                            if (!mounted || !dialogContext.mounted) return;

                            Navigator.pop(
                               dialogContext,
                                );

                            await loadRoles();

                            if (!mounted) return;

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Role created successfully.',
                                ),
                              ),
                            );
                          } catch (e) {
                            setDialogState(() {
                              isSaving = false;
                            });

                            if (!mounted) return;

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to create role: $e',
                                ),
                              ),
                            );
                          }
                        },
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.add,
                        ),
                  label:
                      const Text('Add Role'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
  }

  // ============================================================
  // EDIT ROLE
  // ============================================================

  Future<void> showEditRoleDialog(
    Map<String, dynamic> role,
  ) async {
    final roleId = getIntValue(
      role,
      ['role_id', 'id'],
    );

    final nameController =
        TextEditingController(
      text: getStringValue(
        role,
        ['role_name', 'name', 'title'],
      ),
    );

    final descriptionController =
        TextEditingController(
      text: getStringValue(
        role,
        ['description'],
      ),
    );

    bool isSaving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            dialogContext,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text('Edit Role'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      TextField(
                        controller:
                            nameController,
                        decoration:
                            const InputDecoration(
                          labelText: 'Role Name',
                          prefixIcon:
                              Icon(Icons.security),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller:
                            descriptionController,
                        maxLines: 3,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Description',
                          prefixIcon:
                              Icon(Icons.description),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
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
                ElevatedButton.icon(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final roleName =
                              nameController.text
                                  .trim();

                          final description =
                              descriptionController
                                  .text
                                  .trim();

                          if (roleId == 0) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Invalid role ID.',
                                ),
                              ),
                            );
                            return;
                          }

                          if (roleName.isEmpty) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Role name is required.',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            await ApiService
                                .updateRole(
                              roleId,
                              {
                                'role_name':
                                    roleName,
                                'description':
                                    description.isEmpty
                                        ? null
                                        : description,
                              },
                            );

                           if (!mounted || !dialogContext.mounted) return;

                             Navigator.pop(
                               dialogContext,
                                 );

                            await loadRoles();

                            if (!mounted) return;

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Role updated successfully.',
                                ),
                              ),
                            );
                          } catch (e) {
                            setDialogState(() {
                              isSaving = false;
                            });

                            if (!mounted) return;

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to update role: $e',
                                ),
                              ),
                            );
                          }
                        },
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label:
                      const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
  }

  // ============================================================
  // DELETE ROLE
  // ============================================================

  Future<void> deleteRole(
    Map<String, dynamic> role,
  ) async {
    final roleId = getIntValue(
      role,
      ['role_id', 'id'],
    );

    final roleName = getStringValue(
      role,
      ['role_name', 'name', 'title'],
      defaultValue: 'this role',
    );

    if (roleId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid role ID.'),
        ),
      );
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Role?'),
          content: Text(
            'Are you sure you want to delete "$roleName"?',
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
      await ApiService.deleteRole(roleId);

      await loadRoles();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Role deleted successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete role: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

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
                  'Unable to load roles.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });

                loadRoles();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget buildEmpty() {
    return RefreshIndicator(
      onRefresh: loadRoles,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          const Icon(
            Icons.security_outlined,
            size: 70,
          ),
          const SizedBox(height: 18),
          const Text(
            'No roles found.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: showAddRoleDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Role'),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ROLE LIST
  // ============================================================

  Widget buildRoleList() {
    return RefreshIndicator(
      onRefresh: loadRoles,
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          90,
        ),
        itemCount: roles.length,
        itemBuilder: (context, index) {
          final role = roles[index];

          final roleId = getIntValue(
            role,
            ['role_id', 'id'],
          );

          final roleName = getStringValue(
            role,
            ['role_name', 'name', 'title'],
            defaultValue: 'Role',
          );

          final description = getStringValue(
            role,
            ['description'],
            defaultValue: 'No description',
          );

          return Card(
            margin: const EdgeInsets.only(
              bottom: 12,
            ),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.security),
              ),
              title: Text(
                roleName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Role ID: '
                '${roleId == 0 ? 'N/A' : roleId}'
                '\n$description',
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'View',
                    icon: const Icon(
                      Icons.visibility,
                    ),
                    onPressed: () {
                      showRoleDetails(role);
                    },
                  ),
                  IconButton(
                    tooltip: 'Edit',
                    icon: const Icon(
                      Icons.edit,
                    ),
                    onPressed: () {
                      showEditRoleDialog(role);
                    },
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      deleteRole(role);
                    },
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
  // MAIN UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Role & Permissions',
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                isLoading ? null : loadRoles,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? buildLoading()
          : errorMessage != null
              ? buildError()
              : roles.isEmpty
                  ? buildEmpty()
                  : buildRoleList(),
      floatingActionButton: roles.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: showAddRoleDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Role'),
            ),
    );
  }
    }