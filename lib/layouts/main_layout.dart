import 'package:flutter/material.dart';
import 'package:health/pages/home_page.dart';
import 'package:health/pages/profile_page.dart';
import 'package:health/pages/edit_profile_page.dart';
import 'package:health/theme/app_theme.dart';
import 'package:health/pages/create_event_page.dart';
import 'package:health/pages/event_list_page.dart';
import 'package:health/pages/test_image_upload_page.dart';
import 'package:health/pages/pose_detection_screen.dart';

class MainLayout extends StatefulWidget {
  final int initialPageIndex;

  const MainLayout({
    super.key, 
    this.initialPageIndex = 0,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPageIndex;
    _pages = [
      const HomePage(),
      const EventListPage(),
      const PoseDetectionScreen(), // ML-based pose detection and analysis
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      appBar: _currentIndex == 3 ? AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              ).then((_) {
                // Refresh profile page when returning from edit page
                setState(() {
                  _pages[3] = const ProfilePage();
                });
              });
            },
          ),
          // Keep test button for development
          IconButton(
            icon: const Icon(Icons.science),
            tooltip: 'Test Image Upload',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TestImageUploadPage(),
                ),
              );
            },
          ),
        ],
      ) : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.vibrantTeal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Analysis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1 ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateEventPage(isAdmin: false),
            ),
          );
        },
        backgroundColor: AppColors.vibrantTeal,
        child: const Icon(Icons.add),
      ) : null,
    );
  }
}