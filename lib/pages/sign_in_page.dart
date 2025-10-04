import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health/pages/sign_up_page.dart';
import 'package:health/services/auth_service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedRole = AuthService.ROLE_USER;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        // Sign in with email and password
        final userCredential = await AuthService.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        // Verify the user's role if they selected admin
        if (_selectedRole == AuthService.ROLE_ADMIN) {
          try {
            final doc = await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .get();
            
            // Check if the user is actually an admin
            if (!doc.exists || doc.data()?['role'] != AuthService.ROLE_ADMIN) {
              // Sign out the user if they're not an admin
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                setState(() {
                  _errorMessage = 'You are not authorized as an admin';
                  _isLoading = false;
                });
              }
              return;
            }
          } catch (e) {
            print('Error checking admin role: $e');
            // Sign out on error to be safe
            await FirebaseAuth.instance.signOut();
            if (mounted) {
              setState(() {
                _errorMessage = 'Error verifying account type. Please try again.';
                _isLoading = false;
              });
            }
            return;
          }
        }
        
        // No need to navigate - main.dart will handle this when auth state changes
      } on FirebaseAuthException catch (e) {
        print('FirebaseAuthException during sign in: ${e.message}');
        setState(() {
          _errorMessage = e.message ?? 'An error occurred during sign in';
        });
      } catch (e) {
        print('Unexpected error during sign in: $e');
        setState(() {
          _errorMessage = 'An unexpected error occurred';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A3A6B),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and app name
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.fitness_center,
                    size: 60,
                    color: Color(0xFF1A3A6B),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'FitConnect',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Workout Together. Achieve More.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Sign in form container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A3A6B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sign in to continue your fitness journey',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 25),
                        
                        // Email field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            prefixIcon: const Icon(Icons.email, color: Color(0xFF1A3A6B)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock, color: Color(0xFF1A3A6B)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        
                        // Role selection
                        Row(
                          children: [
                            const Text('Sign in as:'),
                            const Spacer(),
                            ChoiceChip(
                              label: const Text('User'),
                              selected: _selectedRole == AuthService.ROLE_USER,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedRole = AuthService.ROLE_USER;
                                  });
                                }
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor: const Color(0xFF1A3A6B).withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: _selectedRole == AuthService.ROLE_USER 
                                    ? const Color(0xFF1A3A6B) 
                                    : Colors.black,
                                fontWeight: _selectedRole == AuthService.ROLE_USER
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(width: 10),
                            ChoiceChip(
                              label: const Text('Admin'),
                              selected: _selectedRole == AuthService.ROLE_ADMIN,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedRole = AuthService.ROLE_ADMIN;
                                  });
                                }
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor: const Color(0xFF1A3A6B).withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: _selectedRole == AuthService.ROLE_ADMIN 
                                    ? const Color(0xFF1A3A6B) 
                                    : Colors.black,
                                fontWeight: _selectedRole == AuthService.ROLE_ADMIN
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Password reset functionality could be added here
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF1A3A6B),
                            ),
                            child: const Text('Forgot Password?'),
                          ),
                        ),
                        
                        // Error message
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          
                        // Sign in button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF1A3A6B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            disabledBackgroundColor: const Color(0xFF1A3A6B).withOpacity(0.6),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('SIGN IN', style: TextStyle(fontSize: 16)),
                        ),
                        const SizedBox(height: 20),
                        
                        // Sign up option
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?"),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpPage(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF1A3A6B),
                              ),
                              child: const Text('Sign Up'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}