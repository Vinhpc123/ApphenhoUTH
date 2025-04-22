import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:apphenhouth/Login/Home/profile_setting.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool isInitializing = true;

  String name = '';
  String email = '';
  String phone = '';
  String dob = '';
  String photoBase64 = '';

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    await _createUserIfNotExists();
    setState(() {
      isInitializing = false;
    });
  }

  Future<void> _createUserIfNotExists() async {
    final user = currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'phone': user.phoneNumber ?? '',
        'dob': '',
        'photoURL': user.photoURL ?? '',
        'gender': '',
        'hobbies': '',
        'address': '',
        'height': '',
        'occupation': '',
        'maritalStatus': '',
        'education': '',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isInitializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("Không tìm thấy dữ liệu người dùng."));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            name = data['name'] ?? '';
            email = data['email'] ?? '';
            phone = data['phone'] ?? '';
            dob = data['dob'] ?? '';
            photoBase64 = data['photoURL'] ?? '';

            return Column(
              children: [
                ClipPath(
                  clipper: BottomCurveClipper(),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFF00E0C6),
                    padding: const EdgeInsets.only(top: 30, bottom: 70),
                    child: Column(
                      children: [
                        const Text(
                          "Hồ sơ cá nhân",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              key: ValueKey(photoBase64),
                              radius: 55,
                              backgroundImage: photoBase64.isNotEmpty
                                  ? (photoBase64.startsWith('data:image')
                                  ? MemoryImage(base64Decode(photoBase64.split(',').last))
                                  : NetworkImage(photoBase64)) as ImageProvider
                                  : const NetworkImage(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSlRM2-AldpZgaraCXCnO5loktGi0wGiNPydQ&s',
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 4,
                              child: GestureDetector(
                                onTap: _pickImageFromGallery,
                                child: const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.edit, size: 16, color: Colors.pink),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "$name, ${_calculateAge(dob)}",
                          style: const TextStyle(fontSize: 17, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: ListView(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Thiết lập tài khoản",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditProfileScreen(
                                      name: name,
                                      phone: phone,
                                      dob: dob,
                                      email: email,
                                      gender: data['gender'] ?? '',
                                      hobbies: data['hobbies'] ?? '',
                                      address: data['address'] ?? '',
                                      height: data['height'] ?? '',
                                      occupation: data['occupation'] ?? '',
                                      maritalStatus: data['maritalStatus'] ?? '',
                                      education: data['education'] ?? '',
                                    ),
                                  ),
                                );
                              },
                              child: const Text("Chỉnh sửa"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildProfileRow("Họ và tên", name),
                        _buildProfileRow("Số điện thoại", phone),
                        _buildProfileRow("Ngày sinh", dob),
                        _buildProfileRow("Email", email),
                        _buildProfileRow("Giới tính", data['gender'] ?? ''),
                        _buildProfileRow("Sở thích", data['hobbies'] ?? ''),
                        _buildProfileRow("Địa chỉ", data['address'] ?? ''),
                        _buildProfileRow("Chiều cao", data['height'] ?? ''),
                        _buildProfileRow("Công việc", data['occupation'] ?? ''),
                        _buildProfileRow("Tình trạng hôn nhân", data['maritalStatus'] ?? ''),
                        _buildProfileRow("Bằng cấp", data['education'] ?? ''),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _logOut,
                          child: const Text("Đăng xuất"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent[400]),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _deleteAccount,
                          child: const Text("Xóa tài khoản"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    final isHeightField = label == "Chiều cao" && double.tryParse(value) != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 15),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(
              isHeightField ? "$value cm" : value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateAge(String dob) {
    try {
      final parts = dob.split('-');
      final birthDate = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không có ảnh được chọn.")),
      );
      return;
    }

    try {
      final result = await FlutterImageCompress.compressWithFile(
        pickedFile.path,
        minWidth: 600,
        minHeight: 600,
        quality: 80,
      );

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không thể nén ảnh.")),
        );
        return;
      }

      final base64Image = "data:image/jpeg;base64,${base64Encode(result)}";

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .set({'photoURL': base64Image}, SetOptions(merge: true));

      setState(() {
        photoBase64 = base64Image;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật ảnh đại diện thành công!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cập nhật ảnh thất bại: $e")),
      );
    }
  }

  Future<void> _logOut() async {
    try {
      await FirebaseAuth.instance.signOut();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng xuất thành công")),
      );

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng xuất thất bại: $e")),
      );
    }
  }

  Future<void> _deleteAccount() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).delete();
      await currentUser!.delete();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Xóa tài khoản thất bại: $e")),
      );
    }
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
