import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parking_project/screen/profile/ui/change-pass.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parking_project/root_page.dart';
import 'package:parking_project/screen/auth/login_screen.dart';
import 'package:parking_project/screen/checkout/ui/add_bank.dart';
import 'package:parking_project/screen/profile/profile_screen.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Settings extends StatefulWidget {

  const Settings({super.key});
  _StateSettings createState() => _StateSettings();
}

class _StateSettings extends State<Settings> {


  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm"),
          content: Text("Are you sure logout?"),
          backgroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng popup
              },
              child: Text("Cancer"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng popup trước khi logout
                logout();
              },
              child: Text("Log out", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void showChangePass() {
    final TextEditingController oldPassController = TextEditingController();
    final TextEditingController newPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Change Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPassController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Old Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: newPassController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng hộp thoại
              },
              child: Text("Hủy"),
            ),
            TextButton(
              onPressed: () async {
                String oldPass = oldPassController.text;
                String newPass = newPassController.text;

                if (oldPass.isEmpty || newPass.isEmpty) {

                  Fluttertoast.showToast(
                    msg: "Please enter require field!",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  return;
                }

                // Gọi API hoặc xử lý logic đổi mật khẩu ở đây
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? token = prefs.getString('access_token');
                try{
                  final rs = await Dio().post(
                    "http://18.182.12.54:8080/identity/users/change-password",
                    data: {
                      "oldPassword": oldPass,
                      "newPassword": newPass,
                    },
                    options: Options(
                      headers: {
                        "Content-Type": "application/json",
                        "Authorization": "Bearer $token",
                      },
                    ),
                  );
                  Fluttertoast.showToast(
                    msg: "Change password success!",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );

                }catch(e){
                  print("err $e");
                  Fluttertoast.showToast(
                    msg: "Error, please try again!",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }


              },
              child: Text("Change"),
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
                    "Setting",
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
                        "Language",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => ChangePass()),
                        );
                      },
                      child: Text(
                        "Change password",
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
                        "Log out",
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
