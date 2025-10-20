import 'package:flutter/material.dart';
import 'package:intellitest_app/src/pages/test_provider.dart';
import 'package:provider/provider.dart';

// Pages
import 'src/pages/dashboard_page.dart';
import 'src/pages/info_pages.dart';
import 'src/pages/login_page.dart';
import 'src/pages/register_page.dart';
import 'src/pages/test_bank_page.dart';
import 'src/pages/welcome_page.dart';
import 'src/pages/analytics_page.dart';
import 'src/pages/courses_page.dart';
import 'src/pages/question_bank_page.dart';
import 'src/pages/create_test_page.dart';
import 'src/pages/contact_page.dart';
import 'src/pages/gradebook_page.dart';
import 'src/pages/calendar_page.dart';

// Providers
// Your TestProvider

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TestProvider()),
        // Add other providers here if needed
      ],
      child: const IntelliTestApp(),
    ),
  );
}

class IntelliTestApp extends StatelessWidget {
  const IntelliTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IntelliTest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2563EB),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/about': (context) => const AboutPage(),
        '/contact': (context) => const ContactPage(),
        '/privacy': (context) => const PrivacyPolicyPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/analytics': (context) => const AnalyticsPage(),
        '/courses': (context) => const CoursesPage(),
        '/question-bank': (context) => const QuestionBankPage(),
        '/create-test': (context) => const CreateTestPage(),
        '/gradebook': (context) => const GradebookPage(),
        '/calendar': (context) => const CalendarPage(),
        '/test-bank': (context) => const TestBankPage(),
        '/settings': (context) =>
            const DashboardPage(), // Update to actual SettingsPage if available
      },
      onUnknownRoute: (settings) {
        // Fallback for missing routes
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
      },
    );
  }
}
