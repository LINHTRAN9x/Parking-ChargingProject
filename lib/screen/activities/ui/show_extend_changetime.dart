
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parking_project/screen/activities/ui/extend_payment_time.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'extend_payment.dart';

class ShowExtendChangetime extends StatefulWidget {
  final String id;
  final List<Map<String, dynamic>> tickets;
  const ShowExtendChangetime({super.key, required this.id, required this.tickets});

  @override
  _StateShowExtend createState() => _StateShowExtend();
}
class _StateShowExtend extends State<ShowExtendChangetime>{
  final DraggableScrollableController _controller = DraggableScrollableController();
  var bookingData;
  bool isLoading = false;
  late String id;
  Map<String, Map<String, dynamic>> selectedSlots = {};
  double ticketPrice = 0.0;
  DateTime spinnerTime = DateTime.now().add(Duration(minutes: 10));
  TimeOfDay? selectedTime;
  bool isTimeChecked = false;
  var bookingInfo;


  List<Map<String, dynamic>> generateNewTimeRanges(DateTime startDateTime, DateTime endDateTime, int numberOfSlots, double price) {
    final duration = endDateTime.difference(startDateTime);
    final List<Map<String, dynamic>> slots = [];

    DateTime currentStart = endDateTime.toLocal();
    print("currentStart $currentStart");

    for (int i = 0; i < numberOfSlots; i++) {
      final currentEnd = currentStart.add(duration);
      print("currentEnd $currentEnd");

      // Thêm slot vào danh sách
      slots.add({
        'newStartTime': currentStart,
        'newEndTime': currentEnd,
        'price': price
      });

      currentStart = currentEnd;
    }

    print("slotss: $slots");
    return slots;
  }





  String formatTime(DateTime? dt) {
    if (dt == null) return "Chưa chọn";
    return DateFormat("HH:mm").format(dt);
  }

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
    print('BookingID1 $bookingId');
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

  Future<void> sendChangeTime() async {
    print("==> Starting sendChangeTime");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    setState(() {
      isLoading = true;
    });

    String formatToLocalISO(DateTime dt) {
      final local = dt.toLocal();
      final offset = local.timeZoneOffset;
      final hours = offset.inHours.abs().toString().padLeft(2, '0');
      final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
      final sign = offset.isNegative ? '-' : '+';
      return '${local.toIso8601String().split('.').first}$sign$hours:$minutes';
    }

    try {
      print("Selected slots: $selectedSlots");

      final requestBody = selectedSlots.values.map((slot) {
        final rawStart = slot['newStartTime'];
        final rawEnd = slot['newEndTime'];

        if (rawStart == null || rawEnd == null) {
          print("❌ Slot thiếu thời gian: $slot");
          throw Exception("Slot thiếu thời gian");
        }

        final start = rawStart is String ? DateTime.parse(rawStart) : rawStart;
        final end = rawEnd is String ? DateTime.parse(rawEnd) : rawEnd;

        return {
          'ticketId': slot['ticketId'],
          'proposedStartDateTime': formatToLocalISO(start),
          'proposedEndDateTime': formatToLocalISO(end),
        };
      }).toList();


      print("Request body: $requestBody");

      final rs = await Dio().post(
        "http://18.182.12.54:8082/app-data-service/tickets/booking-change-time/$bookingId",
        data: requestBody,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      print("✅ Change time success: ${rs.data}");

      Fluttertoast.showToast(
        msg: "Change time had send! Please wait",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e, s) {
      print("Error changetime tickets: $e");
      print("Stacktrace: $s");

      Fluttertoast.showToast(
        msg: "Error change time ticket",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      
    } finally {
      setState(() {
        isLoading = false;
      });
      print("==> sendChangeTime DONE");
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
              minChildSize: 0.2, // Kích thước nhỏ nhất khi vuốt xuống
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
                                  width: MediaQuery.of(context).size.height * 0.08,
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
                                            "Select start time change",
                                            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
                                          ),
                                          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
                                                  double price = ticket['price'];
                                                  var selectedDuration = ticketsWithStatus[index]['selectedDuration'];
                                                  final slot = ticket['slot'];
                                                  final start = DateTime.parse(ticket['startDateTime']);
                                                  final end = DateTime.parse(ticket['endDateTime']);
                                                  final newSlots = generateNewTimeRanges(start, end, 8, price);
                                                  print("slott $slot");
                                                  print("start $start");
                                                  print("end $end");

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
                                                  height: MediaQuery.of(context).size.height * 0.23,
                                                  margin: EdgeInsets.only(left: 6),
                                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                  decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(8),
                                                  boxShadow: [
                                                  BoxShadow(
                                                  color: Colors.grey.withOpacity(0.3),
                                                  offset: Offset(4, 0),
                                                  blurRadius: 10,
                                                  )
                                                  ],
                                                  ),
                                                  child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                  SizedBox(height: 10),
                                                  TimePickerSpinner(
                                                  alignment: Alignment.center,
                                                  is24HourMode: true,
                                                  normalTextStyle: TextStyle(fontSize: 18, color: Colors.grey),
                                                  highlightedTextStyle: TextStyle(
                                                  fontSize: 25,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  ),
                                                  spacing: 20,
                                                  itemHeight: MediaQuery.of(context).size.height * 0.06,
                                                  minutesInterval: 10,
                                                  isForce2Digits: true,
                                                  time: spinnerTime,
                                                  onTimeChange: (time) {
                                                  setState(() async {
                                                  spinnerTime = time;

                                                  final ticketId = ticket['id'].toString();
                                                  final Duration duration = end.difference(start);
                                                  final DateTime startDateTimeSelected = DateTime(
                                                    spinnerTime.year,
                                                    spinnerTime.month,
                                                    spinnerTime.day,
                                                    spinnerTime.hour,
                                                    spinnerTime.minute,
                                                  );
                                                  final DateTime endDateTimeSelected = startDateTimeSelected.add(duration);
                                                  // Nếu đã có slot cũ => trừ giá cũ
                                                  if (selectedSlots.containsKey(ticketId)) {
                                                  final oldSlot = selectedSlots[ticketId];
                                                  final oldPrice = (oldSlot?['price'] ?? 0.0) / 2;
                                                  ticketPrice -= oldPrice;
                                                  }


                                                  selectedSlots[ticketId] = {
                                                    'ticketId': ticketId,
                                                    'newStartTime': startDateTimeSelected.toIso8601String(),
                                                    'newEndTime': endDateTimeSelected.toIso8601String(),

                                                  };



                                                  print("User selected start time: $time");
                                                  print("Updated selectedSlots: $selectedSlots");
                                                  });
                                                  },
                                                  ),
                                                  ],
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
            height: MediaQuery.of(context).size.height * 0.13,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total fee:',
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        decoration: TextDecoration.underline
                      ),
                    ),
                    Text(
                      "\$${ticketPrice}",
                      style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00B150)
                      ),
                    )
                  ],
                ),



                SizedBox(height: 10,),
                Align(
                  alignment: Alignment(0, 1.10),
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                      if (isTimeChecked) {
                        // Nút PAY -> chuyển trang
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExtendPaymentTime(
                                type: "TIME_CHANGE",
                                price: ticketPrice,
                                booking: bookingInfo),

                          ),
                        );
                      } else {
                        // Nút CHECK TIME

                        await sendChangeTime();
                        // tiếp tục gọi API get booking như bên trên
                        try {
                          final prefs = await SharedPreferences.getInstance();
                          final token = prefs.getString('access_token');

                          final response = await Dio().get(
                            "http://18.182.12.54:8082/app-data-service/bookings/with-tickets?type=&page=0&size=100&sort=updatedAt,desc&bookingId=$bookingId",
                            options: Options(
                              headers: {
                                "Content-Type": "application/json",
                                "Authorization": "Bearer $token",
                              },
                            ),
                          );

                          setState(() {
                            bookingInfo = response.data['content'][0]; // Đây là List
                            isTimeChecked = true;
                            isLoading = false;
                          });
                          print("bookingInfo $bookingInfo");
                          if (bookingInfo.isNotEmpty && bookingInfo['booking'] != null) {
                            setState(() {
                              ticketPrice = bookingInfo['booking']['totalTimeChangePrice'];
                            });
                            print("ticketPrice: $ticketPrice");
                          }
                          print("ticketPrice $ticketPrice");
                          Fluttertoast.showToast(
                            msg: "Checked successfully!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                          );
                        } catch (e) {
                          setState(() {
                            isTimeChecked = false;
                            isLoading = false;
                          });
                          Fluttertoast.showToast(
                            msg: "This time is conflict, please wait!",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                          print("Error fetching booking info: $e");
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isTimeChecked ? Colors.orange : Color(0xFF00B150),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: EdgeInsets.symmetric(horizontal: 140, vertical: 8),
                    ),
                    child: isLoading
                        ? LoadingAnimationWidget.beat(color: Colors.white, size: 30)
                        : Text(
                      isTimeChecked ? "Pay" : "Check time",
                      style: TextStyle(fontSize: 18, color: Colors.white),
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
