import 'package:flutter/material.dart';
import 'package:apphenhouth/Login/phone_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneLoginScreen extends StatefulWidget {
  @override
  _PhoneLoginScreenState createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  Future<void> _sendOTP() async {
    String phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isNotEmpty) {
      try {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '+84$phoneNumber', // Chú ý format số điện thoại
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Nếu OTP được xác thực tự động
            await FirebaseAuth.instance.signInWithCredential(credential);
            // Điều hướng tới màn hình chính nếu thành công
          },
          verificationFailed: (FirebaseAuthException e) {
            // Xử lý lỗi xác thực
            print('Error: ${e.message}');
          },
          codeSent: (String verificationId, int? resendToken) {
            // Khi OTP được gửi, chuyển sang màn hình OTP
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PhoneOTPScreen(verificationId: verificationId),
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            // Thời gian hết hạn nếu OTP không được nhập
          },
        );
      } catch (e) {
        print("Error: $e");
      }
    } else {
      // Thông báo nếu số điện thoại trống
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid phone number')));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                'My number is',
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'VN +84',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Phone Number',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(),
              Text(
                'By clicking Log In, you agree with our Terms. Learn how process your data in our Privacy Policy and Cookies Policy. By clicking Log In, you agree with our Terms. Learn how process your data in our Privacy Policy and Cookies',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Xử lý sự kiện nhấn nút Continue
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00D6B3),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'CONTINUE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}