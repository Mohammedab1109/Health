import 'package:flutter/material.dart';
import 'package:health/models/sport_event.dart';
import 'package:health/services/event_service.dart';
import 'package:health/services/auth_service.dart';
import 'package:health/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';

class EventDetailsPage extends StatefulWidget {
  final SportEvent event;

  const EventDetailsPage({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final EventService _eventService = EventService();
  bool _isLoading = false;

  bool get _isCreator =>
      AuthService.currentUser?.uid == widget.event.creatorId;

  bool get _isParticipant =>
      widget.event.participantIds.contains(AuthService.currentUser?.uid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          if (_isCreator)
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Edit Event'),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete Event'),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(widget.event.description),
                  const SizedBox(height: 24),
                  _buildParticipantsSection(),
                  const SizedBox(height: 24),
                  if (!_isCreator && widget.event.status == EventStatus.upcoming)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isParticipant ? _leaveEvent : _joinEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isParticipant
                              ? Theme.of(context).colorScheme.error
                              : null,
                        ),
                        child: Text(_isParticipant ? 'Leave Event' : 'Join Event'),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              Icons.sports,
              widget.event.sportType.toString().split('.').last.toUpperCase(),
            ),
            const Divider(),
            _buildInfoRow(
              Icons.calendar_today,
              '${DateFormat('MMM dd, yyyy - HH:mm').format(widget.event.startTime)} - '
              '${DateFormat('HH:mm').format(widget.event.endTime)}',
            ),
            const Divider(),
            _buildInfoRow(
              Icons.location_on,
              widget.event.locationName,
            ),
            const Divider(),
            _buildInfoRow(
              Icons.speed,
              widget.event.difficultyLevel.toUpperCase(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participants (${widget.event.participantIds.length}/${widget.event.maxParticipants})',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        // TODO: Implement participants list with user details
        Text('Participant list will be implemented here'),
      ],
    );
  }

  Future<void> _handleMenuAction(String action) async {
    switch (action) {
      case 'edit':
        // TODO: Implement edit functionality
        break;
      case 'delete':
        await _deleteEvent();
        break;
    }
  }

  Future<void> _joinEvent() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final user = AuthService.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _eventService.joinEvent(widget.event.id, user.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined the event')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error joining event: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _leaveEvent() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final user = AuthService.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _eventService.leaveEvent(widget.event.id, user.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully left the event')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error leaving event: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await _eventService.deleteEvent(widget.event.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting event: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
