import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health/models/sport_event.dart';

class EventService {
  final CollectionReference _eventsCollection = FirebaseFirestore.instance.collection('events');

  // Get upcoming events
  Stream<List<SportEvent>> getUpcomingEvents() {
    print('Querying upcoming events with status: ${EventStatus.upcoming.name}');
    print('Current time for query: ${DateTime.now()}');
    return _eventsCollection
        .where('startTime', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .snapshots()
        .map((snapshot) {
          print('Received snapshot with ${snapshot.docs.length} documents');
          final events = _convertToSportEvents(snapshot);
          // Filter for upcoming status in memory
          return events.where((event) => event.status == EventStatus.upcoming).toList();
        });
  }

  // Get events created by a specific user
  Stream<List<SportEvent>> getUserEvents(String userId) {
    return _eventsCollection
        .where('creatorId', isEqualTo: userId)
        .orderBy('startTime')
        .snapshots()
        .map(_convertToSportEvents);
  }

  // Get events where a specific user is participating
  Stream<List<SportEvent>> getUserParticipatingEvents(String userId) {
    return _eventsCollection
        .where('participantIds', arrayContains: userId)
        .where('creatorId', isNotEqualTo: userId)
        .orderBy('creatorId')
        .orderBy('startTime')
        .snapshots()
        .map(_convertToSportEvents);
  }

  // Convert Firestore documents to SportEvent objects
  List<SportEvent> _convertToSportEvents(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return SportEvent(
        id: doc.id,
        title: data['title'] as String,
        description: data['description'] as String,
        creatorId: data['creatorId'] as String,
        sportType: SportType.values.firstWhere(
          (type) => type.name == data['sportType'],
          orElse: () => SportType.other,
        ),
        startTime: (data['startTime'] as Timestamp).toDate(),
        endTime: (data['endTime'] as Timestamp).toDate(),
        location: data['location'] as GeoPoint,
        locationName: data['locationName'] as String,
        maxParticipants: data['maxParticipants'] as int,
        difficultyLevel: data['difficultyLevel'] as String,
        status: EventStatus.values.firstWhere(
          (status) => status.name == data['status'],
          orElse: () => EventStatus.upcoming,
        ),
        participantIds: List<String>.from(data['participantIds'] as List),
        settings: Map<String, dynamic>.from(data['settings'] ?? {}),
      );
    }).toList();
  }

  // Create a new event
  Future<String> createEvent(SportEvent event) async {
    final docRef = await _eventsCollection.add({
      'title': event.title,
      'description': event.description,
      'creatorId': event.creatorId,
      'sportType': event.sportType.name,
      'startTime': Timestamp.fromDate(event.startTime),
      'endTime': Timestamp.fromDate(event.endTime),
      'location': event.location,
      'locationName': event.locationName,
      'maxParticipants': event.maxParticipants,
      'difficultyLevel': event.difficultyLevel,
      'status': event.status.name,
      'participantIds': event.participantIds,
      'settings': event.settings,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // Update an existing event
  Future<void> updateEvent(SportEvent event) async {
    await _eventsCollection.doc(event.id).update({
      'title': event.title,
      'description': event.description,
      'sportType': event.sportType.name,
      'startTime': Timestamp.fromDate(event.startTime),
      'endTime': Timestamp.fromDate(event.endTime),
      'location': event.location,
      'locationName': event.locationName,
      'maxParticipants': event.maxParticipants,
      'difficultyLevel': event.difficultyLevel,
      'status': event.status.name,
      'settings': event.settings,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Join an event
  Future<void> joinEvent(String eventId, String userId) async {
    await _eventsCollection.doc(eventId).update({
      'participantIds': FieldValue.arrayUnion([userId]),
    });
  }

  // Leave an event
  Future<void> leaveEvent(String eventId, String userId) async {
    await _eventsCollection.doc(eventId).update({
      'participantIds': FieldValue.arrayRemove([userId]),
    });
  }

  // Delete an event
  Future<void> deleteEvent(String eventId) async {
    await _eventsCollection.doc(eventId).delete();
  }
}