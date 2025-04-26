import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'Home/home.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.active) {
          final user = authSnapshot.data;

          if (user == null) {
            return const LoginScreen();
          } else {
            return Stack(
              children: [
                const HomeScreen(),
                MatchNotifier(userId: user.uid),
              ],
            );
          }
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MatchNotifier extends StatefulWidget {
  final String userId;

  const MatchNotifier({super.key, required this.userId});

  @override
  State<MatchNotifier> createState() => _MatchNotifierState();
}

class _MatchNotifierState extends State<MatchNotifier> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('matches')
          .where('notified', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _processMatches(snapshot.data!.docs);
          });
        }
        return const SizedBox.shrink();
      },
    );
  }

  Future<void> _processMatches(List<DocumentSnapshot> matches) async {
    final firestore = FirebaseFirestore.instance;

    for (final matchDoc in matches) {
      final matchData = matchDoc.data() as Map<String, dynamic>;

      // Hiển thị thông báo match
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Bạn và ${matchData['name']} đã thích nhau!'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Đánh dấu đã thông báo
      await matchDoc.reference.update({'notified': true});
    }
  }
}