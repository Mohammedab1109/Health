import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';

class BiLSTMService {
  late Interpreter _interpreter;
  bool _isInitialized = false;

  Future<void> initializeModel(String modelPath) async {
    try {
      _interpreter = await Interpreter.fromAsset(modelPath);
      _isInitialized = true;
      print('BiLSTM model initialized successfully');
    } catch (e) {
      print('Error initializing BiLSTM model: $e');
      _isInitialized = false;
    }
  }

  Future<List<double>> runInference(List<List<double>> keyPoints) async {
    if (!_isInitialized) {
      throw Exception('Model not initialized');
    }

    try {
      // Reshape input data according to your model's requirements
      // This is an example - adjust dimensions based on your model
      var input = [keyPoints];
      var output = List<double>.filled(1, 0).reshape([1, 1]); // Adjust output shape

      _interpreter.run(input, output);
      return output[0];
    } catch (e) {
      print('Error running inference: $e');
      return [];
    }
  }

  void dispose() {
    if (_isInitialized) {
      _interpreter.close();
    }
  }
}
