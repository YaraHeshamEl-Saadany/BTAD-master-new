import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'patient')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final patientDocs = snapshot.data?.docs ?? [];

        if (patientDocs.isEmpty) {
          return const Text('No patients found.');
        }

        return ListView.builder(
          itemCount: patientDocs.length,
          itemBuilder: (context, index) {
            final patientDoc = patientDocs[index];
            final patientData = patientDoc.data();
            final patientEmail = patientData['email'] as String?;

            if (patientEmail == null) {
              return const SizedBox(); // Skip the null values
            }

            return Card(
              child: ListTile(
                title: Text(patientEmail),
                onTap: () {
                  if (patientEmail.isNotEmpty) {
                    _openChatScreen(context, patientEmail);
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
