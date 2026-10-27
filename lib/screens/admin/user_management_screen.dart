import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState
    extends State<UserManagementScreen> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> roles = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  // ============================================================
  // LOAD USERS AND ROLES
  // ============================================================

  Future<void> loadUsers() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final results = await Future.wait([
        ApiService.getUsers(),
        ApiService.getRoles(),
      ]);

      final userData = results[0]
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      final roleData = results[1]
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      if (!mounted) return;

      setState(() {
        users = userData;
        roles = roleData;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load users: $e';
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

  bool isUserActive(Map<String, dynamic> user) {
    final value = user['is_active'];

    if (value is bool) return value;

    final text = value?.toString().toLowerCase().trim();

    return text == 'true' || text == '1' || text == 'active';
  }

  String getRoleName(int roleId) {
    for (final role in roles) {
      final currentRoleId = getIntValue(
        role,
        ['role_id', 'id'],
      );

      if (currentRoleId == roleId) {
        return getStringValue(
          role,
          ['role_name', 'name', 'title'],
          defaultValue: 'Role',
        );
      }
    }

    return roleId == 0 ? 'Role not assigned' : 'Role $roleId';
  }

  // ============================================================
  // VIEW USER DETAILS
  // ============================================================

  Future<void> showUserDetails(
    Map<String, dynamic> user,
  ) async {
    final userId = getIntValue(user, ['user_id', 'id']);
    final name = getStringValue(
      user,
      ['name'],
      defaultValue: 'User',
    );
    final email = getStringValue(
      user,
      ['email'],
      defaultValue: 'Not available',
    );
    final phone = getStringValue(
      user,
      ['phone'],
      defaultValue: 'Not available',
    );
    final roleId = getIntValue(user, ['role_id']);
    final active = isUserActive(user);

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          scrollable: true,
          title: Text(name),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow(
                'User ID',
                userId == 0 ? 'Not available' : '$userId',
              ),
              _detailRow('Name', name),
              _detailRow('Email', email),
              _detailRow('Phone', phone),
              _detailRow('Role', getRoleName(roleId)),
              _detailRow(
                'Status',
                active ? 'Active' : 'Inactive',
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

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          SelectableText(value),
        ],
      ),
    );
  }

  // ============================================================
  // ADD USER
  // ============================================================

  Future<void> showAddUserDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();

    int? selectedRoleId;
    bool isActive = true;
    bool isSaving = false;
    bool obscurePassword = true;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return AlertDialog(
                scrollable: true,
                title: const Text('Add User'),
                content: SizedBox(
                  width: 440,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Name *',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password *',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setDialogState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: selectedRoleId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Role *',
                          prefixIcon: Icon(Icons.badge),
                          border: OutlineInputBorder(),
                        ),
                        items: roles.map((role) {
                          final roleId = getIntValue(
                            role,
                            ['role_id', 'id'],
                          );

                          final roleName = getStringValue(
                            role,
                            ['role_name', 'name', 'title'],
                            defaultValue: 'Role $roleId',
                          );

                          return DropdownMenuItem<int>(
                            value: roleId,
                            child: Text(
                              roleName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: isSaving
                            ? null
                            : (value) {
                                setDialogState(() {
                                  selectedRoleId = value;
                                });
                              },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Active'),
                        value: isActive,
                        onChanged: isSaving
                            ? null
                            : (value) {
                                setDialogState(() {
                                  isActive = value;
                                });
                              },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isSaving
                        ? null
                        : () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton.icon(
                    onPressed: isSaving
                        ? null
                        : () async {
                            final name = nameController.text.trim();
                            final email = emailController.text.trim();
                            final password =
                                passwordController.text.trim();
                            final phone = phoneController.text.trim();

                            if (name.isEmpty ||
                                email.isEmpty ||
                                password.isEmpty) {
                              _showMessage(
                                'Name, email and password are required.',
                              );
                              return;
                            }

                            if (selectedRoleId == null) {
                              _showMessage('Please select a role.');
                              return;
                            }

                            setDialogState(() {
                              isSaving = true;
                            });

                            try {
                              await ApiService.createUser({
                                'name': name,
                                'email': email,
                                'password': password,
                                'phone': phone.isEmpty ? null : phone,
                                'role_id': selectedRoleId,
                                'is_active': isActive,
                              });

                              if (!mounted || !dialogContext.mounted) return;

Navigator.pop(dialogContext);
_showMessage('User created successfully.');
await loadUsers();
                            } catch (e) {
                              setDialogState(() {
                                isSaving = false;
                              });

                              _showMessage('Failed to create user: $e');
                            }
                          },
                    icon: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.person_add),
                    label: const Text('Add User'),
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
      passwordController.dispose();
      phoneController.dispose();
    }
  }

  // ============================================================
  // EDIT USER
  // ============================================================

  Future<void> showEditUserDialog(
    Map<String, dynamic> user,
  ) async {
    final userId = getIntValue(user, ['user_id', 'id']);

    if (userId == 0) {
      _showMessage('Invalid user ID.');
      return;
    }

    final nameController = TextEditingController(
      text: getStringValue(user, ['name']),
    );
    final emailController = TextEditingController(
      text: getStringValue(user, ['email']),
    );
    final phoneController = TextEditingController(
      text: getStringValue(user, ['phone']),
    );
    final passwordController = TextEditingController();

    final existingRoleId = getIntValue(user, ['role_id']);

    int? selectedRoleId = roles.any(
      (role) => getIntValue(role, ['role_id', 'id']) == existingRoleId,
    )
        ? existingRoleId
        : null;

    bool isActive = isUserActive(user);
    bool isSaving = false;
    bool obscurePassword = true;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return AlertDialog(
                scrollable: true,
                title: const Text('Edit User'),
                content: SizedBox(
                  width: 440,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Name *',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'New Password (optional)',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setDialogState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Leave blank to keep the current password, '
                          'if supported by the backend.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: selectedRoleId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Role *',
                          prefixIcon: Icon(Icons.badge),
                          border: OutlineInputBorder(),
                        ),
                        items: roles.map((role) {
                          final roleId = getIntValue(
                            role,
                            ['role_id', 'id'],
                          );

                          final roleName = getStringValue(
                            role,
                            ['role_name', 'name', 'title'],
                            defaultValue: 'Role $roleId',
                          );

                          return DropdownMenuItem<int>(
                            value: roleId,
                            child: Text(
                              roleName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: isSaving
                            ? null
                            : (value) {
                                setDialogState(() {
                                  selectedRoleId = value;
                                });
                              },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Active'),
                        value: isActive,
                        onChanged: isSaving
                            ? null
                            : (value) {
                                setDialogState(() {
                                  isActive = value;
                                });
                              },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isSaving
                        ? null
                        : () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton.icon(
                    onPressed: isSaving
                        ? null
                        : () async {
                            final name = nameController.text.trim();
                            final email = emailController.text.trim();
                            final password =
                                passwordController.text.trim();
                            final phone = phoneController.text.trim();

                            if (name.isEmpty || email.isEmpty) {
                              _showMessage(
                                'Name and email are required.',
                              );
                              return;
                            }

                            if (selectedRoleId == null) {
                              _showMessage('Please select a role.');
                              return;
                            }

                            setDialogState(() {
                              isSaving = true;
                            });

                            final data = <String, dynamic>{
                              'name': name,
                              'email': email,
                              'phone': phone.isEmpty ? null : phone,
                              'role_id': selectedRoleId,
                              'is_active': isActive,
                            };

                            // Only send a password when the user entered one.
                            if (password.isNotEmpty) {
                              data['password'] = password;
                            }

                            try {
                              await ApiService.updateUser(
                                userId,
                                data,
                              );

                              if (!mounted || !dialogContext.mounted) return;

Navigator.pop(dialogContext);
_showMessage('User updated successfully.');
await loadUsers();
                            } catch (e) {
                              setDialogState(() {
                                isSaving = false;
                              });

                              _showMessage('Failed to update user: $e');
                            }
                          },
                    icon: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: const Text('Save Changes'),
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
      passwordController.dispose();
    }
  }

  // ============================================================
  // DELETE USER
  // ============================================================

  Future<void> deleteUser(Map<String, dynamic> user) async {
    final userId = getIntValue(user, ['user_id', 'id']);
    final name = getStringValue(
      user,
      ['name'],
      defaultValue: 'this user',
    );

    if (userId == 0) {
      _showMessage('Invalid user ID.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Delete User?'),
          content: Text('Are you sure you want to delete "$name"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await ApiService.deleteUser(userId);

      if (!mounted) return;

      _showMessage('User deleted successfully.');
      await loadUsers();
    } catch (e) {
      _showMessage('Failed to delete user: $e');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  // ============================================================
  // LOADING, ERROR AND EMPTY STATES
  // ============================================================

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildError() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60),
            const SizedBox(height: 14),
            Text(
              errorMessage ?? 'Unable to load users.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: loadUsers,
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
      onRefresh: loadUsers,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          const Icon(Icons.manage_accounts_outlined, size: 70),
          const SizedBox(height: 18),
          const Text(
            'No users found.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: showAddUserDialog,
              icon: const Icon(Icons.person_add),
              label: const Text('Add User'),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // USER CARD
  // ============================================================

  Widget buildUserCard(Map<String, dynamic> user) {
    final name = getStringValue(
      user,
      ['name'],
      defaultValue: 'User',
    );

    final userId = getIntValue(user, ['user_id', 'id']);
    final email = getStringValue(
      user,
      ['email'],
      defaultValue: 'No email',
    );
    final phone = getStringValue(
      user,
      ['phone'],
      defaultValue: 'No phone',
    );
    final roleId = getIntValue(user, ['role_id']);
    final active = isUserActive(user);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              child: Icon(
                active ? Icons.person : Icons.person_off,
              ),
            ),
            const SizedBox(width: 10),

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
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text('ID: ${userId == 0 ? 'N/A' : userId}'),
                  const SizedBox(height: 3),
                  Text(
                    email,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Role: ${getRoleName(roleId)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 4),

            SizedBox(
              width: 94,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: active
                          ? Colors.green.withValues(alpha: 0.12)
                          : Colors.red.withValues(alpha: 0.12),
                    ),
                    child: Text(
                      active ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 12,
                        color: active ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 0,
                    children: [
                      IconButton(
                        tooltip: 'View',
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(
                          minWidth: 30,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.visibility, size: 18),
                        onPressed: () => showUserDetails(user),
                      ),
                      IconButton(
                        tooltip: 'Edit',
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(
                          minWidth: 30,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () => showEditUserDialog(user),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(
                          minWidth: 30,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 18,
                        ),
                        onPressed: () => deleteUser(user),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUserList() {
    return RefreshIndicator(
      onRefresh: loadUsers,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
        itemCount: users.length,
        itemBuilder: (context, index) {
          return buildUserCard(users[index]);
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
        title: const Text('User Management'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: isLoading ? null : loadUsers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? buildLoading()
          : errorMessage != null
              ? buildError()
              : users.isEmpty
                  ? buildEmpty()
                  : buildUserList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddUserDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Add User'),
      ),
    );
  }
}