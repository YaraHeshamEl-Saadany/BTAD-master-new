import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/chat_service.dart';
import '../models/doctor.dart';
import '../models/user.dart';

class ChatPatientScreen extends StatefulWidget {
  final UserModel user;
  final Doctor doctor;

  const ChatPatientScreen({Key? key, required this.user, required this.doctor})
      : super(key: key);

  @override
  _ChatPatientScreenState createState() => _ChatPatientScreenState();
}

class _ChatPatientScreenState extends State<ChatPatientScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Stream<QuerySnapshot<Map<String, dynamic>>> _chatStream;

  @override
  void initState() {
    super.initState();
    _chatStream = ChatService.getChatsForUser(widget.user.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.doctor.name}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _chatStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                final chatDocs = snapshot.data?.docs.reversed.toList() ?? [];

                if (chatDocs.isEmpty) {
                  return Text('No chat messages found.');
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: chatDocs.length,
                  itemBuilder: (context, index) {
                    final chatDoc = chatDocs[index];
                    final chatData = chatDoc.data();
                    final senderEmail = chatData['senderEmail'];
                    final message = chatData['message'];

                    if (senderEmail == null || message == null) {
                      return SizedBox(); // Skip the null values
                    }

                    final isSender = senderEmail == widget.user.email;
                    // ignore: unused_local_variable
                    final bubbleAlignment = isSender
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start;
                    final bubbleColor =
                        isSender ? Colors.blue : Colors.grey.shade300;
                    final textColor = isSender ? Colors.white : Colors.black;

                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: isSender
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: bubbleColor,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              message,
                              style: TextStyle(color: textColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: 'Enter message'),
                  ),
                ),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final message = _messageController.text;
    if (message.isNotEmpty) {
      await ChatService.sendMessage(
        senderEmail: widget.user.email,
        receiverEmail: widget.doctor.email,
        message: message,
      );
      _messageController.clear();
    }
  }
}
