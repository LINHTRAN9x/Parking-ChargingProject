
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowExtend extends StatefulWidget {
  final String id;
  final List<Map<String, dynamic>> tickets;
  const ShowExtend({super.key, required this.id, required this.tickets});

  @override
  _StateShowExtend createState() => _StateShowExtend();
}
class _StateShowExtend extends State<ShowExtend>{
  final DraggableScrollableController _controller = DraggableScrollableController();
  var bookingData;
  bool isLoading = false;

  late List<Map<String, dynamic>> ticketsWithStatus;

  Map<String, String> selectedDuration = {'duration': '30', 'type': 'min'};
  String formatPrice(double price) {
    final formatter = NumberFormat("#,###", "vi_VN");
    return "${formatter.format(price)} đ";
  }

  List<Map<String, dynamic>> zones = [
    {"id": "A1", "name": "Zone A - A1", "selected": false, "selectedDuration": {"duration": "30", "type": "min"}},
    {"id": "B1", "name": "Zone B - B1", "selected": false, "selectedDuration": {"duration": "30", "type": "min"}},
    {"id": "C1", "name": "Zone C - C1", "selected": false, "selectedDuration": {"duration": "30", "type": "min"}},
    {"id": "D1", "name": "Zone D - D1", "selected": false, "selectedDuration": {"duration": "30", "type": "min"}},
    {"id": "E1", "name": "Zone E - E1", "selected": false, "selectedDuration": {"duration": "30", "type": "min"}},
  ];


  int selectedTime = 30;
  int selectedZoneIndex = 0;
  final List<Map<String, dynamic>> availableTimeDuration = [
    {
      'id': 1,
      'duration': '30',
      "type": 'min'
    },
    {
      'id': 2,
      'duration': '1',
      'type': 'hour'
    },
    {
      'id': 3,
      'duration': '2',
      'type': 'hour'
    },
  ];
  late String bookingId;

  @override
  void initState() {
    super.initState();
    bookingId = widget.id;
    setState(() {

    });
    ticketsWithStatus = widget.tickets.map((ticket) {
      return {
        ...ticket,
        'selected': false,
        'selectedDuration': {
          'duration': '30',
          'type': 'min',
        }
      };
    }).toList();
  }

  Future<void> sendExtend(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    setState(() {
      isLoading = true;
    });
    try {
      final now = DateTime.now();
      final List<Map<String, dynamic>> payload = ticketsWithStatus
          .where((ticket) => ticket['selected'] == true)
          .map((ticket) {
        final duration = int.parse(ticket['selectedDuration']['duration']);
        final type = ticket['selectedDuration']['type'];

        DateTime utcEndTime = DateTime.parse(ticket['endDateTime']);
        DateTime currentEndTime = utcEndTime.toLocal();
        print("endDateTimee $currentEndTime");

        DateTime newEndTime;
        if (type == 'hour') {
          newEndTime = currentEndTime.add(Duration(hours: duration));
        } else {
          newEndTime = currentEndTime.add(Duration(minutes: duration));
        }
        String formattedEndTime = newEndTime.toIso8601String().split('.').first + "+07:00";

        return {
          'ticketId': ticket['id'],
          'proposedEndDateTime': formattedEndTime
        };
      }).toList();
      print("jsonend"+jsonEncode(payload));
      final response = await Dio().patch(
        "http://18.182.12.54:8082/app-data-service/tickets/extend-booking/$bookingId",
        data: payload,
        options: Options(
          headers: {"Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      print("Extend successful: ${response.statusCode}");
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "Extend request had sent! Please wait",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      print("Error extending tickets: $e");
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    var currentSelected = zones[selectedZoneIndex]['selectedDuration'];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.transparent,
          child: DraggableScrollableSheet(
              controller: _controller,
              initialChildSize: 0.8, // Bắt đầu ở 70% chiều cao
              minChildSize: 0.4, // Kích thước nhỏ nhất khi vuốt xuống
              maxChildSize: 0.94,
              builder: (context, scrollController) {
                return
                  ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                  decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16), // Bo tròn góc trên bên trái
                    topRight: Radius.circular(16), // Bo tròn góc trên bên phải
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.blueAccent,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                      ),
                      ),
                    Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Select a spot",
                                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: 20),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.4,
                                    child: // Trong build() — thay phần ListView hiện tại:
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.6,
                                      child: ListView.builder(
                                        controller: scrollController,
                                        itemCount: widget.tickets.length,
                                        itemBuilder: (context, index) {
                                          final ticket = widget.tickets[index];
                                          var isExpanded = ticketsWithStatus[index]['selected'];
                                          var selectedDuration = ticketsWithStatus[index]['selectedDuration'];
                                          final slot = ticket['slot'];
                                          print("slott $slot");

                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Title zone (tap để expand/collapse)
                                              ListTile(
                                                title: Text("${slot['zone'] != null ? 'Zone ${slot['zone']}' : 'Gate ${slot['gate']}'} - ${slot['slotNumber']}"),
                                                trailing: Icon(
                                                  isExpanded ? Icons.expand_less : Icons.expand_more,
                                                  color: Colors.grey,
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    ticketsWithStatus[index]['selected'] = !isExpanded;
                                                  });
                                                },
                                              ),
                                              // Nếu được expand thì show thời gian
                                              if (isExpanded)
                                                Container(
                                                  height: 90,
                                                  margin: EdgeInsets.only(left: 16),
                                                  child: ListView.builder(
                                                    scrollDirection: Axis.horizontal,
                                                    itemCount: availableTimeDuration.length,
                                                    itemBuilder: (context, timeIndex) {
                                                      var time = availableTimeDuration[timeIndex];
                                                      bool isTimeSelected =
                                                          time['duration'] == selectedDuration['duration'] &&
                                                              time['type'] == selectedDuration['type'];

                                                      return GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            ticketsWithStatus[index]['selectedDuration'] = {
                                                              'duration': time['duration'],
                                                              'type': time['type'],
                                                            };
                                                          });
                                                        },
                                                        child: Container(
                                                          margin: EdgeInsets.symmetric(horizontal: 8),
                                                          padding: EdgeInsets.symmetric(horizontal: 16),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(8),
                                                            boxShadow: isTimeSelected
                                                                ? [
                                                              BoxShadow(
                                                                color: Colors.grey.withOpacity(0.3),
                                                                offset: Offset(4, 0),
                                                                blurRadius: 10,
                                                              )
                                                            ]
                                                                : [],
                                                          ),
                                                          child: Column(

                                                            children: [
                                                              SvgPicture.asset(
                                                                isTimeSelected
                                                                    ? "lib/assets/images/icons/arrow-down.svg"
                                                                    : "lib/assets/images/icons/radio-check-2.svg",
                                                                width: 24,
                                                                height: 24,
                                                              ),
                                                              SizedBox(
                                                                height: 60,
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Text(
                                                                      time['duration'],
                                                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                                                    ),
                                                                    SizedBox(height: 4),
                                                                    Text(
                                                                      time['type'],
                                                                      style: TextStyle(fontSize: 15, color: Colors.grey),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              const Divider(),
                                            ],
                                          );
                                        },
                                      ),
                                    ),



                                  ),
                                  //CONTENT
                                  // Padding(
                                  //     padding: const EdgeInsets.all(0.0),
                                  //     child:
                                  //     Column(
                                  //         crossAxisAlignment: CrossAxisAlignment.start,
                                  //         children: [
                                  //           Align(
                                  //             alignment: Alignment.topLeft,
                                  //             child: Padding(
                                  //               padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                                  //               child: Text(
                                  //                 "Select duration extend (max 2 hours)",
                                  //                 style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                                  //               ),
                                  //             ),
                                  //           ),
                                  //
                                  //           SizedBox(height: 20),
                                  //           //chon seleted duration se cap nhat lai list spacetime
                                  //           const SizedBox(height: 22),
                                  //           Container(
                                  //             height: 90,
                                  //             child: ListView.builder(
                                  //               scrollDirection: Axis.horizontal,
                                  //               itemCount: availableTimeDuration.length,
                                  //               itemBuilder: (context, index) {
                                  //                 var time = availableTimeDuration[index];
                                  //                 bool isSelected = time['duration'] == currentSelected['duration'] &&
                                  //                     time['type'] == currentSelected['type'];
                                  //
                                  //                 return GestureDetector(
                                  //                   onTap: () {
                                  //                     setState(() {
                                  //                       zones[selectedZoneIndex]['selectedDuration'] = {
                                  //                         'duration': time['duration'],
                                  //                         'type': time['type']
                                  //                       };
                                  //                     });
                                  //                   },
                                  //                   child: Container(
                                  //                     margin: EdgeInsets.symmetric(horizontal: 8),
                                  //                     padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  //                     decoration: BoxDecoration(
                                  //                       color: Colors.white,
                                  //                       borderRadius: BorderRadius.circular(8),
                                  //                       boxShadow: isSelected
                                  //                           ? [
                                  //                         BoxShadow(
                                  //                           color: Colors.grey.withOpacity(0.3),
                                  //                           offset: Offset(4, 0),
                                  //                           blurRadius: 10,
                                  //                         )
                                  //                       ]
                                  //                           : [],
                                  //                     ),
                                  //                     child: Column(
                                  //                       children: [
                                  //                         SvgPicture.asset(
                                  //                           isSelected
                                  //                               ? "lib/assets/images/icons/arrow-down.svg"
                                  //                               : "lib/assets/images/icons/radio-check-2.svg",
                                  //                           width: 24,
                                  //                           height: 24,
                                  //                         ),
                                  //                         SizedBox(
                                  //                           height: 60,
                                  //                           child: Column(
                                  //                             mainAxisAlignment: MainAxisAlignment.center,
                                  //                             children: [
                                  //                               Text(
                                  //                                 time['duration'],
                                  //                                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                  //                               ),
                                  //                               SizedBox(height: 4),
                                  //                               Text(
                                  //                                 time['type'],
                                  //                                 style: TextStyle(fontSize: 15, color: Colors.grey),
                                  //                               ),
                                  //                             ],
                                  //                           ),
                                  //                         ),
                                  //                       ],
                                  //                     ),
                                  //                   ),
                                  //                 );
                                  //               },
                                  //             ),
                                  //           ),
                                  //           const SizedBox(height: 22),
                                  //           Padding(
                                  //
                                  //             padding: EdgeInsets.all(10),
                                  //             // Màu nền cho container
                                  //
                                  //             child: Align(
                                  //               alignment: Alignment(0, -0.7),
                                  //               child: ElevatedButton(
                                  //                 onPressed: () {
                                  //                   // Logic cho khi nút Next được nhấn
                                  //                   sendExtend();
                                  //                   // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const SparkparkingStation()));
                                  //                 },
                                  //                 style: ElevatedButton.styleFrom(
                                  //
                                  //                   backgroundColor: Color(0xFF00B150), // Màu nền cho nút
                                  //                   shape: RoundedRectangleBorder(
                                  //                     borderRadius: BorderRadius.circular(30), // Bo tròn nút
                                  //                   ),
                                  //                   padding: EdgeInsets.symmetric(horizontal: 145, vertical: 8), // Padding cho nút
                                  //                 ),
                                  //                 child: Text(
                                  //                   "Request",
                                  //                   style: TextStyle(
                                  //                     fontSize: 18,
                                  //                     color: Colors.white, // Màu chữ của nút
                                  //                   ),
                                  //                 ),
                                  //               ),
                                  //             ),
                                  //           ),
                                  //
                                  //
                                  //         ]
                                  //     )
                                  // ),



                                ],
                              ),
                            )
                        ],
                        ),
                    )
                    ],
                )
                  )
                );
              }
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
            height: 100,
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
                topLeft: Radius.circular(0), // Bo tròn góc trên bên trái
                topRight: Radius.circular(0), // Bo tròn góc trên bên phải
              ),
            ),
            child: Column(
              children: [




                SizedBox(height: 10,),
                Align(
                  alignment: Alignment(0, 1.10),
                  child: ElevatedButton(
                    onPressed: () {
                      // Logic cho khi nút Next được nhấn
                      sendExtend(context);
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


                    },
                    style: ElevatedButton.styleFrom(

                      backgroundColor: Color(0xFF00B150), // Màu nền cho nút
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Bo tròn nút
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 160, vertical: 8), // Padding cho nút
                    ),
                    child: isLoading ?
                    LoadingAnimationWidget.beat(
                        color: Colors.white, size: 30) :
                    Text(
                      "Request",
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
      ),
    );
  }


}
