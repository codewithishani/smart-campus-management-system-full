import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminProfileScreen extends StatefulWidget {
const AdminProfileScreen({super.key});

@override
State<AdminProfileScreen> createState() =>
_AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
Map<String, dynamic>? admin;

bool isLoading = true;
String? errorMessage;

@override
void initState() {
super.initState();
loadAdminProfile();
}

Future<void> loadAdminProfile() async {
try {
final users = await ApiService.getUsers();

  Map<String, dynamic>? adminUser;

  for (final item in users) {
    if (item is! Map) continue;

    final user = Map<String, dynamic>.from(item);

    final roleId = getIntValue(
      user,
      ['role_id'],
    );

    final role = getStringValue(
      user,
      ['role'],
    ).toLowerCase();

    if (roleId == 4 ||
        role == 'admin' ||
        role == 'administrator') {
      adminUser = user;
      break;
    }
  }

  if (!mounted) return;

  setState(() {
    admin = adminUser;
    isLoading = false;
    errorMessage = adminUser == null
        ? 'Administrator account not found.'
        : null;
  });
} catch (e) {
  if (!mounted) return;

  setState(() {
    isLoading = false;
    errorMessage = 'Unable to load administrator profile.';
  });
}


}

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
String defaultValue = 'Not available',
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
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(
Icons.error_outline,
size: 60,
),
const SizedBox(height: 14),
Text(
errorMessage ??
'Unable to load administrator profile.',
textAlign: TextAlign.center,
),
const SizedBox(height: 18),
ElevatedButton.icon(
onPressed: () {
setState(() {
isLoading = true;
errorMessage = null;
});


            loadAdminProfile();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    ),
  ),
);

}

Widget buildProfile() {
final data = admin!;


final name = getStringValue(
  data,
  ['name'],
  defaultValue: 'Administrator',
);

final userId = getStringValue(
  data,
  ['user_id', 'id'],
);

final email = getStringValue(
  data,
  ['email'],
);

final phone = getStringValue(
  data,
  ['phone'],
);

final role = getStringValue(
  data,
  ['role'],
  defaultValue: 'Administrator',
);

final activeValue = data['is_active'];

final isActive = activeValue is bool
    ? activeValue
    : activeValue?.toString().toLowerCase() == 'true';

return RefreshIndicator(
  onRefresh: loadAdminProfile,
  child: ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(16),
    children: [
      const SizedBox(height: 20),
      const CircleAvatar(
        radius: 50,
        child: Icon(
          Icons.admin_panel_settings,
          size: 55,
        ),
      ),
      const SizedBox(height: 15),
      Center(
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(height: 20),
      _info(
        'Admin ID',
        userId,
      ),
      _info(
        'Email',
        email,
      ),
      _info(
        'Phone',
        phone,
      ),
      _info(
        'Role',
        role,
      ),
      _info(
        'Status',
        isActive ? 'Active' : 'Inactive',
      ),
      const SizedBox(height: 12),
      const Card(
        child: ListTile(
          leading: Icon(
            Icons.info_outline,
          ),
          title: Text(
            'Profile information',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
              'Administrator profile information is loaded from the campus database.',
            ),
          ),
        ),
      ),
    ],
  ),
);


}

Widget _info(
String title,
String value,
) {
return Card(
child: ListTile(
title: Text(title),
subtitle: Text(
value,
style: const TextStyle(
fontWeight: FontWeight.w600,
),
),
),
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Admin Profile'),
),
body: isLoading
? buildLoading()
: errorMessage != null
? buildError()
: admin == null
? buildError()
: buildProfile(),
);
}
}
