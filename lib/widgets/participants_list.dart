import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ParticipantsList extends StatelessWidget {
  final List<String> participantIds;

  const ParticipantsList({
    super.key,
    required this.participantIds,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: participantIds.length,
      itemBuilder: (context, index) {
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(participantIds[index])
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(
                leading: CircleAvatar(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                title: LinearProgressIndicator(),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.person_outline),
                ),
                title: Text('Unknown User'),
              );
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final String displayName = userData['displayName'] ?? 'Anonymous';
            final String photoUrl = userData['photoUrl'] ?? '';
            final bool isCurrentUser =
                FirebaseAuth.instance.currentUser?.uid == participantIds[index];

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                child: photoUrl.isEmpty ? const Icon(Icons.person) : null,
              ),
              title: Text(displayName),
              trailing: isCurrentUser
                  ? const Chip(
                      label: Text('You'),
                      backgroundColor: Colors.blue,
                      labelStyle: TextStyle(color: Colors.white),
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}
