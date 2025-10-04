import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health/models/event.dart';
import 'package:health/services/auth_service.dart';

class EventService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _eventsCollection = _firestore.collection('events');
  
  // Get all events
  static Stream<List<Event>> getAllEvents() {
    return _eventsCollection
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Event.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          }).toList();
        });
  }
  
  // Get events by type (formal or regular)
  static Stream<List<Event>> getEventsByType(bool isFormal) {
    return _eventsCollection
        .where('isFormal', isEqualTo: isFormal)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Event.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          }).toList();
        });
  }
  
  // Create a new event
  static Future<void> createEvent({
    required String title,
    required String description,
    required DateTime date,
    required String location,
    required bool isFormal,
    String? sponsorship,
  }) async {
    final user = AuthService.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to create an event');
    }
    
    // Check if user is admin when creating formal events
    if (isFormal) {
      final isAdmin = await AuthService.isCurrentUserAdmin();
      if (!isAdmin) {
        throw Exception('Only admins can create formal events');
      }
    }
    
    // Create the event
    await _eventsCollection.add({
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'location': location,
      'createdBy': user.uid,
      'isFormal': isFormal,
      'sponsorship': isFormal ? sponsorship : null,
      'participants': [user.uid],  // Creator is automatically a participant
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  
  // Join an event
  static Future<void> joinEvent(String eventId) async {
    final user = AuthService.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to join an event');
    }
    
    await _eventsCollection.doc(eventId).update({
      'participants': FieldValue.arrayUnion([user.uid]),
    });
  }
  
  // Leave an event
  static Future<void> leaveEvent(String eventId) async {
    final user = AuthService.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to leave an event');
    }
    
    await _eventsCollection.doc(eventId).update({
      'participants': FieldValue.arrayRemove([user.uid]),
    });
  }
  
  // Delete an event (only creator or admin can delete)
  static Future<void> deleteEvent(String eventId) async {
    final user = AuthService.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to delete an event');
    }
    
    // Get the event
    final eventDoc = await _eventsCollection.doc(eventId).get();
    if (!eventDoc.exists) {
      throw Exception('Event not found');
    }
    
    final eventData = eventDoc.data() as Map<String, dynamic>;
    final String createdBy = eventData['createdBy'];
    
    // Check if user is creator or admin
    final bool isAdmin = await AuthService.isCurrentUserAdmin();
    if (user.uid != createdBy && !isAdmin) {
      throw Exception('Only the creator or admin can delete an event');
    }
    
    await _eventsCollection.doc(eventId).delete();
  }
}