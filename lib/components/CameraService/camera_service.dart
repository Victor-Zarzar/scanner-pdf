import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraService {
  CameraController? controller;

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    await controller?.initialize();
  }

  Widget buildCameraPreview() {
    if (controller == null || !controller!.value.isInitialized) {
      return const Center(child: Text('Camera not initialized'));
    }
    return CameraPreview(controller!);
  }

  Future<XFile?> takePicture() async {
    if (controller == null || !controller!.value.isInitialized) {
      throw Exception('CameraController is not initialized');
    }

    try {
      final XFile file = await controller!.takePicture();
      return file;
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }
}
