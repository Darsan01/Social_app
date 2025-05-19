import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String senderId, String receiverId, String message) async {
    final participants = [senderId, receiverId];
    participants.sort();
    final chatId = participants.join('_');
    
    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'senderId': senderId,
      'message': message,
      'timestamp': DateTime.now(),
      'read': false,
    });

    await _firestore.collection('chat_meta').doc(chatId).set({
      'participants': [senderId, receiverId],
      'lastMessage': message,
      'lastMessageTime': DateTime.now(),
      'unreadCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  Stream<QuerySnapshot> getChatList() {
    return _firestore
        .collection('chat_meta')
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }
}
