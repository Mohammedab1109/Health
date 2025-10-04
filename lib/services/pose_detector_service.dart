import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:camera/camera.dart';

class PoseDetectorService {
  final PoseDetector _poseDetector = GoogleMlKit.vision.poseDetector();
  
  Future<List<Pose>> detectPose(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    try {
      final List<Pose> poses = await _poseDetector.processImage(inputImage);
      return poses;
    } catch (e) {
      print('Error detecting pose: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> extractKeyPoints(List<Pose> poses) async {
    List<Map<String, dynamic>> keyPoints = [];
    
    for (var pose in poses) {
      Map<String, dynamic> poseKeyPoints = {};
      
      for (var landmark in pose.landmarks.entries) {
        final point = landmark.value;
        poseKeyPoints[landmark.key.name] = {
          'x': point.x,
          'y': point.y,
          'z': point.z,
          'likelihood': point.likelihood,
        };
      }
      
      keyPoints.add(poseKeyPoints);
    }
    
    return keyPoints;
  }

  void dispose() {
    _poseDetector.close();
  }
}
