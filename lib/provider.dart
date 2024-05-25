import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class MediaProvider extends ChangeNotifier {
  List<XFile> _mediaFiles = [];
  Map<String, VideoPlayerController> _controllers = {};

  List<XFile> get mediaFiles => _mediaFiles;

  Map<String, VideoPlayerController> get controllers => _controllers;

  Future<void> pickMedia(bool isVideo) async {
    final picker = ImagePicker();
    if (isVideo) {
      final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
      if (pickedFile != null) {
        _mediaFiles.add(pickedFile);
        _controllers[pickedFile.path] =
        VideoPlayerController.file(File(pickedFile.path))
          ..initialize().then((_) {
            notifyListeners();
            _controllers[pickedFile.path]!.play();
          });
        notifyListeners();
      }
    } else {
      final pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        _mediaFiles.addAll(pickedFiles);
        notifyListeners();
      }
    }
  }

  void disposeControllers() {
    _controllers.forEach((key, controller) {
      controller.dispose();
    });
    _controllers.clear();
    notifyListeners();
  }

  void clearMedia() {
    _mediaFiles.clear();
    disposeControllers();
    notifyListeners();
  }
}
