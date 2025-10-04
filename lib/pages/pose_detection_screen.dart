import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../services/pose_detector_service.dart';
import '../services/bilstm_service.dart';

class PoseDetectionScreen extends StatefulWidget {
  const PoseDetectionScreen({Key? key}) : super(key: key);

  @override
  _PoseDetectionScreenState createState() => _PoseDetectionScreenState();
}

class _PoseDetectionScreenState extends State<PoseDetectionScreen> {
  VideoPlayerController? _videoController;
  String? _videoPath;
  String? _result;
  bool _isProcessing = false;
  final PoseDetectorService _poseDetector = PoseDetectorService();
  final BiLSTMService _biLSTMService = BiLSTMService();


  @override
  void initState() {
    super.initState();
    _initializeBiLSTMModel();
  }

  Future<void> _initializeBiLSTMModel() async {
    try {
      await _biLSTMService.initializeModel('assets/my_model.tflite');
      print('BiLSTM model initialized successfully');
    } catch (e) {
      print('Error initializing BiLSTM model: $e');
    }
  }


  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoPath = pickedFile.path;
        _result = null;
      });
      _videoController = VideoPlayerController.file(File(_videoPath!))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  Future<void> _processVideo() async {
    if (_videoPath == null) return;
    setState(() { _isProcessing = true; _result = null; });
    try {
      final poses = await _poseDetector.detectPose(_videoPath!);
      final keyPoints = await _poseDetector.extractKeyPoints(poses);
      const List<String> landmarkOrder = [
        'nose', 'leftEyeInner', 'leftEye', 'leftEyeOuter', 'rightEyeInner', 'rightEye', 'rightEyeOuter',
        'leftEar', 'rightEar', 'leftMouth', 'rightMouth',
        'leftShoulder', 'rightShoulder', 'leftElbow', 'rightElbow',
        'leftWrist', 'rightWrist', 'leftPinky', 'rightPinky',
        'leftIndex', 'rightIndex', 'leftThumb', 'rightThumb',
        'leftHip', 'rightHip', 'leftKnee', 'rightKnee',
        'leftAnkle', 'rightAnkle', 'leftHeel', 'rightHeel',
        'leftFootIndex', 'rightFootIndex'
      ];
      List<List<double>> formattedKeyPoints = keyPoints.map((pose) {
        List<double> flat = [];
        for (final name in landmarkOrder) {
          final point = pose[name];
          if (point != null) {
            flat.add(point['x'] ?? 0.0);
            flat.add(point['y'] ?? 0.0);
            flat.add(point['z'] ?? 0.0);
          } else {
            flat.addAll([0.0, 0.0, 0.0]);
          }
        }
        return flat;
      }).toList();
      final prediction = await _biLSTMService.runInference(formattedKeyPoints);
      // Assume binary output: 1 = correct, 0 = wrong
      setState(() {
        _result = (prediction.isNotEmpty && prediction[0] > 0.5) ? 'Correct' : 'Wrong';
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _result = 'Error processing video';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis'),
      ),
      body: Container(
        width: double.infinity,
        color: Colors.grey[100],
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_videoPath == null)
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(Icons.video_file, size: 60, color: Colors.teal[300]),
                            const SizedBox(height: 16),
                            const Text(
                              'Upload a video to analyze your movement.\nThe model will tell you if your form is correct.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _pickVideo,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Video'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(180, 48),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  if (_videoPath != null && _videoController != null && _videoController!.value.isInitialized)
                    Column(
                      children: [
                        AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: VideoPlayer(_videoController!),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _processVideo,
                          icon: const Icon(Icons.analytics),
                          label: _isProcessing
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Analyze'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[400],
                            foregroundColor: Colors.white,
                            minimumSize: const Size(180, 44),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 32),
                  if (_result != null)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: _result == 'Correct' ? Colors.green[50] : (_result == 'Wrong' ? Colors.red[50] : Colors.orange[50]),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                        child: Column(
                          children: [
                            Icon(
                              _result == 'Correct' ? Icons.check_circle : (_result == 'Wrong' ? Icons.cancel : Icons.info),
                              size: 60,
                              color: _result == 'Correct' ? Colors.green : (_result == 'Wrong' ? Colors.red : Colors.orange),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _result!,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: _result == 'Correct' ? Colors.green : (_result == 'Wrong' ? Colors.red : Colors.orange),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _poseDetector.dispose();
    _biLSTMService.dispose();
    super.dispose();
  }
}
