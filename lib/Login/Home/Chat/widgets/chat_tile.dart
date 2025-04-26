import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apphenhouth/Login/Home/Chat/models/chat_model.dart';

class ChatTile extends StatelessWidget {
  final Chat chat;
  final void Function(Chat) onTap; 

  const ChatTile({
    super.key,
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(chat.userId).get(),
      builder: (context, snapshot) {
        String name = chat.name;
        String avatarUrl = chat.avatarUrl;
        if (snapshot.hasData && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          name = userData['displayName'] ?? 'Unknown User';
          avatarUrl = userData['avatarUrl'] ?? '';
        }

        return ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey,
            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
            child: avatarUrl.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(chat.lastMessage),
          trailing: Text(chat.time),
          onTap: () {
            // Update the Chat object with the fetched name and avatarUrl
            final updatedChat = Chat(
              chatId: chat.chatId,
              userId: chat.userId,
              name: name,
              lastMessage: chat.lastMessage,
              time: chat.time,
              avatarUrl: avatarUrl,
            );
            onTap(updatedChat);
          },
        );
      },
    );
  }
}