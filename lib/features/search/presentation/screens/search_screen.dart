import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../user/data/user_repository.dart';
import '../../../videos/data/video_repository.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final UserRepository _userRepository = UserRepository();
  final VideoRepository _videoRepository = VideoRepository();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Videos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserSearch(),
          _buildVideoSearch(),
        ],
      ),
    );
  }

  Widget _buildUserSearch() {
    return StreamBuilder<QuerySnapshot>(
      stream: _userRepository.searchUsers(_searchQuery),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final user = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user['profileImage'] ?? ''),
              ),
              title: Text(user['username'] ?? ''),
              subtitle: Text(user['bio'] ?? ''),
              onTap: () {
                // Navigate to user profile
              },
            );
          },
        );
      },
    );
  }

  Widget _buildVideoSearch() {
    return StreamBuilder<QuerySnapshot>(
      stream: _videoRepository.getVideosByHashtag(_searchQuery),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.8,
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final video = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return GestureDetector(
              onTap: () {
                // Navigate to video player
              },
              child: Card(
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        video['thumbnail'] ?? '',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        video['title'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
