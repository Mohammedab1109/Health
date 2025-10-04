import 'package:flutter/material.dart';
import 'package:health/models/sport_event.dart';
import 'package:health/services/event_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health/widgets/loading_indicator.dart';
import 'package:health/widgets/location_picker_dialog.dart';
import 'package:intl/intl.dart';

class EditEventPage extends StatefulWidget {
  final SportEvent event;

  const EditEventPage({
    super.key,
    required this.event,
  });

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  final EventService _eventService = EventService();
  
  late String _title;
  late String _description;
  late SportType _sportType;
  late DateTime _startDate;
  late DateTime _startTime;
  late DateTime _endDate;
  late DateTime _endTime;
  late String _locationName;
  late GeoPoint _location;
  late int _maxParticipants;
  late String _difficultyLevel;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeEventData();
  }

  void _initializeEventData() {
    _title = widget.event.title;
    _description = widget.event.description;
    _sportType = widget.event.sportType;
    _startDate = widget.event.startTime;
    _startTime = widget.event.startTime;
    _endDate = widget.event.endTime;
    _endTime = widget.event.endTime;
    _locationName = widget.event.locationName;
    _location = widget.event.location;
    _maxParticipants = widget.event.maxParticipants;
    _difficultyLevel = widget.event.difficultyLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Updating event...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      initialValue: _title,
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
                      initialValue: _description,
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
                          setState(() => _sportType = value);
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
                      initialValue: _locationName,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText: 'Enter event location',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      readOnly: true,
                      onTap: _selectLocation,
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
                            initialValue: _maxParticipants.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Max Participants',
                              prefixIcon: Icon(Icons.group),
                            ),
                            keyboardType: TextInputType.number,
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
                            onSaved: (value) =>
                                _maxParticipants = int.tryParse(value ?? '') ?? 10,
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
                                setState(() => _difficultyLevel = value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _updateEvent,
                      child: const Text('Update Event'),
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

  Future<void> _selectLocation() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => LocationPickerDialog(
        onLocationPicked: (location, address) {
          Navigator.pop(context, {
            'location': location,
            'address': address,
          });
        },
      ),
    );

    if (result != null) {
      setState(() {
        _location = GeoPoint(
          result['location'].latitude,
          result['location'].longitude,
        );
        _locationName = result['address'];
      });
    }
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final startDateTime = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final endDateTime = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      final updatedEvent = SportEvent(
        id: widget.event.id,
        title: _title,
        description: _description,
        creatorId: widget.event.creatorId,
        sportType: _sportType,
        startTime: startDateTime,
        endTime: endDateTime,
        location: _location,
        locationName: _locationName,
        maxParticipants: _maxParticipants,
        difficultyLevel: _difficultyLevel,
        status: widget.event.status,
        participantIds: widget.event.participantIds,
        settings: widget.event.settings,
      );

      await _eventService.updateEvent(updatedEvent);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating event: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
