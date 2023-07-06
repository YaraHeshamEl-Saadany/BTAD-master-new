import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderEmail;
  final String recipientEmail;
  final String content;
  final DateTime timestamp;

  MessageModel({
    required this.senderEmail,
    required this.recipientEmail,
    required this.content,
    required this.timestamp,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderEmail: map['senderEmail'],
      recipientEmail: map['recipientEmail'],
      content: map['content'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderEmail': senderEmail,
      'recipientEmail': recipientEmail,
      'content': content,
      'timestamp': timestamp,
    };
  }
}
