import 'package:flutter/material.dart';
import '../../data/video_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class VideoInteractionBar extends StatelessWidget {
  final String videoId;
  final int likes;
  final int comments;
  final VideoRepository _videoRepository = VideoRepository();

  VideoInteractionBar({
    super.key,
    required this.videoId,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        children: [
          _buildInteractionButton(
            context,
            Icons.favorite,
            likes.toString(),
            () async {
              final userId = Provider.of<AuthProvider>(context, listen: false)
                  .currentUser!
                  .uid;
              await _videoRepository.likeVideo(videoId, userId);
            },
          ),
          const SizedBox(height: 16),
          _buildInteractionButton(
            context,
            Icons.comment,
            comments.toString(),
            () {
              // TODO: Show comments sheet
            },
          ),
          const SizedBox(height: 16),
          _buildInteractionButton(
            context,
            Icons.share,
            '',
            () {
              // TODO: Show share options
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton(
    BuildContext context,
    IconData icon,
    String count,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white, size: 30),
          onPressed: onTap,
        ),
        if (count.isNotEmpty)
          Text(
            count,
            style: const TextStyle(color: Colors.white),
          ),
      ],
    );
  }
}
