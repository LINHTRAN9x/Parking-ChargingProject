import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parking_project/screen/home/ui/parking_details.dart';

class ChargingZone extends StatefulWidget {
  final List<Map<String, dynamic>> selectedSpots;
  final Function(Map<String, dynamic>) toggleSpotSelection;
  List<Map<String, dynamic>> chargingSlots;

   ChargingZone({
    required this.selectedSpots,
    required this.toggleSpotSelection,
    required this.chargingSlots,
    super.key,
  });

  @override
  _StateChargingZone createState() => _StateChargingZone();
}
class _StateChargingZone extends State<ChargingZone>{
  List<Map<String, dynamic>> chargingSpots = [];


  bool isSelected(Map<String, dynamic> spot) {

    return widget.selectedSpots.contains(spot);
  }


  Color _getSpotColor(Map<String, dynamic> spot) {
    // If the spot is selected, return red, otherwise return its default color
    if (isSelected(spot)) {
      return Color(0xff00A8FF); // Red for selected spots
    } else {
      return _getSpot(spot['status']) is Color ? _getSpot(spot['status']) : Colors.transparent; // Default color
    }
  }

  dynamic _getSpot(String status) {
    switch (status) {
      case 'AVAILABLE':
        return Color(0xFFD9D9D9);
      case 'RESERVED':
        return Color(0xFF00A8FF);
      case 'BLOCKED':
        return 'lib/assets/images/icons/bloked.svg';
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    var chargingSlots = widget.chargingSlots;
    getChargingSlots(chargingSlots);
    print("ChargingSpotss:  $chargingSlots");
  }
  void getChargingSlots(chargingSlots) {
    setState(() {
      chargingSpots = chargingSlots.where((item) => item is Map<String, dynamic>) // Lọc bỏ dữ liệu không hợp lệ
          .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
          .toList();
      print("chargingSpots: $chargingSpots");
    });
  }
  Map<String, List<Map<String, dynamic>>> groupByGate(List<Map<String, dynamic>> spots) {
    Map<String, List<Map<String, dynamic>>> groupedSpots = {};
    for (var spot in spots) {
      String zone = spot['gate'];
      if (!groupedSpots.containsKey(zone)) {
        groupedSpots[zone] = [];
      }
      groupedSpots[zone]!.add(spot);
    }
    return groupedSpots;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedSpots = groupByGate(chargingSpots);
    return
      Container(
      height: MediaQuery.of(context).size.height * 0.58, // Height for parking lots section
      child: GridView.builder(
        scrollDirection: Axis.vertical,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1, // 2 columns (for 2x2 layout)
          crossAxisSpacing: 0.0,
          mainAxisSpacing: 0.0,
        ),
        itemCount: groupedSpots.keys.length,
        itemBuilder: (context, index) {

          String zone = groupedSpots.keys.elementAt(index);
          List<Map<String, dynamic>> zoneSpots = groupedSpots[zone]!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.02,
              decoration: BoxDecoration(
                color: Colors.white, // background color of the container
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12, // Shadow color with opacity
                    offset: Offset(0, 4), // Horizontal and vertical offset of the shadow
                    blurRadius: 18, // Blur radius to make the shadow soft
                    spreadRadius: 1, // Spread radius to control how far the shadow extends
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.03,
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 12),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(4)
                    ),
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          zone,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white
                          ),
                        )

                    ),
                  ),
                  // 4x4 grid for spots inside each parking lot
                  Expanded(
                    child: Container(
                      child: GridView.builder(
                        shrinkWrap: false,
                         physics: const NeverScrollableScrollPhysics(), // Uncomment if you want to disable scroll
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5, // 3 columns
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: zoneSpots.length,
                        itemBuilder: (context, spotIndex) {
                          var spot = zoneSpots[spotIndex];

                          return GestureDetector(
                            onTap: spot['status'] != 'BLOCKED'
                                ? () {
                              widget.toggleSpotSelection(spot);
                            }
                                : null,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _getSpotColor(spot), // Customize color based on status
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: _getSpot(spot['status']) is String
                                  ? SvgPicture.asset(
                                _getSpot(spot['status']), // Use the asset path
                                width: 100,
                                height: 100,
                              )
                                  : Text(
                                spot['slotNumber'],
                                style: TextStyle(
                                  color: isSelected(spot) ? Colors.white : Colors.black, // Đổi màu chữ khi selected
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )

                ],
              ),
            ),
          );
        },
      ),
    );

  }
}