import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health/services/auth_service.dart';
import 'package:health/theme/app_theme.dart';
import 'package:health/pages/edit_profile_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = AuthService.currentUser;
      
      if (user != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
            
        if (docSnapshot.exists) {
          setState(() {
            _userData = docSnapshot.data();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'User profile not found';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'User not authenticated';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)));
    }

    final firstName = _userData?['firstName'] ?? '';
    final lastName = _userData?['lastName'] ?? '';
    final fullName = '$firstName $lastName';
    final email = _userData?['email'] ?? '';
    final gender = _userData?['gender'] ?? '';
    final role = _userData?['role'] ?? 'user';
    
    // Default fitness profile data that would normally be loaded from Firestore
    final height = _userData?['height'] ?? '--';
    final weight = _userData?['weight'] ?? '--';
    final fitnessLevel = _userData?['fitnessLevel'] ?? 'Beginner';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Edit Profile Button
            Align(
              alignment: Alignment.topRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfilePage(),
                    ),
                  );
                  
                  // Reload user data if profile was updated
                  if (updated == true) {
                    _loadUserData();
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Profile Header
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primaryBlue,
                  backgroundImage: _userData?['profileImageUrl'] != null && _userData!['profileImageUrl'].isNotEmpty
                      ? CachedNetworkImageProvider(_userData!['profileImageUrl'])
                      : null,
                  child: _userData?['profileImageUrl'] == null || _userData!['profileImageUrl'].isEmpty
                      ? Text(
                          fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                GestureDetector(
                  onTap: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    );
                    
                    // Reload user data if profile was updated
                    if (updated == true) {
                      _loadUserData();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: AppColors.vibrantTeal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              fullName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: role == 'admin' ? Colors.orange[100] : AppColors.primaryBlue.withOpacity(0.1),
              ),
              child: Text(
                role == 'admin' ? 'Admin' : 'User',
                style: TextStyle(
                  color: role == 'admin' ? Colors.orange[800] : AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Admin Stats
            _buildStatsCard(),
            
            const SizedBox(height: 24),
            
            // Logout Button
            ElevatedButton.icon(
              onPressed: () async {
                // Show confirmation dialog
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
                
                if (confirmed == true) {
                  await AuthService.signOut();
                  // No need to navigate - main.dart will handle this when auth state changes
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              icon: Icons.people,
              title: 'Users Managed',
              value: '142',
            ),
            _buildStatItem(
              icon: Icons.event,
              title: 'Events Created',
              value: '24',
            ),
            _buildStatItem(
              icon: Icons.star,
              title: 'Average Rating',
              value: '4.8/5',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem({required IconData icon, required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}