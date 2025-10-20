import 'package:flutter/material.dart';
import 'package:intellitest_app/src/pages/login_page.dart';
import 'package:intellitest_app/src/pages/register_page.dart';
import 'package:intellitest_app/src/pages/welcome_page.dart'; // ✅ add this
import 'pages/dashboard_page.dart';
import 'pages/question_bank_page.dart';
import 'pages/test_editor_page.dart';
import 'pages/test_taking_page.dart';
import 'pages/analytics_page.dart';
import 'pages/courses_page.dart';
import 'pages/test_bank_page.dart';
import 'pages/gradebook_page.dart';
import 'pages/calendar_page.dart';
import 'services/api_service.dart';

// Configure API base URL here (update to your Django backend URL)
const _defaultApiBase = 'http://localhost:8080';

class IntelliTestApp extends StatelessWidget {
  const IntelliTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize ApiService with default base URL (can be overridden)
    ApiService.instance = ApiService(baseUrl: _defaultApiBase);

    return MaterialApp(
      title: 'IntelliTest APP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // 👇 Show Welcome Page first
      initialRoute: '/welcome',
      routes: {
        // ignore: prefer_const_constructors
        '/welcome': (c) => WelcomePage(), // ✅ add welcome route
        '/': (c) => const DashboardPage(),
        '/login': (c) => const LoginPage(),
        '/register': (c) => const RegisterPage(),
        '/question-bank': (c) => const QuestionBankPage(),
        '/editor': (c) => const TestEditorPage(),
        '/take': (c) => const TestTakingPage(),
        '/analytics': (c) => const AnalyticsPage(),
        '/courses': (c) => const CoursesPage(),
        '/test-bank': (c) => const TestBankPage(),
        '/gradebook': (c) => const GradebookPage(),
        '/calendar': (c) => const CalendarPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
