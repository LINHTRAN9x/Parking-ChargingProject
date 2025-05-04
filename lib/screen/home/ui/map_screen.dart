
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MapScreen extends StatefulWidget{
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();

}
class _MapScreenState extends State<MapScreen>{

  @override
  Widget build(BuildContext context) {
    return Container(
      child:  SvgPicture.asset(
        "lib/assets/images/map/maps.svg",
        width: double.infinity, // Chiều rộng toàn màn hình
        height: double.infinity,
        fit: BoxFit.cover,
        color: Colors.blue,
      ),
      color: Colors.blue,
    );
  }
}