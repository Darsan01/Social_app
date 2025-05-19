import 'package:flutter/material.dart';

class UserProfileHeader extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserProfileHeader({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(userData['profileImage'] ?? ''),
            child: userData['profileImage'] == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            userData['username'] ?? 'User',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(userData['bio'] ?? ''),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('Posts', userData['posts']?.toString() ?? '0'),
              _buildStatColumn('Followers', userData['followers']?.toString() ?? '0'),
              _buildStatColumn('Following', userData['following']?.toString() ?? '0'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }
}
