
import 'package:flutter/material.dart';
import 'package:parking_project/screen/home/ui/category_screen.dart';
import 'package:parking_project/screen/home/ui/maps.dart';
import 'package:parking_project/screen/home/ui/search_box.dart';
import 'package:parking_project/screen/home/ui/show_all.dart';
import 'package:parking_project/screen/home/ui/show_all_tab.dart';
import 'package:parking_project/screen/notice/ui/test.dart';

class HomeScreen extends StatelessWidget{
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          // Maps hiển thị dưới cùng
          const Maps(),
          //VietMapNavigationScreen()

          // SearchBox nằm phía trên Maps

           // Positioned(
           //    top: 51.0,
           //    left: 16.0,
           //    right: 16.0,
           //
           //    child: SearchBox(),
           //  ),






        ],
      ),
    );
  }
}