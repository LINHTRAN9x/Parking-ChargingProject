
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:parking_project/root_page.dart';
import 'package:parking_project/screen/checkout/checkout_screen.dart';
import 'package:parking_project/screen/home/ui/sparkparking_station.dart';
import 'package:intl/intl.dart';

class ParkingDetails extends StatefulWidget {

  final Map<String, dynamic> spot; // Accept spot data
  final String parkingLotName;

  // Constructor to accept the spot data
  const ParkingDetails({Key? key, required this.spot,required this.parkingLotName}) : super(key: key);
  @override
  _StateParkingDetails createState() => _StateParkingDetails();
}
class _StateParkingDetails extends State<ParkingDetails>{
  DateTime selectedDate = DateTime.now();

  TimeOfDay? selectedTime; // Lưu giờ được chọn
  DateTime spinnerTime = DateTime.now(); // Lưu giờ được chọn
  Map<String, dynamic>? selectedDuration;
  List<Map<String, dynamic>> spacetimeList = [];
  Map<String, dynamic>? selectedSpacetime;

  final int daysToShow = 30;

  final List<TimeOfDay> availableTimes = [
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 11, minute: 0),
    TimeOfDay(hour: 12, minute: 0),
  ];


  final List<Map<String, dynamic>> availableTimeDuration = [
    {
      'id': 1,
      'duration': 'Under 1 Hour',
      'spacetime': [
        {'time': '30', 'type': 'min'},
        {'time': '40', 'type': 'min'},
        {'time': '50', 'type': 'min'},
      ],
    },
    {
      'id': 2,
      'duration': '1-2 Hours',
      'spacetime': [
        {'time': '1', 'type': 'hour'},
        {'time': '1', 'type': '10 min'},
        {'time': '1', 'type': '20 min'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    var spot = widget.spot;
    var parkingLotName = widget.parkingLotName;


    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 47, 20, 0),
                child: Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 12),
                    child:
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   PageRouteBuilder(
                            //     pageBuilder: (context, animation, secondaryAnimation) => const SparkparkingStation(),
                            //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            //       const begin = Offset(-1.0, 0.0);
                            //       const end = Offset.zero;
                            //       const curve = Curves.easeInOut;
                            //
                            //       var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            //       var offsetAnimation = animation.drive(tween);
                            //
                            //       return SlideTransition(
                            //         position: offsetAnimation,
                            //         child: child,
                            //       );
                            //     },
                            //   ),
                            // );
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
                          child: Text(
                            "Select parking detail " + spot['spotName'] + parkingLotName ,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),



                      ],
                    ),

                ),


              ),
              const SizedBox(height: 12),
              //view chon ngay tinh tu thoi diem hien tai
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Container(
                      height: 80,

                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: daysToShow,
                        itemBuilder: (context, index) {
                          DateTime date = DateTime.now().add(Duration(days: index));
                          bool isSelected = date.day == selectedDate.day &&
                              date.month == selectedDate.month &&
                              date.year == selectedDate.year;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDate = date;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              padding: EdgeInsets.fromLTRB(20,0,20,0),
                              decoration: BoxDecoration(
                                color: isSelected ? Color(0xFF00B150) : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                // border: Border.all(
                                //   color: isSelected ? Colors.green : Colors.grey,
                                // ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('dd').format(date),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,

                                      color: isSelected ? Colors.white : Color(0xFF9A9A9A),
                                    ),
                                  ),
                                  Text(
                                    index == 0 ? "Today" : DateFormat('EEE').format(date),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isSelected ? Colors.white : Colors.grey,
                                    ),
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
              ),
              const SizedBox(height: 12),
              //View chon time
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
                        children: availableTimes.map((time) {
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
                          child: TimePickerSpinner(
                            alignment: Alignment.center,
                            is24HourMode: true,
                            normalTextStyle: TextStyle(fontSize: 18, color: Colors.grey),
                            highlightedTextStyle: TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,

                            ),
                            spacing: 20,
                            itemHeight: 80,
                            isForce2Digits: true,
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
              //view chon parking duration
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
                        height: 80,
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


                    ]
                )
              ),



      ]),

    ),

    ),
      bottomNavigationBar: Container(
        height: 106,
        padding: EdgeInsets.all(10),
         // Màu nền cho container
        decoration: BoxDecoration(
        color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Màu bóng mờ
              offset: Offset(0, 1), // Vị trí bóng
              blurRadius: 6, // Độ mờ của bóng
            )
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15), // Bo tròn góc trên bên trái
            topRight: Radius.circular(15), // Bo tròn góc trên bên phải
          ),
        ),
        child: Align(
          alignment: Alignment(0, -0.7),
          child: ElevatedButton(
            onPressed: () {
              // Logic cho khi nút Next được nhấn
              print("Next button pressed");
              //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const CheckoutScreen()));
            },
            style: ElevatedButton.styleFrom(

              backgroundColor: Color(0xFF00B150), // Màu nền cho nút
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Bo tròn nút
              ),
              padding: EdgeInsets.symmetric(horizontal: 170, vertical: 8), // Padding cho nút
            ),
            child: Text(
              "Next",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white, // Màu chữ của nút
              ),
            ),
          ),
        ),
      ),


    );
  }
}