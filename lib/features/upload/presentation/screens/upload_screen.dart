import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../videos/data/video_repository.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _videoFile;
  final _titleController = TextEditingController();
  final _hashtagsController = TextEditingController();
  bool _isUploading = false;
  final _videoRepository = VideoRepository();

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _videoFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (_videoFile == null || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video and add a title')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final userId = Provider.of<AuthProvider>(context, listen: false).currentUser!.uid;
      await _videoRepository.uploadVideo(
        _videoFile!,
        userId,
        _titleController.text,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video uploaded successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Video')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _videoFile != null
                ? Text('Selected video: ${_videoFile!.path.split('/').last}')
                : ElevatedButton(
                    onPressed: _pickVideo,
                    child: const Text('Pick Video'),
                  ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _hashtagsController,
              decoration: const InputDecoration(
                labelText: 'Hashtags (comma separated)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _uploadVideo,
                    child: const Text('Upload'),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _hashtagsController.dispose();
    super.dispose();
  }
}
