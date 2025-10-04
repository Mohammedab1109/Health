import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health/pages/sign_in_page.dart';
import 'package:health/pages/test_image_upload_page.dart';
import 'package:health/services/auth_service.dart';
import 'package:health/widgets/loading_indicator.dart';
import 'package:health/theme/app_theme.dart';
import 'package:health/layouts/main_layout.dart';
import 'package:health/layouts/admin_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return const SignInPage();
          } else {
            // User is authenticated, check their role
            return RoleBasedRouter(userId: user.uid);
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

class RoleBasedRouter extends StatelessWidget {
  final String userId;
  
  const RoleBasedRouter({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: LoadingIndicator(message: 'Loading your profile...'),
          );
        }
        
        // Handle errors by defaulting to user role
        if (snapshot.hasError) {
          print('Error retrieving user data: ${snapshot.error}');
          return const MainLayout(); // Default to user layout on error
        }
        
        if (!snapshot.hasData || !snapshot.data!.exists) {
          print('User document does not exist for ID: $userId');
          return const MainLayout(); // Default to user layout
        }
        
        try {
          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final role = data['role'] as String? ?? AuthService.ROLE_USER;
          
          if (role == AuthService.ROLE_ADMIN) {
            return const AdminLayout();
          } else {
            return const MainLayout();
          }
        } catch (e) {
          print('Error processing user data: $e');
          return const MainLayout(); // Default to user layout on any exception
        }
      },
    );
  }
}
