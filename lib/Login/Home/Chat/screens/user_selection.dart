import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apphenhouth/Login/Home/Chat/models/chat_model.dart';
import 'package:apphenhouth/Login/Home/Chat/screens/chat_detail_screen.dart';

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to select users')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select User to Chat'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
        builder: (context, currentUserSnapshot) {
          if (currentUserSnapshot.hasError) {
            return Center(child: Text('Error: ${currentUserSnapshot.error}'));
          }

          if (currentUserSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!currentUserSnapshot.hasData || !currentUserSnapshot.data!.exists) {
            return const Center(child: Text('Current user data not found'));
          }

          final currentUserData = currentUserSnapshot.data!.data() as Map<String, dynamic>;
          final likedUsers = (currentUserData['likedUsers'] as List<dynamic>?)?.cast<String>() ?? [];
          print('Current user likedUsers: $likedUsers');

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No users found'));
              }

              final mutuallyLikedUsers = snapshot.data!.docs.where((userDoc) {
                if (userDoc.id == currentUser.uid) return false;

                final userData = userDoc.data() as Map<String, dynamic>;
                final userLikedUsers = (userData['likedUsers'] as List<dynamic>?)?.cast<String>() ?? [];
                return likedUsers.contains(userDoc.id) && userLikedUsers.contains(currentUser.uid);
              }).toList();

              if (mutuallyLikedUsers.isEmpty) {
                return const Center(child: Text('No mutually liked users yet'));
              }

              return ListView.builder(
                itemCount: mutuallyLikedUsers.length,
                itemBuilder: (context, index) {
                  final userDoc = mutuallyLikedUsers[index];
                  final userData = userDoc.data() as Map<String, dynamic>;
                  final name = userData['displayName'] ?? userData['name'] ?? 'Unknown User';
                  final email = userData['email'] ?? 'No email';
                  final avatarUrl = userData['photoURL'] ?? '';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl.isEmpty ? const Icon(Icons.person) : null,
                    ),
                    title: Text(name),
                    subtitle: Text(email),
                    onTap: () async {
                      final currentUserId = currentUser.uid;
                      final selectedUserId = userDoc.id;

                      final participants = [currentUserId, selectedUserId];
                      participants.sort();

                      final chatQuery = await FirebaseFirestore.instance
                          .collection('chats')
                          .where('participants', isEqualTo: participants)
                          .get();

                      String chatId;
                      if (chatQuery.docs.isEmpty) {
                        final chatRef = await FirebaseFirestore.instance.collection('chats').add({
                          'participants': participants,
                          'lastMessage': '',
                          'time': DateTime.now().toString(),
                        });
                        chatId = chatRef.id;
                      } else {
                        chatId = chatQuery.docs.first.id;
                      }

                      final chat = Chat(
                        chatId: chatId,
                        userId: selectedUserId,
                        name: name,
                        lastMessage: '',
                        time: DateTime.now().toString(),
                        avatarUrl: avatarUrl,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(chat: chat),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}