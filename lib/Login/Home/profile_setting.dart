import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String phone;
  final String dob;
  final String email;
  final String gender;
  final String hobbies;
  final String address;
  final String height;
  final String occupation;
  final String maritalStatus;
  final String education;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.phone,
    required this.dob,
    required this.email,
    required this.gender,
    required this.hobbies,
    required this.address,
    required this.height,
    required this.occupation,
    required this.maritalStatus,
    required this.education,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController dobController;
  late TextEditingController emailController;
  late TextEditingController genderController;
  late TextEditingController hobbiesController;
  late TextEditingController addressController;
  late TextEditingController heightController;
  late TextEditingController occupationController;
  late TextEditingController maritalStatusController;
  late TextEditingController educationController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    phoneController = TextEditingController(text: widget.phone);
    dobController = TextEditingController(text: widget.dob);
    emailController = TextEditingController(text: widget.email);
    genderController = TextEditingController(text: widget.gender);
    hobbiesController = TextEditingController(text: widget.hobbies);
    addressController = TextEditingController(text: widget.address);
    heightController = TextEditingController(text: widget.height);
    occupationController = TextEditingController(text: widget.occupation);
    maritalStatusController = TextEditingController(text: widget.maritalStatus);
    educationController = TextEditingController(text: widget.education);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    dobController.dispose();
    emailController.dispose();
    genderController.dispose();
    hobbiesController.dispose();
    addressController.dispose();
    heightController.dispose();
    occupationController.dispose();
    maritalStatusController.dispose();
    educationController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Người dùng chưa đăng nhập")),
          );
          setState(() => _isSaving = false);
        }
        return;
      }

      final phone = phoneController.text.trim();
      final validPrefixes = RegExp(r'^(03|05|07|08|09|01[2|6|8|9])');
      if (phone.length != 10 || !validPrefixes.hasMatch(phone)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Số điện thoại không hợp lệ")),
          );
          setState(() => _isSaving = false);
        }
        return;
      }

      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userData = <String, dynamic>{};

      // Chỉ gửi các trường đã thay đổi
      if (nameController.text.trim() != widget.name) {
        userData['name'] = nameController.text.trim();
      }
      if (phoneController.text.trim() != widget.phone) {
        userData['phone'] = phone;
      }
      if (dobController.text.trim() != widget.dob) {
        userData['dob'] = dobController.text.trim();
      }
      if (emailController.text.trim() != widget.email) {
        userData['email'] = emailController.text.trim();
      }
      if (genderController.text.trim() != widget.gender) {
        userData['gender'] = genderController.text.trim();
      }
      if (hobbiesController.text.trim() != widget.hobbies) {
        userData['hobbies'] = hobbiesController.text.trim().split(',').map((h) => h.trim()).toList();
      }
      if (addressController.text.trim() != widget.address) {
        userData['address'] = addressController.text.trim();
      }
      if (heightController.text.trim() != widget.height) {
        userData['height'] = heightController.text.trim();
      }
      if (occupationController.text.trim() != widget.occupation) {
        userData['occupation'] = occupationController.text.trim();
      }
      if (maritalStatusController.text.trim() != widget.maritalStatus) {
        userData['maritalStatus'] = maritalStatusController.text.trim();
      }
      if (educationController.text.trim() != widget.education) {
        userData['education'] = educationController.text.trim();
      }

      // Chỉ gửi nếu có dữ liệu thay đổi
      if (userData.isNotEmpty) {
        await userDocRef.set(userData, SetOptions(merge: true));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cập nhật thành công"),
            duration: Duration(seconds: 1),
          ),
        );

        // Đợi hiển thị snackbar hoàn tất trước khi đóng màn hình
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi cập nhật: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        dobController.text =
        "${picked.day}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chỉnh sửa hồ sơ")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _textField("Họ và tên", nameController),
            _textField("Số điện thoại", phoneController,
                keyboardType: TextInputType.phone, maxLength: 10, isPhone: true),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: _textField("Ngày sinh (dd-mm-yyyy)", dobController),
              ),
            ),
            _textField("Email", emailController, keyboardType: TextInputType.emailAddress),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: DropdownButtonFormField<String>(
                value: ['Nam', 'Nữ'].contains(genderController.text)
                    ? genderController.text
                    : null,
                items: ['Nam', 'Nữ'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: "Giới tính",
                  border: OutlineInputBorder(),
                ),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      genderController.text = newValue;
                    });
                  }
                },
              ),
            ),
            _textField("Sở thích", hobbiesController),
            _textField("Địa chỉ", addressController),
            _textField("Chiều cao (cm)", heightController, keyboardType: TextInputType.number),
            _textField("Công việc", occupationController),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: DropdownButtonFormField<String>(
                value: [
                  "Độc thân",
                  "Đang trong mối quan hệ mập mờ",
                  "Đã có bồ",
                  "Đã lập gia đình"
                ].contains(maritalStatusController.text)
                    ? maritalStatusController.text
                    : null,
                items: [
                  "Độc thân",
                  "Đang trong mối quan hệ mập mờ",
                  "Đã có bồ",
                  "Đã lập gia đình"
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: "Tình trạng hôn nhân",
                  border: OutlineInputBorder(),
                ),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      maritalStatusController.text = newValue;
                    });
                  }
                },
              ),
            ),
            _textField("Bằng cấp", educationController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isSaving
                  ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              )
                  : const Text("Lưu", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(
      String label,
      TextEditingController controller, {
        TextInputType keyboardType = TextInputType.text,
        int? maxLength,
        bool isPhone = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: isPhone
            ? [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ]
            : [],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          counterText: "",
        ),
      ),
    );
  }
}