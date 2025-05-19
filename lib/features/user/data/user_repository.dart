import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createProfile(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).set({
      ...data,
      'followers': 0,
      'following': 0,
      'createdAt': DateTime.now(),
    });
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  Future<void> followUser(String followerId, String followedId) async {
    final batch = _firestore.batch();
    final followerRef = _firestore.collection('users').doc(followerId);
    final followedRef = _firestore.collection('users').doc(followedId);
    final relationRef = _firestore
        .collection('follows')
        .doc('${followerId}_${followedId}');

    batch.set(relationRef, {
      'followerId': followerId,
      'followedId': followedId,
      'timestamp': DateTime.now(),
    });
    
    batch.update(followerRef, {'following': FieldValue.increment(1)});
    batch.update(followedRef, {'followers': FieldValue.increment(1)});
    
    await batch.commit();
  }

  Stream<QuerySnapshot> searchUsers(String query) {
    return _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThan: query + 'z')
        .limit(20)
        .snapshots();
  }
}
