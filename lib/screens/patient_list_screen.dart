import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/chat_service.dart';
import '../models/user.dart';
import 'chat_doctor_screen.dart';

class PatientListScreen extends StatelessWidget {
  final UserModel user;

  const PatientListScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient List'),
      ),
      body: _buildPatientList(context),
    );
  }

  Widget _buildPatientList(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ChatService.getChatsForUser(user.email),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final chatDocs = snapshot.data?.docs ?? [];

        if (chatDocs.isEmpty) {
          return const Text('No chat messages found.');
        }

        return ListView.builder(
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            final chatDoc = chatDocs[index];
            final chatData = chatDoc.data();

            /* final otherUserEmail = chatData['emails'] != null
                ? chatData['emails'].cast<String>().firstWhere(
                      (email) => email != user.email,
                      orElse: () => '',
                    )
                : '';

            return Card(
              child: ListTile(
                title: Text(otherUserEmail),
                onTap: () {
                  if (otherUserEmail.isNotEmpty) {
                    _openChatScreen(context, otherUserEmail);
                  }
                },
              ),
            ); */
            final senderEmail =
                chatData['email'] as String; // Retrieve sender's email

            return Card(
              child: ListTile(
                title: Text(senderEmail),
                onTap: () {
                  if (senderEmail.isNotEmpty) {
                    _openChatScreen(
                        context, senderEmail); // Pass sender's email
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  void _openChatScreen(BuildContext context, String receiverEmail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDoctorScreen(
          user: user,
          receiverEmail: receiverEmail,
        ),
      ),
    );
  }
}
