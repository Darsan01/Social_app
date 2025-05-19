import 'package:flutter/material.dart';
import '../../../user/data/user_repository.dart';
import '../../../videos/data/video_repository.dart';
import '../widgets/user_profile_header.dart';
import '../widgets/user_videos_grid.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;
  final UserRepository _userRepository = UserRepository();
  final VideoRepository _videoRepository = VideoRepository();

  ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Column(
        children: [
          FutureBuilder(
            future: _userRepository.getUserProfile(userId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final userData = snapshot.data!;
              return UserProfileHeader(userData: userData);
            },
          ),
          Expanded(
            child: StreamBuilder(
              stream: _videoRepository.getUserVideos(userId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                return UserVideosGrid(videos: snapshot.data!.docs);
              },
            ),
          ),
        ],
      ),
    );
  }
}
