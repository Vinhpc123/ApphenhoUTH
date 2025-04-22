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
          MaterialPageRoute(builder: (_) => const Wrapper()),
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

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final PageController _pageController = PageController();
  List<DocumentSnapshot> _users = [];
  int _currentPage = 0;

  Future<void> _likeUser(DocumentSnapshot likedUser) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final firestore = FirebaseFirestore.instance;
      final currentUserId = currentUser.uid;
      final likedUserId = likedUser.id;

      // 1. Kiểm tra đã thích chưa
      final userFavoritesRef = firestore
          .collection('users')
          .doc(currentUserId)
          .collection('favorites')
          .doc(likedUserId);

      if ((await userFavoritesRef.get()).exists) return;

      // 2. Thêm vào danh sách thích
      await userFavoritesRef.set({
        'userId': likedUserId,
        'name': likedUser['name'],
        'photoURL': likedUser['photoURL'],
        'likedAt': FieldValue.serverTimestamp(),
        'matched': false,
      });

      // 3. Kiểm tra có phải match không
      final otherUserFavoritesRef = firestore
          .collection('users')
          .doc(likedUserId)
          .collection('favorites')
          .doc(currentUserId);

      final otherUserFavorite = await otherUserFavoritesRef.get();

      if (otherUserFavorite.exists) {
        // 4. Tạo match nếu cả 2 cùng thích
        final batch = firestore.batch();

        // Cập nhật trạng thái match cho cả 2
        batch.update(userFavoritesRef, {'matched': true});
        batch.update(otherUserFavoritesRef, {'matched': true});

        // Thêm vào danh sách match
        batch.set(
          firestore.collection('users').doc(currentUserId).collection('matches').doc(likedUserId),
          {
            'userId': likedUserId,
            'name': likedUser['name'],
            'photoURL': likedUser['photoURL'],
            'matchedAt': FieldValue.serverTimestamp(),
            'notified': false,
          },
        );

        batch.set(
          firestore.collection('users').doc(likedUserId).collection('matches').doc(currentUserId),
          {
            'userId': currentUserId,
            'name': currentUser.displayName ?? 'Không tên',
            'photoURL': currentUser.photoURL ?? '',
            'matchedAt': FieldValue.serverTimestamp(),
            'notified': false,
          },
        );

        await batch.commit();
      }

      _nextUser();
    } catch (e) {
      debugPrint('Lỗi khi thích người dùng: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra: ${e.toString()}')),
      );
    }
  }

  void _nextUser() {
    if (_currentPage < _users.length - 1) {
      setState(() {
        _currentPage++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Center(child: Text('Vui lòng đăng nhập'));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, isNotEqualTo: currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        _users = snapshot.data!.docs;

        if (_users.isEmpty) {
          return const Center(child: Text('Không có người dùng nào để hiển thị'));
        }

        return Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ProfileCard(
                    name: user['name'],
                    distance: "Gần bạn",
                    imageUrl: user['photoURL'],
                  );
                },
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SwipeButton(
                    icon: Icons.close,
                    color: Colors.red,
                    onPressed: _nextUser,
                  ),
                  SwipeButton(
                    icon: Icons.favorite,
                    color: Colors.pink,
                    onPressed: () => _likeUser(_users[_currentPage]),
                  ),
                ],
              ),
            ),
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

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Vui lòng đăng nhập'));
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Danh sách yêu thích'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Đã thích'),
              Tab(text: 'Đã match'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Danh sách đã thích
            _buildFavoritesList(currentUser.uid, false),
            // Tab 2: Danh sách đã match
            _buildFavoritesList(currentUser.uid, true),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(String userId, bool matchedOnly) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection(matchedOnly ? 'matches' : 'favorites')
          .orderBy(matchedOnly ? 'matchedAt' : 'likedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(matchedOnly
                ? 'Bạn chưa có match nào'
                : 'Bạn chưa thích ai cả'),
          );
        }

        final items = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(item['userId'])
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    leading: CircularProgressIndicator(),
                    title: Text('Đang tải...'),
                  );
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: const Text('Người dùng không tồn tại'),
                  );
                }

                final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                final photoUrl = userData['photoURL'] ?? '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: photoUrl.isNotEmpty
                          ? photoUrl.startsWith('data:image')
                          ? MemoryImage(base64Decode(photoUrl.split(',').last))
                          : NetworkImage(photoUrl) as ImageProvider
                          : const AssetImage('image/placeholder.png'),
                    ),
                    title: Text(userData['name'] ?? 'Không có tên'),
                    subtitle: Text(userData['email'] ?? ''),
                    trailing: matchedOnly
                        ? const Icon(Icons.favorite, color: Colors.pink)
                        : IconButton(
                      icon: const Icon(Icons.chat, color: Colors.grey),
                      onPressed: () {
                        // Chỉ có thể chat khi đã match
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Hãy đợi đối phương thích lại bạn!'),
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      // Xem chi tiết profile
                    },
                  ),
                );
              },
            );
          },
        );
      },
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