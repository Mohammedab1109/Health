import 'package:cloud_firestore/cloud_firestore.dart';

enum SportType {
  walking,
  running,
  swimming,
  cycling,
  hiking,
  yoga,
  basketball,
  football,
  tennis,
  other
}

enum EventStatus {
  upcoming,
  ongoing,
  completed,
  cancelled
}

class SportEvent {
  final String id;
  final String title;
  final String description;
  final String creatorId;
  final SportType sportType;
  final DateTime startTime;
  final DateTime endTime;
  final GeoPoint location;
  final String locationName;
  final int maxParticipants;
  final String difficultyLevel;
  final EventStatus status;
  final List<String> participantIds;
  final Map<String, dynamic> settings;

  SportEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorId,
    required this.sportType,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.locationName,
    required this.maxParticipants,
    required this.difficultyLevel,
    required this.status,
    required this.participantIds,
    required this.settings,
  });

  // Factory constructor to create SportEvent from Firestore document
  factory SportEvent.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SportEvent(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      creatorId: data['creatorId'] ?? '',
      sportType: SportType.values.firstWhere(
        (type) => type.toString() == data['sportType'],
        orElse: () => SportType.other,
      ),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      location: data['location'] as GeoPoint,
      locationName: data['locationName'] ?? '',
      maxParticipants: data['maxParticipants'] ?? 0,
      difficultyLevel: data['difficultyLevel'] ?? 'beginner',
      status: EventStatus.values.firstWhere(
        (status) => status.toString() == data['status'],
        orElse: () => EventStatus.upcoming,
      ),
      participantIds: List<String>.from(data['participantIds'] ?? []),
      settings: data['settings'] ?? {},
    );
  }

  // Convert SportEvent to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'creatorId': creatorId,
      'sportType': sportType.toString(),
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'location': location,
      'locationName': locationName,
      'maxParticipants': maxParticipants,
      'difficultyLevel': difficultyLevel,
      'status': status.toString(),
      'participantIds': participantIds,
      'settings': settings,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
