import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/chat_repository.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final ChatRepository _chatRepository = ChatRepository();
  
  ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _chatRepository.getChatList(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(chat['participants'][1]), // Show other user's name
                subtitle: Text(chat['lastMessage'] ?? 'No messages yet'),
                trailing: chat['unreadCount'] > 0
                    ? CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.blue,
                        child: Text(
                          chat['unreadCount'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : null,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      chatId: chats[index].id,
                      otherUserId: chat['participants'][1],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
