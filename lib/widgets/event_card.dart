import 'package:flutter/material.dart';
import 'package:health/models/sport_event.dart';
import 'package:intl/intl.dart';
import 'package:health/theme/app_theme.dart';

class EventCard extends StatelessWidget {
  final SportEvent event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _getSportIcon(event.sportType),
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    event.sportType.toString().split('.').last.toUpperCase(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM dd, yyyy - HH:mm').format(event.startTime),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.locationName,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.group,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${event.participantIds.length}/${event.maxParticipants} participants',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  _buildStatusChip(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (event.status) {
      case EventStatus.upcoming:
        backgroundColor = Theme.of(context).colorScheme.primary;
        break;
      case EventStatus.ongoing:
        backgroundColor = Theme.of(context).colorScheme.secondary;
        break;
      case EventStatus.completed:
        backgroundColor = Colors.grey;
        break;
      case EventStatus.cancelled:
        backgroundColor = Theme.of(context).colorScheme.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        event.status.toString().split('.').last.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getSportIcon(SportType type) {
    switch (type) {
      case SportType.walking:
        return Icons.directions_walk;
      case SportType.running:
        return Icons.directions_run;
      case SportType.swimming:
        return Icons.pool;
      case SportType.cycling:
        return Icons.directions_bike;
      case SportType.hiking:
        return Icons.terrain;
      case SportType.yoga:
        return Icons.self_improvement;
      case SportType.basketball:
        return Icons.sports_basketball;
      case SportType.football:
        return Icons.sports_soccer;
      case SportType.tennis:
        return Icons.sports_tennis;
      case SportType.other:
        return Icons.sports;
    }
  }
}
