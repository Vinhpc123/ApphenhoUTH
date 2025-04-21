import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apphenhouth/Login/wrapper.dart';
import 'package:apphenhouth/Login/Home/profile.dart';

import '../../main.dart';

void main() {
  runApp(const DatingApp());
}

class DatingApp extends StatelessWidget {
  const DatingApp({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dating App',
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),

      home: const Wrapper(), // Dùng Wrapper để điều hướng Login / Home
      routes: {
        '/login': (context) => LoginScreen(),
      },
    );
  }

}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      saveUserInfoToFirestore(user!);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) =>  Wrapper()),
        );
      });
    }
  }

  Future<void> saveUserInfoToFirestore(User user) async {
    final firestore = FirebaseFirestore.instance;
    final userRef = firestore.collection('users').doc(user.uid);
    final docSnapshot = await userRef.get();

    if (!docSnapshot.exists) {
      await userRef.set({
        'name': user.displayName ?? 'Tên người dùng',
        'email': user.email ?? 'Email không có',
        'phone': user.phoneNumber ?? '',
        'dob': '',
        'photoURL': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'gender': '',
        'hobbies': '',
        'address': '',
        'height': '',
        'occupation': '',
        'maritalStatus': '',
        'education': '',
      });
    } else {
      await userRef.set(
        {
          'name': user.displayName ?? 'Tên người dùng',
          'email': user.email ?? 'Email không có',
          'phone': user.phoneNumber ?? '',
        },
        SetOptions(merge: true),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'image/logo.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 12),
            Text(
              'UTH Love',
              style: GoogleFonts.pinyonScript(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              // Reset toàn bộ navigation stack và quay lại Wrapper
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const Wrapper()),
                    (route) => false,
              );
            },

          ),
        ],
      )
          : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomeContent(),
          ChatScreen(),
          FavoritesScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Thích"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) =>  Wrapper()),
        );
      });
      return const Center(child: Text('Đang chuyển hướng đến trang đăng nhập...'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('StreamBuilder error: ${snapshot.error}');
          return const Center(child: Text('Đã xảy ra lỗi khi tải dữ liệu'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        print('Snapshot hasData: ${snapshot.hasData}');
        if (!snapshot.hasData) {
          return const Center(child: Text('Không nhận được dữ liệu từ Firestore'));
        }

        print('Docs count: ${snapshot.data!.docs.length}');
        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Không có người dùng nào trong hệ thống'));
        }

        final users = snapshot.data!.docs.where((doc) => doc.id != currentUser.uid).toList();
        print('Filtered users count: ${users.length}');

        if (users.isEmpty) {
          return const Center(child: Text('Không tìm thấy người dùng phù hợp. Hãy thử lại sau!'));
        }

        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: PageView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final name = user['name'] ?? 'No Name';
                    final photoUrl = user['photoURL'] ?? '';
                    final distance = 'Gần bạn';

                    return ProfileCard(
                      name: name,
                      distance: distance,
                      imageUrl: photoUrl,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SwipeButton(icon: Icons.close, color: Colors.red, onPressed: () {}),
                SwipeButton(icon: Icons.favorite, color: Colors.pink, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Chat Screen",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Danh sách yêu thích",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final String name;
  final String distance;
  final String imageUrl;

  const ProfileCard({
    super.key,
    required this.name,
    required this.distance,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            imageUrl.isNotEmpty
                ? imageUrl.startsWith('data:image')
                ? Image.memory(
              base64Decode(imageUrl.split(',').last),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'image/placeholder.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            )
                : Image.network(
              imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'image/placeholder.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            )
                : Image.asset(
              'image/placeholder.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    distance,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SwipeButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const SwipeButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: color,
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 30),
        onPressed: onPressed,
      ),
    );
  }
}