import 'package:flutter/material.dart';
import 'package:health/models/sport_event.dart';
import 'package:health/services/event_service.dart';
import 'package:health/services/auth_service.dart';
import 'package:health/widgets/loading_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final EventService _eventService = EventService();
  
  String _title = '';
  String _description = '';
  SportType _sportType = SportType.walking;
  DateTime _startDate = DateTime.now();
  DateTime _startTime = DateTime.now();
  DateTime _endDate = DateTime.now();
  DateTime _endTime = DateTime.now();
  String _locationName = '';
  GeoPoint _location = const GeoPoint(0, 0);
  int _maxParticipants = 10;
  String _difficultyLevel = 'beginner';
  
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Creating event...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Event Title',
                        hintText: 'Enter event title',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                      onSaved: (value) => _title = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter event description',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                      onSaved: (value) => _description = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<SportType>(
                      value: _sportType,
                      decoration: const InputDecoration(
                        labelText: 'Sport Type',
                      ),
                      items: SportType.values.map((SportType type) {
                        return DropdownMenuItem<SportType>(
                          value: type,
                          child: Text(type.toString().split('.').last.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (SportType? value) {
                        if (value != null) {
                          setState(() {
                            _sportType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Start Date',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            readOnly: true,
                            controller: TextEditingController(
                              text: DateFormat('MMM dd, yyyy').format(_startDate),
                            ),
                            onTap: () => _selectDate(context, true),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Start Time',
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            readOnly: true,
                            controller: TextEditingController(
                              text: DateFormat('HH:mm').format(_startTime),
                            ),
                            onTap: () => _selectTime(context, true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'End Date',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            readOnly: true,
                            controller: TextEditingController(
                              text: DateFormat('MMM dd, yyyy').format(_endDate),
                            ),
                            onTap: () => _selectDate(context, false),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'End Time',
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            readOnly: true,
                            controller: TextEditingController(
                              text: DateFormat('HH:mm').format(_endTime),
                            ),
                            onTap: () => _selectTime(context, false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText: 'Enter event location',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                      onSaved: (value) => _locationName = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Max Participants',
                              prefixIcon: Icon(Icons.group),
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: _maxParticipants.toString(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter max participants';
                              }
                              final number = int.tryParse(value);
                              if (number == null || number < 1) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                            onSaved: (value) => _maxParticipants = int.tryParse(value ?? '') ?? 10,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _difficultyLevel,
                            decoration: const InputDecoration(
                              labelText: 'Difficulty',
                            ),
                            items: ['beginner', 'intermediate', 'advanced']
                                .map((String level) {
                              return DropdownMenuItem<String>(
                                value: level,
                                child: Text(level.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _difficultyLevel = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _createEvent,
                      child: const Text('Create Event'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _startTime : _endTime),
    );
    if (picked != null) {
      setState(() {
        final DateTime now = DateTime.now();
        final DateTime selectedDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          picked.hour,
          picked.minute,
        );
        if (isStart) {
          _startTime = selectedDateTime;
          if (_startTime.isAfter(_endTime)) {
            _endTime = _startTime.add(const Duration(hours: 1));
          }
        } else {
          _endTime = selectedDateTime;
        }
      });
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final user = AuthService.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final startDateTime = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      );
      print('Creating event with start time: $startDateTime');
      print('Current time: ${DateTime.now()}');

      final endDateTime = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      final event = SportEvent(
        id: '', // Will be set by Firestore
        title: _title,
        description: _description,
        creatorId: user.uid,
        sportType: _sportType,
        startTime: startDateTime,
        endTime: endDateTime,
        location: _location,
        locationName: _locationName,
        maxParticipants: _maxParticipants,
        difficultyLevel: _difficultyLevel,
        status: EventStatus.upcoming,
        participantIds: [user.uid], // Creator is automatically a participant
        settings: {},
      );

      await _eventService.createEvent(event);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating event: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
