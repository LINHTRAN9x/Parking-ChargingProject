import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parking_project/root_page.dart';
import 'package:parking_project/screen/checkout/ui/add_bank.dart';
import 'package:parking_project/screen/profile/profile_screen.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AccountLink extends StatefulWidget {

  const AccountLink({super.key});
  _StateAccountLink createState() => _StateAccountLink();
}

class _StateAccountLink extends State<AccountLink> {
  bool isFacebookOn = true;
  bool isGoogleOn = false;


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
                    "Account linking",
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildToggleRow(
                        "Facebook", "lib/assets/images/icons/logo_facebook.png", isFacebookOn, (val) {
                      setState(() {
                        isFacebookOn = val;
                      });
                    }),
                    const SizedBox(height: 20),
                    buildToggleRow(
                        "Google", "lib/assets/images/icons/logo_google.png", isGoogleOn, (val) {
                      setState(() {
                        isGoogleOn = val;
                      });
                    }),
                  ])


            ],
          ),
        ),
      ),

    );
  }

  Widget buildToggleRow(String text, String iconPath, bool toggleValue,
      Function(bool) onToggle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(iconPath, width: 24, height: 24),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(fontSize: 16)),
          ],
        ),
        FlutterSwitch(
          width: 50,
          height: 25,
          value: toggleValue,
          activeColor: Colors.green,
          inactiveColor: Colors.grey[300]!,
          onToggle: onToggle,
        ),
      ],
    );
  }
}
