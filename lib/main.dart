import 'package:apphenhouth/Login/phone_login.dart';
import 'package:apphenhouth/Login/signup.dart';
import 'package:apphenhouth/Login/wrapper.dart';
import 'package:apphenhouth/Login/Home/home.dart' hide ChatScreen;
import 'package:apphenhouth/Login/Home/Chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTH Love',
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/chat':
            return MaterialPageRoute(builder: (_) => const ChatScreen());
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Tuyến không xác định')),
              ),
            );
        }
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Wrapper()),
        );
      }
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
                  Image.asset('image/logo.png', width: 40, height: 40),
                  const SizedBox(height: 5),
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  // Save user data to Firestore
  Future<void> saveUserData(User user) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final docSnapshot = await docRef.get();

    // Only set photoURL from provider if it doesn't exist in Firestore
    String? photoURL = docSnapshot.exists ? docSnapshot.get('photoURL') : user.photoURL;

    await docRef.set({
      'uid': user.uid,
      'displayName': user.displayName ?? 'Anonymous',
      'email': user.email,
      'photoURL': photoURL ?? '', // Use existing photoURL if available
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // LOGIN BẰNG GOOGLE
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Người dùng hủy đăng nhập');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      await saveUserData(userCredential.user!);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DatingApp()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đăng nhập bằng Google thất bại: $e")),
        );
      }
    }
  }

  // LOGIN BẰNG FACEBOOK
  Future<void> loginWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success && result.accessToken != null) {
        final String accessToken = result.accessToken!.tokenString;

        final OAuthCredential credential = FacebookAuthProvider.credential(accessToken);
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        await saveUserData(userCredential.user!);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DatingApp()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Facebook sign-in failed: ${result.message}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Facebook sign-in failed: $e")),
        );
      }
    }
  }

  // LOGIN BẰNG SỐ ĐIỆN THOẠI
  void goToPhoneLogin() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PhoneLoginScreen()));
  }

  void goToSignup() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.tealAccent[400],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('image/logo.png', width: 40, height: 40),
                  const SizedBox(height: 5),
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
            const SizedBox(height: 180),
            const Text(
              "By clicking Log In, you agree with our Terms. Learn how we process your data in our Privacy Policy and Cookies Policy.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            _buildLoginButton(
              "LOGIN WITH GOOGLE",
              Icons.g_mobiledata,
              Colors.white,
              Colors.black,
              signInWithGoogle,
            ),
            _buildLoginButton(
              "LOGIN WITH FACEBOOK",
              Icons.facebook,
              Colors.white,
              Colors.blue,
              loginWithFacebook,
            ),
            _buildLoginButton(
              "LOGIN WITH PHONE",
              Icons.phone,
              Colors.white,
              Colors.green,
              goToPhoneLogin,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: goToSignup,
              child: const Text(
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
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
