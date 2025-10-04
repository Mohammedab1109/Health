import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health/services/auth_service.dart';
import 'package:health/theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit profile page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit profile functionality coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: AppColors.errorRed)))
              : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    final firstName = _userData?['firstName'] ?? '';
    final lastName = _userData?['lastName'] ?? '';
    final fullName = _userData?['fullName'] ?? 'User';
    final email = _userData?['email'] ?? '';
    final gender = _userData?['gender'] ?? '';
    final createdAt = _userData?['createdAt'] as Timestamp?;
    final joinDate = createdAt != null 
        ? '${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}'
        : 'Unknown';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Header
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.lightGray,
              child: Text(
                '${firstName[0]}${lastName[0]}',
                style: const TextStyle(
                  fontSize: 40, 
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              fullName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.vibrantTeal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Joined $joinDate',
                style: const TextStyle(
                  color: AppColors.vibrantTeal,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Profile Information
            const Divider(),
            _buildInfoSection('Personal Information'),
            _buildInfoTile('Email', email, Icons.email),
            _buildInfoTile('Gender', gender, Icons.person),
            
            const Divider(height: 32),
            _buildInfoSection('Fitness Goals & Stats'),
            
            // Placeholder for fitness goals (to be implemented)
            _buildInfoTile('Height', 'Not set', Icons.height),
            _buildInfoTile('Weight', 'Not set', Icons.monitor_weight_outlined),
            _buildInfoTile('Fitness Goal', 'Not set', Icons.flag),
            
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Update fitness goals functionality coming soon!'),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Set Fitness Goals'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vibrantTeal,
                foregroundColor: Colors.white,
              ),
            ),
            
            const Divider(height: 32),
            _buildInfoSection('Activity Summary'),
            
            // Placeholder for activity stats (to be implemented)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard('Events\nAttended', '0', Icons.event_available),
                  _buildStatCard('Events\nCreated', '0', Icons.create),
                  _buildStatCard('Workout\nCount', '0', Icons.fitness_center),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () async {
                // Show confirmation dialog
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Sign Out', style: TextStyle(color: AppColors.errorRed)),
                      ),
                    ],
                  ),
                );
                
                if (result == true) {
                  await AuthService.signOut();
                  // No need to navigate, main.dart will handle this
                }
              },
              icon: const Icon(Icons.logout, color: AppColors.errorRed),
              label: const Text('Sign Out', style: TextStyle(color: AppColors.errorRed)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoTile(String label, String value, IconData icon) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.lightGray,
        child: Icon(icon, color: AppColors.primaryBlue),
      ),
      title: Text(label),
      subtitle: Text(
        value.isNotEmpty ? value : 'Not provided',
        style: TextStyle(
          fontWeight: value.isNotEmpty ? FontWeight.w500 : FontWeight.normal,
          color: value.isNotEmpty ? Colors.black87 : Colors.grey,
        ),
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.energeticOrange, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}