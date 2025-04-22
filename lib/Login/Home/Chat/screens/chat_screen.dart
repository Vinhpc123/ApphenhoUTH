import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apphenhouth/Login/Home/Chat/screens/chat_detail_screen.dart';
import 'package:apphenhouth/Login/Home/Chat/screens/user_selection.dart';
import 'package:apphenhouth/Login/Home/Chat/models/chat_model.dart';
import 'package:apphenhouth/Login/Home/Chat/widgets/chat_tile.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Please sign in to view chats'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('ChatScreen StreamBuilder error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          print('ChatScreen snapshot hasData: ${snapshot.hasData}, docs count: ${snapshot.data?.docs.length ?? 0}');
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No chats yet'));
          }

          final chats = snapshot.data!.docs.map((doc) {
            print('Chat document data: ${doc.data()}');
            return Chat.fromJson(doc.data() as Map<String, dynamic>, doc.id, user.uid);
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ChatTile(
                chat: chat,
                onTap: (updatedChat) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(chat: updatedChat),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserSelectionScreen()),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}