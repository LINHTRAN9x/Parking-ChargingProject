
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parking_project/screen/home/ui/parking_details.dart';

class ParkingZone extends StatefulWidget {
  final List<Map<String, dynamic>> selectedSpots;
  final Function(Map<String, dynamic>) toggleSpotSelection;
  List<Map<String, dynamic>> parkingSlots;

  ParkingZone({
    required this.selectedSpots,
    required this.toggleSpotSelection,
    required this.parkingSlots,
    super.key,
  });

  @override
  _StateParkingZone createState() => _StateParkingZone();
}
class _StateParkingZone extends State<ParkingZone>{
  List<Map<String, dynamic>> spots = [];



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
    var parkingSlots = widget.parkingSlots;
    getParkingSlots(parkingSlots);
    print("parkingSlots:  $parkingSlots");
  }
  void getParkingSlots(parkingSlots) {
    setState(() {
      spots = parkingSlots.where((item) => item is Map<String, dynamic>) // Lọc bỏ dữ liệu không hợp lệ
          .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
          .toList();
      print("SPOTS: $spots");
    });
  }
  Map<String, List<Map<String, dynamic>>> groupByZone(List<Map<String, dynamic>> spots) {
    Map<String, List<Map<String, dynamic>>> groupedSpots = {};
    for (var spot in spots) {
      String zone = spot['zone'];
      if (!groupedSpots.containsKey(zone)) {
        groupedSpots[zone] = [];
      }
      groupedSpots[zone]!.add(spot);
    }
    return groupedSpots;
  }


  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedSpots = groupByZone(spots);
    return
      Container(
        height: MediaQuery.of(context).size.height * 0.58,
        child: GridView.builder(
          scrollDirection: Axis.vertical,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 cột (bố cục 2x2)
            crossAxisSpacing: 0.0,
            mainAxisSpacing: 0.0,
          ),
          itemCount: groupedSpots.keys.length, // Số lượng zone
          itemBuilder: (context, index) {
            String zone = groupedSpots.keys.elementAt(index);
            List<Map<String, dynamic>> zoneSpots = groupedSpots[zone]!;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 4),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header của mỗi Zone
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.03,
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 12),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          zone,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Hiển thị danh sách chỗ đậu xe của Zone này
                    Expanded(
                      child: GridView.builder(
                        shrinkWrap: false,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
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
                                color: _getSpotColor(spot),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: _getSpot(spot['status']) is String
                                  ? SvgPicture.asset(
                                _getSpot(spot['status']), // Dùng asset SVG
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
                  ],
                ),
              ),
            );
          },
        ),
      );

  }
}