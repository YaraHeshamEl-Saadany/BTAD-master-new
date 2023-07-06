import 'package:cloud_firestore/cloud_firestore.dart';

class PatientInfo {
  final String name;
  final String phone;
  final String email;

  const PatientInfo({
    required this.name,
    required this.phone,
    required this.email,
  });

  factory PatientInfo.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final userData = document.data()!;
    return PatientInfo(
      name: userData['name'],
      phone: userData['phone'],
      email: userData['email'],
    );
  }
}
