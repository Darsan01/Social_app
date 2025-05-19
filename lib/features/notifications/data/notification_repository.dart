import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> saveUserToken(String userId, String token) async {
    await _firestore.collection('user_tokens').doc(userId).set({
      'token': token,
      'lastUpdated': DateTime.now(),
    });
  }

  Future<void> createNotification(String userId, String type, String content) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'type': type,
      'content': content,
      'timestamp': DateTime.now(),
      'read': false,
    });
  }

  Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
