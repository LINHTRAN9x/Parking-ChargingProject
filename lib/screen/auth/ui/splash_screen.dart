import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parking_project/root_page.dart';
import 'package:parking_project/screen/auth/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    // Đợi 2 giây rồi chuyển hướng
    await Future.delayed(Duration(seconds: 3));

    if (token != null && token.isNotEmpty) {
      // Nếu có token, chuyển đến màn hình Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RootPage()),
      );
    } else {
      // Nếu không có token, chuyển đến màn hình Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF5CCD8F),
        child: Center(
          child: Lottie.asset(
            'lib/assets/images/icons/pogo.json', // Thay bằng đường dẫn Lottie JSON của bạn
            width: MediaQuery.of(context).size.height * 0.33,
          ),
        ),
      )

    );
  }
}
