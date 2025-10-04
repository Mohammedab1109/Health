import 'package:flutter/material.dart';
import 'package:health/models/sport_event.dart';
import 'package:health/services/event_service.dart';
import 'package:health/services/auth_service.dart';
import 'package:health/widgets/loading_indicator.dart';
import 'package:health/pages/events/create_event_page.dart';
import 'package:health/pages/events/event_details_page.dart';
import 'package:health/widgets/event_card.dart';
import 'package:health/theme/app_theme.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF80CBC4),
          elevation: 0,
          title: const Text(
            'Events',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            tabs: const [
              Tab(icon: Icon(Icons.event), text: 'Upcoming'),
              Tab(icon: Icon(Icons.create), text: 'My Events'),
              Tab(icon: Icon(Icons.group), text: 'Participating'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _UpcomingEventsTab(),
            _MyEventsTab(),
            _ParticipatingEventsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF80CBC4),
          elevation: 4,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateEventPage(),
              ),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class _UpcomingEventsTab extends StatelessWidget {
  _UpcomingEventsTab({Key? key}) : super(key: key);

  final EventService _eventService = EventService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SportEvent>>(
      stream: _eventService.getUpcomingEvents(),
      builder: (context, snapshot) {
        print('Upcoming Events Stream Status:');
        print('Connection State: ${snapshot.connectionState}');
        print('Has Error: ${snapshot.hasError}');
        if (snapshot.hasError) print('Error: ${snapshot.error}');
        print('Has Data: ${snapshot.hasData}');
        if (snapshot.hasData) print('Events Count: ${snapshot.data!.length}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 50,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No upcoming events',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Create a new event or join existing ones',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: events.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            return EventCard(
              event: events[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailsPage(event: events[index]),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _MyEventsTab extends StatelessWidget {
  _MyEventsTab({Key? key}) : super(key: key);

  final EventService _eventService = EventService();

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return const Center(child: Text('Please sign in'));

    return StreamBuilder<List<SportEvent>>(
      stream: _eventService.getUserEvents(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return const Center(
            child: Text('You haven\'t created any events yet'),
          );
        }

        return ListView.builder(
          itemCount: events.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            return EventCard(
              event: events[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailsPage(event: events[index]),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ParticipatingEventsTab extends StatelessWidget {
  _ParticipatingEventsTab({Key? key}) : super(key: key);

  final EventService _eventService = EventService();

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return const Center(child: Text('Please sign in'));

    return StreamBuilder<List<SportEvent>>(
      stream: _eventService.getUserParticipatingEvents(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return const Center(
            child: Text('You haven\'t joined any events yet'),
          );
        }

        return ListView.builder(
          itemCount: events.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            return EventCard(
              event: events[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailsPage(event: events[index]),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
