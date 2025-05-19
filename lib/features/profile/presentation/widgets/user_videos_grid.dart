import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserVideosGrid extends StatelessWidget {
  final List<QueryDocumentSnapshot> videos;

  const UserVideosGrid({super.key, required this.videos});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 1.0,
        crossAxisSpacing: 1.0,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index].data() as Map<String, dynamic>;
        return GestureDetector(
          onTap: () {
            // TODO: Navigate to video player
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                video['thumbnail'] ?? '',
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Column(
                  children: [
                    Icon(Icons.play_arrow, color: Colors.white),
                    Text(
                      '${video['views'] ?? 0}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
