import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // User role constants
  static const String ROLE_USER = 'user';
  static const String ROLE_ADMIN = 'admin';
  
  // Get current user
  static User? get currentUser => _auth.currentUser;
  
  // Stream of authentication state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Check if user is signed in
  static bool isSignedIn() {
    return currentUser != null;
  }
  
  // Get current user role
  static Future<String> getCurrentUserRole() async {
    if (currentUser == null) return '';
    
    try {
      final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (doc.exists && doc.data()!.containsKey('role')) {
        return doc.data()!['role'] as String;
      } else {
        // Default role if not specified
        return ROLE_USER;
      }
    } catch (e) {
      print('Error getting user role: $e');
      return ROLE_USER;
    }
  }
  
  // Check if current user is an admin
  static Future<bool> isCurrentUserAdmin() async {
    final role = await getCurrentUserRole();
    return role == ROLE_ADMIN;
  }
  
  // Sign in with email and password
  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  
  // Create user account with specified role
  static Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String gender,
    String role = ROLE_USER,
  }) async {
    UserCredential userCredential;
    
    try {
      // First create the user account
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Combine first and last name
      final fullName = '$firstName $lastName';
      
      try {
        // Add user details to Firestore with role
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'fullName': fullName,
          'email': email,
          'gender': gender,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        // Update user display name
        await userCredential.user!.updateDisplayName(fullName);
      } catch (e) {
        print('Error setting user data in Firestore: $e');
        // If we can't set user data, delete the created user to avoid orphaned accounts
        try {
          await userCredential.user?.delete();
          throw Exception('Failed to setup user profile. Please try again.');
        } catch (deleteError) {
          print('Error deleting user after failed setup: $deleteError');
          throw Exception('Account created but profile setup failed. Please contact support.');
        }
      }
    } catch (e) {
      print('Error in createUserWithEmailAndPassword: $e');
      rethrow; // Re-throw the exception to be handled by the caller
    }
    
    return userCredential;
  }
}