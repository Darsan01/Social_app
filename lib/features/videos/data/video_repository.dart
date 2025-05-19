import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class VideoRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = Uuid();

  Future<String> uploadVideo(File videoFile, String userId, String title) async {
    try {
      final videoId = _uuid.v4();
      final storageRef = _storage.ref().child('videos/$userId/$videoId');
      
      await storageRef.putFile(videoFile);
      final videoUrl = await storageRef.getDownloadURL();

      await _firestore.collection('videos').doc(videoId).set({
        'userId': userId,
        'title': title,
        'videoUrl': videoUrl,
        'createdAt': DateTime.now(),
        'likes': 0,
        'views': 0,
        'comments': 0,
      });

      return videoId;
    } catch (e) {
      throw Exception('Video upload failed: $e');
    }
  }

  Stream<QuerySnapshot> getVideoFeed() {
    return _firestore
        .collection('videos')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots();
  }

  Future<void> likeVideo(String videoId, String userId) async {
    final docRef = _firestore.collection('videos').doc(videoId);
    final userLikesRef = _firestore.collection('user_likes').doc('${userId}_${videoId}');

    await _firestore.runTransaction((transaction) async {
      final videoDoc = await transaction.get(docRef);
      if (!videoDoc.exists) {
        throw Exception('Video not found');
      }

      final userLikeDoc = await transaction.get(userLikesRef);
      if (userLikeDoc.exists) {
        transaction.delete(userLikesRef);
        transaction.update(docRef, {'likes': FieldValue.increment(-1)});
      } else {
        transaction.set(userLikesRef, {'timestamp': DateTime.now()});
        transaction.update(docRef, {'likes': FieldValue.increment(1)});
      }
    });
  }

  Future<void> addComment(String videoId, String userId, String comment) async {
    await _firestore.collection('video_comments').add({
      'videoId': videoId,
      'userId': userId,
      'comment': comment,
      'timestamp': DateTime.now(),
    });

    await _firestore.collection('videos').doc(videoId).update({
      'comments': FieldValue.increment(1),
    });
  }

  Future<void> incrementViews(String videoId) async {
    await _firestore.collection('videos').doc(videoId).update({
      'views': FieldValue.increment(1),
    });
  }

  Future<void> shareVideo(String videoId, String sharedByUserId, String sharedToUserId) async {
    await _firestore.collection('shared_videos').add({
      'videoId': videoId,
      'sharedBy': sharedByUserId,
      'sharedTo': sharedToUserId,
      'timestamp': DateTime.now(),
    });
  }

  Stream<QuerySnapshot> getVideoComments(String videoId) {
    return _firestore
        .collection('video_comments')
        .where('videoId', isEqualTo: videoId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<double> calculateEarnings(String videoId) async {
    final video = await _firestore.collection('videos').doc(videoId).get();
    final data = video.data() as Map<String, dynamic>;
    
    // Enhanced earning calculation with bonus factors
    final viewEarnings = data['views'] * 0.01;
    final likeEarnings = data['likes'] * 0.05;
    final commentEarnings = (data['comments'] ?? 0) * 0.02;
    final shareEarnings = (data['shares'] ?? 0) * 0.03;
    final watchTimeMinutes = await getAverageWatchTimeMinutes(videoId);
    final watchTimeEarnings = watchTimeMinutes * 0.001;

    // Add engagement bonus for high interaction rates
    double bonus = 0.0;
    if (data['views'] > 10000) bonus += 50.0;
    if (data['likes'] / data['views'] > 0.2) bonus += 25.0;
    if (watchTimeMinutes > 2.0) bonus += 10.0;

    return viewEarnings + likeEarnings + commentEarnings + 
           shareEarnings + watchTimeEarnings + bonus;
  }

  Future<void> updatePaymentStatus(String videoId, String status) async {
    await _firestore.collection('videos').doc(videoId).update({
      'paymentStatus': status,
      'lastPaymentUpdate': DateTime.now(),
    });
  }

  Future<double> getAverageWatchTimeMinutes(String videoId) async {
    final watchTimeSnapshot = await _firestore
        .collection('video_analytics')
        .doc(videoId)
        .collection('watch_time')
        .get();

    if (watchTimeSnapshot.docs.isEmpty) return 0;

    final totalMinutes = watchTimeSnapshot.docs.fold<double>(
      0,
      (sum, doc) => sum + (doc.data()['duration'] ?? 0) / 60,
    );

    return totalMinutes / watchTimeSnapshot.docs.length;
  }

  Future<void> trackVideoEngagement(String videoId, String userId, double watchDuration) async {
    await _firestore
        .collection('video_analytics')
        .doc(videoId)
        .collection('watch_time')
        .add({
      'userId': userId,
      'duration': watchDuration,
      'timestamp': DateTime.now(),
    });
  }

  Stream<QuerySnapshot> getVideosByHashtag(String hashtag) {
    return _firestore
        .collection('videos')
        .where('hashtags', arrayContains: hashtag)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots();
  }

  Future<void> updateVideoMetadata(String videoId, Map<String, dynamic> metadata) async {
    await _firestore.collection('videos').doc(videoId).update(metadata);
  }

  Stream<QuerySnapshot> getTrendingVideos() {
    return _firestore
        .collection('videos')
        .orderBy('views', descending: true)
        .limit(20)
        .snapshots();
  }

  Future<Map<String, dynamic>> getVideoAnalytics(String videoId) async {
    final video = await _firestore.collection('videos').doc(videoId).get();
    final data = video.data() as Map<String, dynamic>;
    
    final watchTime = await _firestore
        .collection('video_analytics')
        .doc(videoId)
        .collection('watch_time')
        .get();

    return {
      'views': data['views'],
      'likes': data['likes'],
      'comments': data['comments'],
      'shares': data['shares'] ?? 0,
      'watchTime': watchTime.docs.length,
      'estimatedEarnings': await calculateEarnings(videoId),
    };
  }

  Stream<QuerySnapshot> getUserVideos(String userId) {
    return _firestore
        .collection('videos')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
