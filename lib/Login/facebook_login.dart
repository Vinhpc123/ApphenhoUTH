import 'package:flutter/material.dart';

class FacebookLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Facebook Login"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Đăng nhập bằng Facebook",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            // Thêm form đăng nhập Facebook ở đây
            // ...
          ],
        ),
      ),
    );
  }
}