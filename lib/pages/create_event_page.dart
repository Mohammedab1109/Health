import 'dart:io';
import 'package:flutter/material.dart';
import 'package:health/services/event_service.dart';
import 'package:health/widgets/image_uploader.dart';
import 'package:health/widgets/loading_indicator.dart';

class CreateEventPage extends StatefulWidget {
  final bool isAdmin;
  
  const CreateEventPage({super.key, this.isAdmin = false});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _sponsorshipController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  File? _selectedImage;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _sponsorshipController.dispose();
    super.dispose();
  }

  Future<void> _createEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        await EventService.createEvent(
          title: _titleController.text,
          description: _descriptionController.text,
          date: _selectedDate,
          location: _locationController.text,
          isFormal: widget.isAdmin, // Only admins can create formal events
          sponsorship: widget.isAdmin ? _sponsorshipController.text : null,
          imageFile: _selectedImage,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event created successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error creating event: ${e.toString()}';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isAdmin ? 'Create Formal Event' : 'Create Event',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A3A6B),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Creating event...')
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Image Uploader
                      ImageUploader(
                        onImageSelected: (file) {
                          setState(() {
                            _selectedImage = file;
                          });
                        },
                        placeholder: 'Add Event Image (Optional)',
                        height: 200,
                      ),
                      const SizedBox(height: 16),
                      
                      // Title Field
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Event Title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an event title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Description Field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an event description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Date Picker
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Event Date',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Location Field
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an event location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Sponsorship Field (only for admin events)
                      if (widget.isAdmin)
                        Column(
                          children: [
                            TextFormField(
                              controller: _sponsorshipController,
                              decoration: InputDecoration(
                                labelText: 'Sponsorship Details',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      
                      // Error Message
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _createEvent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A3A6B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Create Event'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}