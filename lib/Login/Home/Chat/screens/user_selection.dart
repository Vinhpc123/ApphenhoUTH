import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:apphenhouth/Login/Home/Chat/screens/chat_detail_screen.dart';
import 'package:apphenhouth/Login/Home/Chat/models/chat_model.dart';

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select User to Chat'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('uid', isNotEqualTo: currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading users'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users available'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userData = user.data() as Map<String, dynamic>;

              return ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey,
                  backgroundImage: userData['avatarUrl'] != null && userData['avatarUrl'].isNotEmpty
                      ? NetworkImage(userData['avatarUrl'])
                      : null,
                  child: userData['avatarUrl'] == null || userData['avatarUrl'].isEmpty
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                title: Text(userData['displayName'] ?? 'Unknown User'),
                subtitle: Text(userData['email'] ?? ''),
                onTap: () async {
                  // Check if a chat already exists
                  final chatSnapshot = await FirebaseFirestore.instance
                      .collection('chats')
                      .where('participants', arrayContains: currentUser.uid)
                      .get();

                  String? chatId;
                  for (var doc in chatSnapshot.docs) {
                    final participants = doc['participants'] as List<dynamic>;
                    if (participants.contains(user.id)) {
                      chatId = doc.id;
                      break;
                    }
                  }

                  // If no chat exists, create a new one
                  if (chatId == null) {
                    final newChat = await FirebaseFirestore.instance.collection('chats').add({
                      'participants': [currentUser.uid, user.id],
                      'lastMessage': '',
                      'time': DateTime.now().toString(),
                    });
                    chatId = newChat.id;
                  }

                  // Fetch user data for the Chat object
                  final chat = Chat(
                    chatId: chatId,
                    userId: user.id,
                    name: userData['displayName'] ?? 'Unknown User',
                    lastMessage: '',
                    time: DateTime.now().toString(),
                    avatarUrl: userData['avatarUrl'] ?? '',
                  );

                  // Navigate to ChatDetailScreen
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(chat: chat),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}