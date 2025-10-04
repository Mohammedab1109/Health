import 'package:flutter/material.dart';
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
    final gender = _userData?['gender'] ?? '';
    
    // Default fitness profile data that would normally be loaded from Firestore
    final height = _userData?['height'] ?? '--';
    final weight = _userData?['weight'] ?? '--';
    final fitnessLevel = _userData?['fitnessLevel'] ?? 'Beginner';
    final bodyFat = _userData?['bodyFat'] ?? '--';
    final activityLevel = _userData?['activityLevel'] ?? 'Moderate';
    final restingHeartRate = _userData?['restingHeartRate'] ?? '--';
    final vo2Max = _userData?['vo2Max'] ?? '--';
    
    // Example favorite activities - in a real app, these would come from the database
    final List<String> favoriteActivities = [
      'Running', 'Cycling', 'Swimming', 'Yoga', 'Weight Training'
    ];
    
    final createdAt = _userData?['createdAt'] as Timestamp?;
    final joinDate = createdAt != null 
        ? '${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}'
        : 'Unknown';
        
    // Get initials for avatar
    String initials = '';
    if (firstName.isNotEmpty) initials += firstName[0];
    if (lastName.isNotEmpty) initials += lastName[0];
    if (initials.isEmpty) initials = 'U';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Header with Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryBlue, AppColors.vibrantTeal],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    // Profile Picture
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: AppColors.energeticOrange,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 40, 
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // User Name
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // User Status and Join Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            fitnessLevel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Joined $joinDate',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Quick Stats
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _buildQuickStats(height, weight, bodyFat, activityLevel),
          ),

          // Basic Information
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Gender', gender, Icons.person),
                    _buildInfoRow('Activity Level', activityLevel, Icons.directions_run),
                    _buildInfoRow('Fitness Level', fitnessLevel, Icons.fitness_center),
                    _buildInfoRow('Height', height != '--' ? '$height cm' : '--', Icons.height),
                    _buildInfoRow('Weight', weight != '--' ? '$weight kg' : '--', Icons.monitor_weight),
                  ],
                ),
              ),
            ),
          ),
          
          // Favorite Activities
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Favorite Activities',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20, color: AppColors.vibrantTeal),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Edit activities coming soon!')),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: favoriteActivities.map((activity) => _buildActivityChip(activity)).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Health Metrics
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Health Metrics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHealthMetric('Resting HR', '$restingHeartRate bpm', Icons.favorite, AppColors.errorRed),
                        _buildHealthMetric('VO2 Max', '$vo2Max ml/kg/min', Icons.air, AppColors.vibrantTeal),
                        _buildHealthMetric('Sleep', '7.5 hrs/day', Icons.nightlight, AppColors.primaryBlue),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Fitness Goals
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fitness Goals',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildGoalRow('Run 10km under 50 minutes', 0.7),
                    const SizedBox(height: 12),
                    _buildGoalRow('Bench press 100kg', 0.4),
                    const SizedBox(height: 12),
                    _buildGoalRow('Lose 5kg', 0.6),
                  ],
                ),
              ),
            ),
          ),
          
          // Activity and Achievements
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Activity & Achievements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActivityStat('5', 'Events\nAttended', Icons.event_available, AppColors.vibrantTeal),
                        _buildActivityStat('2', 'Events\nCreated', Icons.create, AppColors.energeticOrange),
                        _buildActivityStat('12', 'Workouts\nCompleted', Icons.fitness_center, AppColors.primaryBlue),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress bar for next achievement
                    const Text(
                      'Next Achievement: 15 Workouts',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 12 / 15, // 12 workouts out of 15 needed
                        minHeight: 8,
                        backgroundColor: AppColors.lightGray,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.vibrantTeal),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Upcoming Events
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upcoming Events',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildEventCard(
                      'Morning Run Group',
                      'Oct 10, 7:00 AM',
                      'Central Park',
                      Icons.directions_run,
                    ),
                    _buildEventCard(
                      'Yoga Workshop',
                      'Oct 15, 6:30 PM',
                      'Wellness Studio',
                      Icons.self_improvement,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Sign Out Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ElevatedButton.icon(
              onPressed: () async {
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
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: AppColors.darkGray,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickStats(String height, String weight, String bodyFat, String activityLevel) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickStatItem('Height', height, Icons.height),
            _buildDivider(),
            _buildQuickStatItem('Weight', weight, Icons.fitness_center),
            _buildDivider(),
            _buildQuickStatItem('Body Fat', bodyFat, Icons.pie_chart),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildQuickStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.vibrantTeal),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.lightMint,
            child: Icon(icon, color: AppColors.vibrantTeal, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value.isNotEmpty ? value : 'Not provided',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: value.isNotEmpty ? Colors.black87 : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityChip(String activity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.vibrantTeal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.vibrantTeal.withOpacity(0.3)),
      ),
      child: Text(
        activity,
        style: const TextStyle(
          color: AppColors.vibrantTeal,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  Widget _buildActivityStat(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.darkGray,
          ),
        ),
      ],
    );
  }
  
  Widget _buildEventCard(String title, String dateTime, String location, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.lightMint,
          child: Icon(icon, color: AppColors.vibrantTeal),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: AppColors.darkGray),
                const SizedBox(width: 4),
                Text(
                  dateTime,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: AppColors.darkGray),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to event details
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event details coming soon!'),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildHealthMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.darkGray,
          ),
        ),
      ],
    );
  }
  
  Widget _buildGoalRow(String goalText, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.flag, 
              color: AppColors.vibrantTeal, 
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                goalText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: progress > 0.7 ? AppColors.successGreen : AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.lightGray,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 0.7 ? AppColors.successGreen : AppColors.vibrantTeal,
            ),
          ),
        ),
      ],
    );
  }
}