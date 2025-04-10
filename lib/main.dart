import 'package:apphenhouth/Login/facebook_login.dart';
import 'package:apphenhouth/Login/google_login.dart';
import 'package:apphenhouth/Login/phone_login.dart';
import 'package:apphenhouth/Login/signup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.tealAccent[400],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'image/logo.png', // Adjust the path and filename as needed
                    width: 40, // Match the size of the previous icon
                    height: 40,
                  ),
                  SizedBox(height: 5),
                  Text(
                    "UTH Love",
                    style: GoogleFonts.pacifico(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
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

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.tealAccent[400],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 100),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'image/logo.png', // Adjust the path and filename as needed
                    width: 40, // Match the size of the previous icon
                    height: 40,
                  ),
                  SizedBox(height: 5),
                  Text(
                    "UTH Love",
                    style: GoogleFonts.pacifico(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 180),
            Text(
              "By clicking Log In, you agree with our Terms. Learn how we process your data in our Privacy Policy and Cookies Policy.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            _buildLoginButton(
                "LOGIN WITH GOOGLE",
                Icons.g_mobiledata,
                Colors.white,
                Colors.black,
                    () {
                  // Điều hướng đến trang đăng nhập Google
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GoogleLoginScreen()),
                  );
                }
            ),
            _buildLoginButton(
                "LOGIN WITH FACEBOOK",
                Icons.facebook,
                Colors.white,
                Colors.blue,
                    () {
                  // Điều hướng đến trang đăng nhập Facebook
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FacebookLoginScreen()),
                  );
                }
            ),
            _buildLoginButton(
                "LOGIN WITH PHONE",
                Icons.phone,
                Colors.white,
                Colors.green,
                    () {
                  // Điều hướng đến trang đăng nhập bằng số điện thoại
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PhoneLoginScreen()),
                  );
                }
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Điều hướng đến trang đăng ký
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              child: Text(
                "Don't have an account? Signup",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton(String text, IconData icon, Color bgColor, Color iconColor, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: iconColor),
        label: Text(
          text,
          style: TextStyle(color: iconColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
