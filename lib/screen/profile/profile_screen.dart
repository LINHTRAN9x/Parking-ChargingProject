import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
//import 'package:parking_project/screen/example/main.dart';
import 'package:parking_project/screen/home/ui/map_screen.dart';
import 'package:parking_project/screen/home/ui/maps.dart';
import 'package:parking_project/screen/notice/ui/test.dart';
import 'package:parking_project/screen/profile/ui/account_link.dart';
import 'package:parking_project/screen/profile/ui/personal_profile.dart';
import 'package:parking_project/screen/profile/ui/settings.dart';
import 'package:parking_project/screen/profile/ui/support.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _StateProfileScreen createState() => _StateProfileScreen();
}
class _StateProfileScreen extends State<ProfileScreen>{
  var user = {};

  Future<void> getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    try{
      final rs = await Dio().get(
          "http://18.182.12.54:8080/identity/users/me",
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );
      print("profile1 ${rs.data['result']}");
      setState(() {
        user = rs.data['result'];
      });
    }catch(e){
      print("err $e");
    }

  }

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Phần trên cùng với ảnh nền và avatar
            Stack(
              alignment: Alignment.center,
              children: [
                // Ảnh nền xanh
                Container(
                  height: MediaQuery.of(context).size.height * 0.27,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("lib/assets/images/icons/profile-bg.png"), // Thay bằng ảnh wave
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Ảnh đại diện
                Positioned(
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: user['avatarUrl'] != null
                        ? NetworkImage(user['avatarUrl'])
                        : AssetImage('lib/assets/images/icons/avatar.png'),
                  )

                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            // Thông tin người dùng
            Text(
              user['username'] ?? '',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              user['phone'] ?? '',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            // Danh sách menu
            Expanded(
              child: ListView(
                  children: [
                    ListTile(
                    leading: SvgPicture.asset(
                    'lib/assets/images/icons/profile-circle.svg',
                      width: 24, // Định kích thước icon nếu cần
                      height: 24,
                    ),
                    title: Text(
                      'Personal Profile',
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PersonalProfile(user: user)));
                    },
                  ),
                    ListTile(
                      leading: SvgPicture.asset(
                        'lib/assets/images/icons/link.svg',
                        width: 24,
                        height: 24,
                      ),
                      title: Text(
                        'Account Linking',
                        style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const AccountLink()));
                      },
                    ),
                    ListTile(
                      leading: SvgPicture.asset(
                        'lib/assets/images/icons/card.svg',
                        width: 24,
                        height: 24,
                      ),
                      title: Text(
                        'Bank & Cards',
                        style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> VietMapNavigationScreen()));
                      },
                    ),
                    ListTile(
                      leading: SvgPicture.asset(
                        'lib/assets/images/icons/ticket.svg',
                        width: 24,
                        height: 24,
                      ),
                      title: Text(
                        'Promo Package',
                        style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onTap: () {

                      },
                    ),
                    ListTile(
                      leading: SvgPicture.asset(
                        'lib/assets/images/icons/headphone.svg',
                        width: 24,
                        height: 24,
                      ),
                      title: Text(
                        'Support',
                        style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Support()));
                      },
                    ),
                    ListTile(
                      leading: SvgPicture.asset(
                        'lib/assets/images/icons/setting-2.svg',
                        width: 24,
                        height: 24,
                      ),
                      title: Text(
                        'Setting',
                        style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const Settings()));
                      },
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
