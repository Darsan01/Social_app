import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../data/video_repository.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/video_interaction_bar.dart';

class VideoFeedScreen extends StatelessWidget {
  final VideoRepository _videoRepository = VideoRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _videoRepository.getVideoFeed(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final videos = snapshot.data!.docs;
          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index].data() as Map<String, dynamic>;
              return Stack(
                children: [
                  VideoPlayerWidget(videoUrl: video['videoUrl']),
                  VideoInteractionBar(
                    videoId: videos[index].id,
                    likes: video['likes'],
                    comments: video['comments'],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
