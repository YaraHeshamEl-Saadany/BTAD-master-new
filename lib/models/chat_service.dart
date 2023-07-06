import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> sendMessage({
    required String senderEmail,
    required String receiverEmail,
    required String message,
  }) async {
    final chatDocRef = _firestore.collection('chats').doc();
    final chatId = chatDocRef.id;

    final senderData = {
      'email': senderEmail,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    };

    final receiverData = {
      'email': receiverEmail,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    };

    final batch = _firestore.batch();

    batch.set(chatDocRef, senderData);
    batch.set(chatDocRef, receiverData);

    final senderUserDocRef = _firestore
        .collection('users')
        .doc(senderEmail)
        .collection('chats')
        .doc(chatId);
    batch.set(senderUserDocRef, receiverData);

    final receiverUserDocRef = _firestore
        .collection('users')
        .doc(receiverEmail)
        .collection('chats')
        .doc(chatId);
    batch.set(receiverUserDocRef, senderData);

    await batch.commit();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getChatsForUser(
      String email) {
    return _firestore
        .collection('users')
        .doc(email)
        .collection('chats')
        .orderBy('timestamp')
        .snapshots();
  }
}
