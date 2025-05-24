
import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parking_project/screen/home/ui/sparkparking_station.dart';

class ShowTimeFilter extends StatefulWidget{
  final Map<String, dynamic> station;
  const ShowTimeFilter({super.key, required this.station});

  @override
  _StateShowTimeFilter createState() => _StateShowTimeFilter();
}
class _StateShowTimeFilter extends State<ShowTimeFilter>{
  final DraggableScrollableController _controller = DraggableScrollableController();
  DateTime selectedDate = DateTime.now();

  TimeOfDay? selectedTime; // Lưu giờ được chọn
  DateTime spinnerTime = DateTime.now().add(Duration(minutes: 10)); // Lưu giờ được chọn
  Map<String, dynamic>? selectedDuration;
  List<Map<String, dynamic>> spacetimeList = [];
  Map<String, dynamic>? selectedSpacetime;
  late Map<String, dynamic> station;
  List<Map<String, dynamic>> spots = [];
  List<String> availableSlots = [];
  List<String> unavailableSlots = [];
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    station = widget.station;

    getSpots();

  }

  final int daysToShow = 30;

  final List<TimeOfDay> availableTimes = [
    for (int i = 1; i < 24; i++) TimeOfDay(hour: i, minute: 0),
  ];
  List<TimeOfDay> getAvailableTimes() {
    DateTime now = DateTime.now();
    return availableTimes.where((time) {
      DateTime selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      return selectedDateTime.isAfter(now); // Chỉ giữ lại giờ trong tương lai
    }).toList();
  }




  final List<Map<String, dynamic>> availableTimeDuration = [
    {
      'id': 1,
      'duration': 'Under 1 hour',
      'spacetime': [
        {'time': '30', 'type': 'min'},
        {'time': '40', 'type': 'min'},
        {'time': '50', 'type': 'min'},
      ],
    },
    {
      'id': 2,
      'duration': '1-2 hour',
      'spacetime': [
        {'time': '1', 'type': 'hour'},
        {'time': '1', 'type': '10 min'},
        {'time': '1', 'type': '20 min'},
        {'time': '1', 'type': '30 min'},
        {'time': '1', 'type': '40 min'},
        {'time': '1', 'type': '50 min'},
        {'time': '2', 'type': 'hour'},
      ],
    },
    {
      'id': 3,
      'duration': '2-3 hour',
      'spacetime': [
        {'time': '2', 'type': '10 min'},
        {'time': '2', 'type': '20 min'},
        {'time': '2', 'type': '30 min'},
        {'time': '2', 'type': '40 min'},
        {'time': '2', 'type': '50 min'},
        {'time': '3', 'type': 'hour'},
      ],
    },
    {
      'id': 4,
      'duration': '3-4 hour',
      'spacetime': [
        {'time': '3', 'type': '10 min'},
        {'time': '3', 'type': '20 min'},
        {'time': '3', 'type': '30 min'},
        {'time': '3', 'type': '40 min'},
        {'time': '3', 'type': '50 min'},
        {'time': '4', 'type': 'hour'},
      ],
    },
    {
      'id': 5,
      'duration': '4-5 hour',
      'spacetime': [
        {'time': '4', 'type': '10 min'},
        {'time': '4', 'type': '20 min'},
        {'time': '4', 'type': '30 min'},
        {'time': '4', 'type': '40 min'},
        {'time': '4', 'type': '50 min'},
        {'time': '5', 'type': 'hour'},
      ],
    },
    {
      'id': 6,
      'duration': '5-6 hour',
      'spacetime': [
        {'time': '5', 'type': '10 min'},
        {'time': '5', 'type': '20 min'},
        {'time': '5', 'type': '30 min'},
        {'time': '5', 'type': '40 min'},
        {'time': '5', 'type': '50 min'},
        {'time': '6', 'type': 'hour'},
      ],
    },
    {
      'id': 6,
      'duration': '6-7 hour',
      'spacetime': [
        {'time': '6', 'type': '10 min'},
        {'time': '6', 'type': '20 min'},
        {'time': '6', 'type': '30 min'},
        {'time': '6', 'type': '40 min'},
        {'time': '6', 'type': '50 min'},
        {'time': '7', 'type': 'hour'},
      ],
    },
    {
      'id': 7,
      'duration': '7-8 hour',
      'spacetime': [
        {'time': '7', 'type': '10 min'},
        {'time': '7', 'type': '20 min'},
        {'time': '7', 'type': '30 min'},
        {'time': '7', 'type': '40 min'},
        {'time': '7', 'type': '50 min'},
        {'time': '8', 'type': 'hour'},
      ],
    },
    {
      'id': 8,
      'duration': '8-9 hour',
      'spacetime': [
        {'time': '8', 'type': '10 min'},
        {'time': '8', 'type': '20 min'},
        {'time': '8', 'type': '30 min'},
        {'time': '8', 'type': '40 min'},
        {'time': '8', 'type': '50 min'},
        {'time': '9', 'type': 'hour'},
      ],
    },
    {
      'id': 9,
      'duration': '9-10 hour',
      'spacetime': [
        {'time': '9', 'type': '10 min'},
        {'time': '9', 'type': '20 min'},
        {'time': '9', 'type': '30 min'},
        {'time': '9', 'type': '40 min'},
        {'time': '9', 'type': '50 min'},
        {'time': '10', 'type': 'hour'},
      ],
    },
  ];
  String formatDateTimeWithOffset(DateTime dateTime) {
    final String formatted = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(dateTime.toLocal());
    return "$formatted+07:00"; // Thêm offset đúng định dạng
  }

  Future<void> findSlot() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    setState(() {
      isLoading = true;
    });

    if (selectedTime == null || selectedSpacetime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a start time and duration")),
      );
      return;
    }

    final id = station['id'].toString();
    final List<String> types = List<String>.from(station['services'] ?? []);
    if (types.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No service type available for this station")),
      );
      return;
    }

    final startDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    int durationMinutes = 0;
    if (selectedSpacetime!['type'] == 'min') {
      durationMinutes = int.parse(selectedSpacetime!['time']);
    } else if (selectedSpacetime!['type'] == 'hour') {
      durationMinutes = int.parse(selectedSpacetime!['time']) * 60;
    } else if (selectedSpacetime!['type'].contains('min')) {
      final parts = selectedSpacetime!['type'].split(' ');
      durationMinutes = int.parse(selectedSpacetime!['time']) * 60 + int.parse(parts[0]);
    }

    final endDateTime = startDateTime.add(Duration(minutes: durationMinutes));
    final String formattedStart = formatDateTimeWithOffset(startDateTime);
    final String formattedEnd = formatDateTimeWithOffset(endDateTime);

    List<String> allAvailableSlots = [];
    List<String> allUnavailableSlots = [];

    try {
      List<Future<Response>> validRequests = types.map((type) {
        String url =
            "http://18.182.12.54:8082/app-data-service/slots/valid-by-type"
            "?locationId=$id"
            "&serviceType=$type"
            "&start=${Uri.encodeComponent(formattedStart)}"
            "&end=${Uri.encodeComponent(formattedEnd)}";

        print("Requesting valid slots: $url");
        return Dio().get(
          url,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          }),
        );
      }).toList();

      List<Future<Response>> invalidRequests = types.map((type) {
        String url =
            "http://18.182.12.54:8082/app-data-service/slots/invalid-by-type"
            "?locationId=$id"
            "&serviceType=$type"
            "&start=${Uri.encodeComponent(formattedStart)}"
            "&end=${Uri.encodeComponent(formattedEnd)}";

        print("Requesting invalid slots: $url");
        return Dio().get(
          url,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          }),
        );
      }).toList();

      List<Response> invalidResponses = await Future.wait(invalidRequests);
      List<Response> validResponses = await Future.wait(validRequests);

      for (var response in validResponses) {
        if (response.statusCode == 200 && response.data is List) {
          allAvailableSlots.addAll(
              (response.data as List).map((item) => item['slotNumber'] as String)
          );
        } else {
          print("Valid slots API Error: ${response.statusCode}, ${response.data}");
        }
      }

      for (var response in invalidResponses) {
        if (response.statusCode == 200 && response.data is List) {
          allUnavailableSlots.addAll(
              (response.data as List).map((item) => item['slotNumber'] as String)
          );
        } else {
          print("Invalid slots API Error: ${response.statusCode}, ${response.data}");
        }
      }


      setState(() {
        availableSlots = allAvailableSlots.toSet().toList();
        unavailableSlots = allUnavailableSlots.toSet().toList();
        print("Available Slots: $availableSlots");
        print("Unavailable Slots: $unavailableSlots");
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SparkparkingStation(
            spots: spots,
            availableSlots: availableSlots,
            unavailableSlots: unavailableSlots,
            durationMinutes: durationMinutes,
            dateStart: formattedStart,
            dateEnd: formattedEnd,
            station: station,
          ),
        ),
      );
    } catch (e) {
      print("API error: $e");
      Fluttertoast.showToast(
        msg: "Not found at this time slot",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      if (e is DioException) {
        print("Response data: ${e.response?.data}");
      }
    }finally {
      setState(() {
        isLoading = false;
      });
    }
  }






  Future<void> getSpots() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    final id = station['id'].toString();
    final Dio dio = Dio();

    try {
      // Gọi cả hai API song song với URL mới
      List<Future<Response>> requests = [
        dio.get("http://18.182.12.54:8082/app-data-service/slots/find-pageable-slots?type=PARKING&status=VALID&page=0&size=1000&locationId=$id",
            options: Options(headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            })),
        dio.get("http://18.182.12.54:8082/app-data-service/slots/find-pageable-slots?type=CHARGING&status=VALID&page=0&size=1000&locationId=$id",
            options: Options(headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            })),
      ];

      List<Response> responses = await Future.wait(requests);


      // Khởi tạo danh sách bãi đỗ và trạm sạc
      List<Map<String, dynamic>> parkingSpots = [];
      List<Map<String, dynamic>> chargingSpots = [];

      // Xử lý dữ liệu từ API parking slots
      if (responses[0].statusCode == 200 && responses[0].data != null) {
        var data = responses[0].data;
        if (data is Map<String, dynamic> && data.containsKey('content') && data['content'] is List) {
          parkingSpots = List<Map<String, dynamic>>.from(data['content']);
        } else {
          print("Parking Slots API returned unexpected format: $data");
        }
      } else {
        print("Parking Slots API Error: ${responses[0].statusCode}, ${responses[0].data}");
      }

      // Xử lý dữ liệu từ API charging slots
      if (responses[1].statusCode == 200 && responses[1].data != null) {
        var data = responses[1].data;
        if (data is Map<String, dynamic> && data.containsKey('content') && data['content'] is List) {
          chargingSpots = List<Map<String, dynamic>>.from(data['content']);
        } else {
          print("Charging Slots API returned unexpected format: $data");
        }
      } else {
        print("Charging Slots API Error: ${responses[1].statusCode}, ${responses[1].data}");
      }

      // Cập nhật state
      setState(() {
        spots = [...parkingSpots, ...chargingSpots]; // Gộp cả hai danh sách
        print("spots $spots");
      });

    } catch (e) {
      print("API Request Failed: $e");
    }
  }




  @override
  Widget build(BuildContext context) {
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
            maxChildSize: 0.94, // Kích thước lớn nhất khi vuốt lên
            builder: (context, scrollController) {
              return ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                          width: MediaQuery.of(context).size.width * 0.04,
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
                                      "Select starting time",
                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                                    ),
                                    SizedBox(height: 20),
                                    // Danh sách các ô giờ
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: getAvailableTimes().map((time) {
                                          bool isSelected = time == selectedTime;
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedTime = time;
                                                spinnerTime = DateTime(
                                                  selectedDate.year,
                                                  selectedDate.month,
                                                  selectedDate.day,
                                                  time.hour,
                                                  time.minute,
                                                );
                                              });
                                            },
                                            child: Container(
                                              margin: EdgeInsets.symmetric(horizontal: 8),
                                              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                              decoration: BoxDecoration(
                                                color: isSelected ? Color(0xFF00B150) : Colors.white,
                                                border: Border.all(
                                                  color: isSelected ? Color(0xFF00B150) : Colors.grey,
                                                ),
                                                borderRadius: BorderRadius.circular(50),
                                              ),
                                              child: Text(
                                                "${time.format(context)}",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: isSelected ? Colors.white : Colors.black,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),

                                    //Time spinner
                                    SizedBox(height: 20),
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(0.0),  // Thêm padding cho toàn bộ container
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,  // Màu nền cho container
                                            borderRadius: BorderRadius.circular(12),  // Viền bo tròn
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.2),
                                                spreadRadius: 3,
                                                blurRadius: 5,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child:
                                          TimePickerSpinner(
                                            alignment: Alignment.center,
                                            key: ValueKey(spinnerTime),
                                            is24HourMode: true,
                                            normalTextStyle: TextStyle(fontSize: 18, color: Colors.grey),
                                            highlightedTextStyle: TextStyle(
                                              fontSize: 25,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,

                                            ),
                                            spacing: 20,
                                            itemHeight: MediaQuery.of(context).size.height * 0.09,
                                            minutesInterval: 10,
                                            isForce2Digits: true,
                                            time: spinnerTime,
                                            onTimeChange: (time) {
                                              setState(() {
                                                spinnerTime = time;
                                                selectedTime = TimeOfDay(
                                                  hour: time.hour,
                                                  minute: time.minute,
                                                ); // Đồng bộ
                                              });
                                            },

                                          ),
                                        ),
                                      ),
                                    )

                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                                            child: Text(
                                              "Select parking duration (max 10 hours)",
                                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ),

                                        SizedBox(height: 20),
                                        SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                                              child: Row(
                                                children: availableTimeDuration.map((time) {
                                                  bool isSelected = time == selectedDuration;
                                                  return GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedDuration = time;
                                                        spacetimeList = time['spacetime'];
                                                      });
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.symmetric(horizontal: 8),
                                                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                                      decoration: BoxDecoration(
                                                        color: isSelected ? Color(0xFF00B150) : Colors.white,
                                                        border: Border.all(
                                                          color: isSelected ? Color(0xFF00B150) : Colors.grey,
                                                        ),
                                                        borderRadius: BorderRadius.circular(50),
                                                      ),
                                                      child: Text(
                                                        "${time['duration']}",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: isSelected ? Colors.white : Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            )

                                        ),
                                        //chon seleted duration se cap nhat lai list spacetime
                                        const SizedBox(height: 22),
                                        Container(
                                          height: MediaQuery.of(context).size.height * 0.10,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: spacetimeList.length,
                                            itemBuilder: (context, index) {
                                              var spacetime = spacetimeList[index];
                                              bool isSelected = spacetime == selectedSpacetime;

                                              return GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selectedSpacetime = spacetime;
                                                  });
                                                },
                                                child:
                                                Container(
                                                    margin: EdgeInsets.symmetric(horizontal: 8),
                                                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(8),
                                                      boxShadow: isSelected
                                                          ? [BoxShadow(
                                                        color: Colors.grey.withOpacity(0.3),
                                                        offset: Offset(4, 0),
                                                        blurRadius: 10,
                                                      )]
                                                          : [],
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        SvgPicture.asset(
                                                          isSelected ? "lib/assets/images/icons/arrow-down.svg" : "lib/assets/images/icons/radio-check-2.svg",
                                                          width: 24, // Thay đổi kích thước nếu cần
                                                          height: 24, // Thay đổi kích thước nếu cần
                                                        ),
                                                        Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              spacetime['time'],
                                                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                                            ),
                                                            Text(
                                                              spacetime['type'],
                                                              style: TextStyle(fontSize: 16, color: Colors.grey),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    )


                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 22),
                                        Padding(

                                          padding: EdgeInsets.all(10),
                                          // Màu nền cho container

                                          child: Align(
                                            alignment: Alignment(0, -0.7),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                // Logic cho khi nút Next được nhấn
                                                findSlot();
                                                // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const SparkparkingStation()));
                                              },
                                              style: ElevatedButton.styleFrom(

                                                backgroundColor: Color(0xFF00B150), // Màu nền cho nút
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(30), // Bo tròn nút
                                                ),
                                                padding: EdgeInsets.symmetric(horizontal: 150, vertical: 8), // Padding cho nút
                                              ),
                                              child: isLoading ?
                                              LoadingAnimationWidget.beat(
                                                  color: Colors.white, size: 30) :
                                              Text(
                                                "Find Slot",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white, // Màu chữ của nút
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),


                                      ]
                                  )
                              ),
                            ],
                          )
                      )
                    ],
                  ),
                ),
              );
            }
        ),
      )
      )


    );
  }
}