import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              style: GoogleFonts.pinyonScript(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => const FilterBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomeContent(),
          const ChatScreen(),
          const FavoritesScreen(),
          const ProfileScreen(),
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

// Trang Home với Swiping Profiles
// Trang Home với Swiping Profiles
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20), // Padding 10px
            child: PageView(
              children: const [
                ProfileCard(name: 'Rek, 27', distance: '5 miles', imageUrl: 'https://cdn.kona-blue.com/upload/kona-blue_com/post/images/2024/09/19/467/avatar-anime-nam-6.jpg'),
                ProfileCard(name: 'John, 24', distance: '7 miles', imageUrl: 'https://cdn.kona-blue.com/upload/kona-blue_com/post/images/2024/09/19/467/avatar-anime-nam-9.jpg'),
                ProfileCard(name: 'Alex, 21', distance: '3 miles', imageUrl: 'https://cdn.kona-blue.com/upload/kona-blue_com/post/images/2024/09/19/467/avatar-anime-nam-10.jpg'),
              ],
            ),
          ),
        ), // <-- Đóng Expanded đúng vị trí
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
  }
}


// Màn hình Chat
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Chat Screen", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }
}

// Màn hình Yêu thích
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Danh sách yêu thích", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }
}

// Màn hình Hồ sơ
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Profile Screen", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }
}

// Thẻ hồ sơ người dùng
class ProfileCard extends StatelessWidget {
  final String name;
  final String distance;
  final String imageUrl;

  const ProfileCard({super.key, required this.name, required this.distance, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Image.network(
                imageUrl,
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
                    Text(name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(distance, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}


// Nút thích / không thích
class SwipeButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const SwipeButton({super.key, required this.icon, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: color, // Đổi màu nền theo button
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 30), // Luôn màu trắng
        onPressed: onPressed,
      ),
    );
  }
}


// Bộ lọc tìm kiếm
class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Bộ lọc', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Khoảng cách', style: TextStyle(fontWeight: FontWeight.bold)),
          Slider(value: 5, min: 0, max: 10, divisions: 10, onChanged: (value) {}),
          const SizedBox(height: 16),
          const Text('Giới tính', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(label: const Text('Nam'), selected: true, onSelected: (value) {}),
              FilterChip(label: const Text('Nữ'), selected: false, onSelected: (value) {}),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Áp dụng'),
          ),
        ],
      ),
    );
  }
}
