import 'package:flutter/material.dart';
import 'dart:io';
import '../../data/video_repository.dart';
import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class VideoProvider with ChangeNotifier {
  final _videoRepository = getIt<VideoRepository>();
  bool isUploading = false;
  List<Map<String, dynamic>> videos = [];

  Future<void> uploadVideo(File videoFile, String title) async {
    isUploading = true;
    notifyListeners();
    try {
      await _videoRepository.uploadVideo(
        videoFile,
        getIt<AuthProvider>().currentUser!.uid,
        title,
      );
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  Future<void> likeVideo(String videoId) async {
    // TODO: Implement like functionality
  }

  Future<void> addComment(String videoId, String comment) async {
    // TODO: Implement comment functionality
  }
}
