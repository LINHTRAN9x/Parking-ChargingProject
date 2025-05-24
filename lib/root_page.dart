import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parking_project/screen/activities/activity_screen.dart';
import 'package:parking_project/screen/firebase.dart';
import 'package:parking_project/screen/home/home_screen.dart';
import 'package:parking_project/screen/home/ui/show_all.dart';
import 'package:parking_project/screen/notice/notice_screen.dart';
import 'package:parking_project/screen/profile/profile_screen.dart';

class RootPage extends StatefulWidget {
  final int initialIndex;
  const RootPage({super.key, this.initialIndex = 0});

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  late int _selectedIndex;
  final FirebaseService _firebaseService = FirebaseService();

  final List<Widget> screens = [
    HomeScreen(),
    ActivityScreen(),
    NoticeScreen(),
    ProfileScreen()
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Lấy giá trị index khi khởi tạo
    _firebaseService.initFCM();
  }

  void changeScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  BottomNavigationBarItem _buildNavItem(String iconFill, String iconOutline, String label, int index) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(top: 14, left: 39, bottom: 8, right: 39),
        child: SvgPicture.asset(
          _selectedIndex == index ? iconFill : iconOutline,
          width: 34,
          height: 24,
        ),
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //if (_selectedIndex == 0) ShowAll(),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black12, width: 1)),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: changeScreen,
              items: [
                _buildNavItem(
                  "lib/assets/images/icons/maps_fill.svg",
                  "lib/assets/images/icons/maps_outline.svg",
                  "Maps",
                  0,
                ),
                _buildNavItem(
                  "lib/assets/images/icons/activities_fill.svg",
                  "lib/assets/images/icons/activities_outline.svg",
                  "Activities",
                  1,
                ),
                _buildNavItem(
                  "lib/assets/images/icons/notice_fill.svg",
                  "lib/assets/images/icons/notice_outline.svg",
                  "Notice",
                  2,
                ),
                _buildNavItem(
                  "lib/assets/images/icons/profile_fill.svg",
                  "lib/assets/images/icons/profile_outline.svg",
                  "Profile",
                  3,
                ),
              ],
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.black54,
              backgroundColor: Colors.white,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                fontFamily: 'NotoSans',
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 13,
                fontFamily: 'NotoSans',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
