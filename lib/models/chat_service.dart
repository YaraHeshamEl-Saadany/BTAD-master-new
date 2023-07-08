import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> sendMessage({
    required String senderEmail,
    required String receiverEmail,
    required String message,
  }) async {
    final chatDocRef = _firestore.collection('chats').doc();
    final chatId = chatDocRef.id;

    final senderData = {
      'senderEmail': senderEmail, // Change 'email' to 'senderEmail'
      'receiverEmail': receiverEmail, // Add 'receiverEmail'
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    };

    final receiverData = {
      'senderEmail': senderEmail, // Change 'email' to 'senderEmail'
      'receiverEmail': receiverEmail, // Add 'receiverEmail'
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    };
    final batch = _firestore.batch();

    batch.set(chatDocRef, senderData);
    batch.set(chatDocRef, receiverData);

    final senderUserDocRef = _firestore
        .collection('users')
        .doc(senderEmail)
        .collection('chat')
        .doc(chatId);
    batch.set(senderUserDocRef, receiverData);

    final receiverUserDocRef = _firestore
        .collection('users')
        .doc(receiverEmail)
        .collection('chat')
        .doc(chatId);
    batch.set(receiverUserDocRef, senderData);

    await batch.commit();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getChatsForUser(
      String email) {
    return _firestore
        .collection('users')
        .doc(email)
        .collection('chat')
        .orderBy('timestamp')
        .snapshots();
  }
}
