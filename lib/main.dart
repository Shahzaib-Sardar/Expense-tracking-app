import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

import 'pages/onboarding.dart';
import 'pages/login.dart';
import 'pages/signup.dart';
import 'pages/main_navigation.dart';
import 'pages/profile.dart';
import 'pages/addexpense.dart';
import 'pages/addincome.dart';
import 'pages/monthly_budget.dart';
import 'pages/transaction_history.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load local secrets from .env for development. In CI/release, use
  // --dart-define values; those take precedence in AppEnv.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Allow execution when .env is missing and values come from --dart-define.
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xffee6856),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xffee6856),
          primary: Color(0xffee6856),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => Onboarding(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => MainNavigation(),
        '/profile': (context) => ProfilePage(),
        '/addexpense': (context) => AddExpensePage(),
        '/addincome': (context) => AddIncomePage(),
        '/budget': (context) => SetMonthlyBudgetPage(),
        '/history': (context) => TransactionHistoryPage(),
      },
    );
  }
}