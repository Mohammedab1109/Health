import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:health/pages/sign_in_page.dart';
import 'package:health/services/auth_service.dart';
import 'package:health/widgets/loading_indicator.dart';
import 'package:health/theme/app_theme.dart';
import 'package:health/layouts/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return const SignInPage();
          } else {
            return const MainLayout();
          }
        }
        
        // Show loading indicator while checking auth state
        return const Scaffold(
          body: LoadingIndicator(message: 'Checking authentication...'),
        );
      },
    );
  }
}
