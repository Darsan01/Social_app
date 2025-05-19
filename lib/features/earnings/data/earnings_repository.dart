import 'package:cloud_firestore/cloud_firestore.dart';

class EarningsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getCreatorEarnings(String userId) async {
    final snapshot = await _firestore
        .collection('creator_earnings')
        .doc(userId)
        .get();

    if (!snapshot.exists) {
      return {
        'totalEarnings': 0.0,
        'pendingPayout': 0.0,
        'lastPayout': null,
      };
    }

    return snapshot.data() as Map<String, dynamic>;
  }

  Future<void> processPayment(String userId, double amount) async {
    final batch = _firestore.batch();
    final earningsRef = _firestore.collection('creator_earnings').doc(userId);
    final paymentRef = _firestore.collection('payments').doc();

    batch.update(earningsRef, {
      'pendingPayout': FieldValue.increment(-amount),
      'totalPaid': FieldValue.increment(amount),
      'lastPayout': DateTime.now(),
    });

    batch.set(paymentRef, {
      'userId': userId,
      'amount': amount,
      'status': 'processed',
      'timestamp': DateTime.now(),
    });

    await batch.commit();
  }
}
