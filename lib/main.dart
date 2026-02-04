import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/student_dashboard.dart';
import 'screens/staff_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('en_US', null);

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  final role = prefs.getString('user_role');
  final name = prefs.getString('user_name');

  // Decide initial screen
  Widget initialScreen;
  if (token != null && role != null && name != null) {
    initialScreen = role == "staff"
        ? StaffDashboard(userName: name, token: token)
        : StudentDashboard(userName: name, token: token);
  } else {
    initialScreen = const LoginScreen();
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: initialScreen,
    );
  }
}
