import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parking_project/root_page.dart';
import 'package:parking_project/screen/checkout/checkout_screen.dart';
import 'package:parking_project/screen/home/ui/charging_zone.dart';
import 'package:parking_project/screen/home/ui/parking_details.dart';
import 'package:parking_project/screen/home/ui/parking_zone.dart';
import 'package:parking_project/screen/home/ui/show_all.dart';
import 'package:parking_project/screen/home/ui/show_all_tab.dart';
import 'package:parking_project/screen/home/ui/show_time_filter.dart';

class SparkparkingStation extends StatefulWidget {
  List<Map<String, dynamic>> spots;
  List<String> availableSlots;
  List<String> unavailableSlots;
  final int durationMinutes;
  Map<String, dynamic> station;
  final String dateStart;
  final String dateEnd;
  SparkparkingStation({super.key, required this.spots, required this.availableSlots,required this.unavailableSlots,
    required this.durationMinutes, required this.station, required this.dateStart, required this.dateEnd});

  @override
  _StateSparkparkingStation createState() => _StateSparkparkingStation();
}

class _StateSparkparkingStation extends State<SparkparkingStation> with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> parkingSlots = [];
  List<Map<String, dynamic>> chargingSlots = [];
  List<Map<String, dynamic>> orders = [];
  bool isLoading = false;
  late Set<String> availableSlotSet;
  late Set<String> unavailableSlotSet;



  @override
  bool get wantKeepAlive => true;



  List<Map<String, dynamic>> zones = [
    {"id": 1, "name": "Parking zone"},
    {"id": 2, "name": "Charging zone"},
  ];
  int selectedZoneId = 1;

  List<Map<String, dynamic>> selectedSpots = [];


  void toggleSpotSelection(Map<String, dynamic> spot) {
    setState(() {
      int index = selectedSpots.indexWhere((s) => s['id'] == spot['id']);
      if (index >= 0) {
        selectedSpots.removeAt(index);
      } else {
        selectedSpots.add(spot);
      }
    });
  }



  @override
  void initState() {
    super.initState();
    availableSlotSet = widget.availableSlots.toSet();
    unavailableSlotSet = widget.unavailableSlots.toSet();
    classifySlots();
    print("XXX ${widget.spots}");

  }
  void classifySlots() {
    parkingSlots = widget.spots.where((spot) {
      bool isParking = spot['type'] == 'PARKING';
      spot['status'] = _determineSlotStatus(spot['slotNumber']);
      return isParking;
    }).toList();

    chargingSlots = widget.spots.where((spot) {
      bool isCharging = spot['type'] == 'CHARGING';
      spot['status'] = _determineSlotStatus(spot['slotNumber']);
      return isCharging;
    }).toList();

    setState(() {});
  }


  String _determineSlotStatus(String id) {
    if (unavailableSlotSet.contains(id)) return 'BLOCKED';
    if (availableSlotSet.contains(id)) return 'AVAILABLE';
    return 'unknown';
  }



  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     showModalBottomSheet(
  //       backgroundColor: Colors.transparent,
  //       context: context,
  //       isScrollControlled: true,
  //       builder: (context) => ShowTimeFilter(),
  //     );
  //   });
  // }
  
  Future<void> createOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    setState(() {
      isLoading = true;
    });

    if (selectedSpots.isEmpty) {
      Fluttertoast.showToast(
        msg: "Chưa có vị trí nào được chọn.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER, // Hiển thị ở giữa màn hình
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() {
        isLoading = false;
      });

      return;
    }


    String type = selectedZoneId == 1 ? "PARKING" : "CHARGING";

    DateTime now = DateTime.now().add(Duration(minutes: 2));
    String startDateTime = widget.dateStart;
    String endDateTime = widget.dateEnd;
    print('selectedSpots $selectedSpots');

    List<Map<String, dynamic>> slotBasicInfos = selectedSpots.map((spot) {
      return {
        "slotId": spot['id'],
        "startDateTime": startDateTime,
        "endDateTime": endDateTime,
      };
    }).toList();


    Map<String, dynamic> requestBody = {
      "locationId": widget.station['id'], // ID của bãi đỗ xe
      "serviceProvidedEnums": type,
      "slotBasicInfos": slotBasicInfos,
    };

    print("Request Body: ${jsonEncode(requestBody)}");
    try {
      var response = await Dio().post(
        "http://18.182.12.54:8082/app-data-service/bookings/create",
        data: requestBody,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Đặt chỗ thành công: ${response.data['booking']}");
        setState(() {
          orders.add(response.data['booking']);
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CheckoutScreen(
              selectedSpots: selectedSpots.isNotEmpty ? selectedSpots : [],
                spots: widget.spots,
                availableSlots: widget.availableSlots,
                orders: orders,
                station: widget.station,
                durationMinutes: widget.durationMinutes,
                unavailableSlots: widget.unavailableSlots,
                dateStart: widget.dateStart,
                dateEnd: widget.dateEnd,
                voucher: {}
            ),
          ),
        );
      } else {
        print("Lỗi đặt chỗ: ${response.statusCode} - ${response.data}");
      }
    } catch (e) {
      if (e is DioException) {
        print("Lỗi khi gửi yêu cầu: ${e.response?.statusCode}");
        Fluttertoast.showToast(
          msg: "Vị trí đã được đặt!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER, // Hiển thị ở giữa màn hình
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        print("Chi tiết lỗi: ${e.response?.data}");
      } else {
        print("Lỗi không xác định: $e");
      }
    }finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  String formatDateTime(DateTime dateTime) {
    return dateTime.toIso8601String().split('.')[0] + "+07:00";
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 47, 20, 0),
              child:
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 12),
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => RootPage(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    const begin = Offset(-1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;

                                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                    var offsetAnimation = animation.drive(tween);

                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                            child: SvgPicture.asset(
                              'lib/assets/images/icons/arrow-left.svg',
                              width: 24,
                              height: 24,
                              color: Colors.black,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: const Text(
                              "SparkParking Station",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          )


                        ],
                      )
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 35, // Chiều cao tổng danh sách
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: zones.length,
                          itemBuilder: (context, index) {
                            final zone = zones[index];
                            final isSelected = selectedZoneId == zone["id"];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedZoneId = zone["id"]; // Cập nhật zone đang chọn
                                  final selectedType = selectedZoneId == 1 ? "PARKING" : "CHARGING";
                                  selectedSpots = widget.spots // Lấy từ danh sách gốc widget.spots
                                      .where((spot) =>
                                  spot['type'] == selectedType &&
                                      spot['status'] != 'BLOCKED' &&
                                      spot['zone'] == zone["name"]) // Thêm luôn điều kiện đúng zone
                                      .toList();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected ? Color(0xFF00B150) : Colors.black38,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(50.0),
                                  color: isSelected ? Color(0xFF00B150) : Colors.white,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      zone["name"],
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected ? Colors.white : Colors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 22,
                    children: [
                      Row(
                        spacing: 10,
                        children: [
                          SvgPicture.asset(
                            'lib/assets/images/icons/available.svg',
                            width: null,
                            height: null,
                          ),
                          Text(
                              'Available'
                          )
                        ],
                      ),
                      Row(
                        spacing: 10,
                        children: [
                          SvgPicture.asset(
                            'lib/assets/images/icons/bloked.svg',
                            width: null,
                            height: null,
                          ),
                          Text(
                              'Blocked'
                          )
                        ],
                      ),
                      Row(
                        spacing: 10,
                        children: [
                          SvgPicture.asset(
                            'lib/assets/images/icons/reserved.svg',
                            width: null,
                            height: null,
                          ),
                          Text(
                              'Reserved'
                          )
                        ],
                      )

                    ],
                  ),
                  const SizedBox(height: 22),
                  Container(
                    color: Color(0xFFCDCDCD),
                    height: 2,
                  ),
                ],
              ),
            ),



            const SizedBox(height: 10),
            // 2x2 grid for parking lots
            Column(
              children: [
                if (selectedZoneId == 1) ParkingZone(
                  parkingSlots: parkingSlots,
                  selectedSpots: selectedSpots,
                  toggleSpotSelection: toggleSpotSelection,

                ),
                if (selectedZoneId == 2) ChargingZone(
                selectedSpots: selectedSpots,
                toggleSpotSelection: toggleSpotSelection,
                    chargingSlots: chargingSlots
                ),
              ],
            )

          ],
        ),
      ),
      bottomNavigationBar:
      SafeArea(
          child: Container(
            height: 112,
            padding: EdgeInsets.all(10),
            // Màu nền cho container
            decoration: BoxDecoration(
              color: Colors.white,
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.grey.withOpacity(0.5), // Màu bóng mờ
              //     offset: Offset(0, 1), // Vị trí bóng
              //     blurRadius: 6, // Độ mờ của bóng
              //   )
              // ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), // Bo tròn góc trên bên trái
                topRight: Radius.circular(15), // Bo tròn góc trên bên phải
              ),
            ),
            child: Column(
              children: [

                GestureDetector(
                  onTap: () {
                    // Open time filter sheet again
                    showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => ShowTimeFilter(station: widget.station,)
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(14, 5, 14, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          spacing: 10,
                          children: [
                            SvgPicture.asset('lib/assets/images/icons/time-fillter.svg'),
                            Text('Time Filter',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF00B150)
                              ),
                            )
                          ],
                        ),
                        SvgPicture.asset('lib/assets/images/icons/arrow-up.svg',width: 20,height: 20,)
                      ],
                    ),
                  ),
                ),


                SizedBox(height: 10,),
                Align(
                  alignment: Alignment(0, 1.10),
                  child: ElevatedButton(
                    onPressed: () {
                      // Logic cho khi nút Next được nhấn

                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => CheckoutScreen(
                      //       selectedSpots: selectedSpots.isNotEmpty ? selectedSpots : [],
                      //         spots: widget.spots,
                      //         availableSlots: widget.availableSlots,
                      //         durationMinutes: widget.durationMinutes,
                      //     ),
                      //   ),
                      // );

                      createOrder();
                    },
                    style: ElevatedButton.styleFrom(

                      backgroundColor: Color(0xFF00B150), // Màu nền cho nút
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Bo tròn nút
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 170, vertical: 8), // Padding cho nút
                    ),
                    child: isLoading ?
                    LoadingAnimationWidget.beat(
                        color: Colors.white, size: 30) :
                    Text(
                      "Next",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white, // Màu chữ của nút
                      ),
                    ),
                  ),
                ),
              ],
            )
          ),
      )

    );
  }
}
