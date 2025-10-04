import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
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
}