import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parking_project/screen/profile/ui/booking_issues.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parking_project/root_page.dart';
import 'package:parking_project/screen/auth/login_screen.dart';
import 'package:parking_project/screen/checkout/ui/add_bank.dart';
import 'package:parking_project/screen/profile/profile_screen.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Support extends StatefulWidget {

  const Support({super.key});
  _StateSupport createState() => _StateSupport();
}

class _StateSupport extends State<Support> {


  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác nhận"),
          content: Text("Bạn có chắc chắn muốn đăng xuất không?"),
          backgroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng popup
              },
              child: Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng popup trước khi logout
                logout();
              },
              child: Text("Đăng xuất", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void logout()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');

    // Quay về màn hình Login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ⬅️ Nút quay lại
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const RootPage(initialIndex: 3)),
                      );
                    },
                    child: SvgPicture.asset(
                      'lib/assets/images/icons/arrow-left.svg',
                      width: 24,
                      height: 24,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Support",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    GestureDetector(
                      onTap: () {

                      },
                      child: Text(
                        "Phone support",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => BookingIssues()
                        );
                      },
                      child: Text(
                        "Booking Issues",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showLogoutDialog(context);
                      },
                      child: Text(
                        "Service Issues",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500
                        ),
                      ),
                    )
                  ])


            ],
          ),
        ),
      ),

    );
  }


}
