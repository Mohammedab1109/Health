import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String createdBy;
  final bool isFormal;  // True for admin events (formal), false for regular user events
  final String? sponsorship;  // Only for formal events
  final List<String> participants;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.createdBy,
    required this.isFormal,
    this.sponsorship,
    this.participants = const [],
  });

  // Convert Event to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'location': location,
      'createdBy': createdBy,
      'isFormal': isFormal,
      'sponsorship': sponsorship,
      'participants': participants,
    };
  }

  // Create Event from Firestore document
  factory Event.fromMap(String id, Map<String, dynamic> map) {
    return Event(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      location: map['location'] ?? '',
      createdBy: map['createdBy'] ?? '',
      isFormal: map['isFormal'] ?? false,
      sponsorship: map['sponsorship'],
      participants: List<String>.from(map['participants'] ?? []),
    );
  }
}