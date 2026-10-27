import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'faculty_dashboard.dart';

class FacultyLoginScreen extends StatefulWidget {
  const FacultyLoginScreen({super.key});

  @override
  State<FacultyLoginScreen> createState() =>
      _FacultyLoginScreenState();
}

class _FacultyLoginScreenState extends State<FacultyLoginScreen> {
  final TextEditingController facultyIdController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool isPasswordVisible = false;
  bool isLoggingIn = false;

  String normalizeFacultyCode(String value) {
    return value.trim().toLowerCase();
  }

  int? extractNumericId(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString().trim() ?? '',
    );
  }

  int? facultyCodeToNumericId(String value) {
    final cleaned = value.trim().toUpperCase();

    // FAC001 -> 1
    if (cleaned.startsWith('FAC')) {
      final numberPart =
          cleaned.substring(3).trim();

      return int.tryParse(numberPart);
    }

    // Also allow entering just 1, 3, 5, etc.
    return int.tryParse(cleaned);
  }

  Future<void> login() async {
    final enteredFacultyId =
        facultyIdController.text.trim();

    final password =
        passwordController.text.trim();

    if (enteredFacultyId.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter Faculty ID and Password',
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoggingIn = true;
    });

    try {
      final facultyList =
          await ApiService.getFaculty();

      int? loggedInFacultyId;

      final enteredCode =
          normalizeFacultyCode(
        enteredFacultyId,
      );

      final enteredNumericId =
          facultyCodeToNumericId(
        enteredFacultyId,
      );

      for (final item in facultyList) {
        if (item is! Map) {
          continue;
        }

        final faculty =
            Map<String, dynamic>.from(item);

        // Database primary key
        final databaseFacultyId =
            faculty['faculty_id'] ??
                faculty['id'] ??
                faculty['facultyId'];

        final numericDatabaseId =
            extractNumericId(
          databaseFacultyId,
        );

        // Possible faculty code fields
        final facultyCode =
            faculty['faculty_code'] ??
                faculty['faculty_code_id'] ??
                faculty['facultyId'] ??
                faculty['code'] ??
                faculty['faculty_number'];

        final databaseCode =
            facultyCode?.toString().trim();

        bool matched = false;

        // Example:
        // FAC001 == FAC001
        if (databaseCode != null &&
            databaseCode.isNotEmpty &&
            enteredCode ==
                databaseCode.toLowerCase()) {
          matched = true;
        }

        // Example:
        // FAC001 -> 1
        // database ID -> 1
        if (!matched &&
            enteredNumericId != null &&
            numericDatabaseId != null &&
            enteredNumericId ==
                numericDatabaseId) {
          matched = true;
        }

        // Example:
        // User enters 1 and database ID is 1
        if (!matched &&
            enteredNumericId != null &&
            numericDatabaseId != null &&
            enteredNumericId ==
                numericDatabaseId) {
          matched = true;
        }

        if (matched &&
            numericDatabaseId != null) {
          loggedInFacultyId =
              numericDatabaseId;
          break;
        }
      }

      if (!mounted) return;

      if (loggedInFacultyId == null) {
        setState(() {
          isLoggingIn = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Faculty ID not found in the database.',
            ),
          ),
        );

        return;
      }

      setState(() {
        isLoggingIn = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FacultyDashboard(
            facultyId: loggedInFacultyId!,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoggingIn = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load faculty data: $e',
          ),
        ),
      );
    }
  }

  void forgotPassword() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Forgot Password'),
          content: const Text(
            'Password reset will be connected with the backend later.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    facultyIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Login'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(
                    alpha: 0.10,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.school_outlined,
                  size: 50,
                  color: primaryColor,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Welcome, Faculty',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Login to manage your classes and students',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 32),

              TextField(
                controller: facultyIdController,
                textInputAction:
                    TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Faculty ID',
                  hintText: 'Example: FAC001',
                  prefixIcon:
                      Icon(Icons.badge_outlined),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText:
                    !isPasswordVisible,
                onSubmitted: (_) => login(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter Password',
                  prefixIcon:
                      const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip:
                        isPasswordVisible
                            ? 'Hide password'
                            : 'Show password',
                    icon: Icon(
                      isPasswordVisible
                          ? Icons
                              .visibility_off_outlined
                          : Icons
                              .visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible =
                            !isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Align(
                alignment:
                    Alignment.centerRight,
                child: TextButton(
                  onPressed: forgotPassword,
                  child: const Text(
                    'Forgot Password?',
                  ),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed:
                    isLoggingIn ? null : login,
                icon: isLoggingIn
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.login),
                label: Text(
                  isLoggingIn
                      ? 'Checking...'
                      : 'Login',
                ),
              ),

              const SizedBox(height: 22),

              Container(
                padding:
                    const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(
                    alpha: 0.06,
                  ),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Text(
                  'Use a Faculty ID from the database, such as FAC001, FAC003, FAC005, or FAC006.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Faculty data is loaded from the backend database.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}