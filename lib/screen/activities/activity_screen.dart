
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:parking_project/screen/activities/ui/extend_checkout.dart';
import 'package:parking_project/screen/activities/ui/extend_payment.dart';
import 'package:parking_project/screen/activities/ui/order_details.dart';
import 'package:parking_project/screen/activities/ui/show_extend_changetime.dart';
import 'package:parking_project/screen/home/home_screen.dart';
import 'package:parking_project/screen/home/ui/category_screen.dart';
import 'package:parking_project/screen/notice/notice_screen.dart';
import 'package:parking_project/screen/profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../checkout/checkout_screen.dart';
import '../home/ui/show_extend.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  _StateActivityScreen createState() => _StateActivityScreen();
}
class _StateActivityScreen extends State<ActivityScreen> with AutomaticKeepAliveClientMixin{
  int selectedCategoryId = 1;
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  int page = 0;
  List<dynamic> bookingsData = [];
  List<dynamic> allBookingsData = [];
  ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  final List<Widget> screens = [
    HomeScreen(),
    ActivityScreen(),
    NoticeScreen(),
    ProfileScreen()
  ];
  int _selectedIndex = 0;
  changeScreen(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _getBookings({bool isLoadMore = false, bool forceRefresh = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Ngăn gọi tiếp nếu đang tải thêm hoặc không còn dữ liệu
    if (isLoadMore && (isLoadingMore || !hasMoreData)) return;

    // Kiểm tra cache nếu không tải thêm và không bắt buộc làm mới
    if (!isLoadMore && !forceRefresh) {
      String? cached = prefs.getString('cached_bookings');
      if (cached != null) {
        List<dynamic> localData = jsonDecode(cached);
        if (localData.isNotEmpty) {
          setState(() {
            bookingsData = localData;
            isLoading = false;
          });
          return;
        }
      }
    }

    // Cập nhật trạng thái loading phù hợp
    if (!isLoadMore) {
      setState(() => isLoading = true);
    } else {
      setState(() => isLoadingMore = true);
    }

    String? token = prefs.getString('access_token');
    if (token == null) {
      print("Token is missing, please log in.");
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      return;
    }

    // Xác định loại booking nếu có category
    String? bookingType;
    if (selectedCategoryId == 2) {
      bookingType = "PARKING";
    } else if (selectedCategoryId == 3) {
      bookingType = "CHARGING";
    }else if (selectedCategoryId == 1) {
      bookingType = "";
    }

    try {
      var rs = await Dio().get(
        "http://18.182.12.54:8082/app-data-service/bookings/with-tickets",
        queryParameters: {
          if (bookingType != null) "type": bookingType,
          "page": page,
          "size": 6,
          "sort": "updatedAt,desc",
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );
      var allBooking = await Dio().get(
        "http://18.182.12.54:8082/app-data-service/bookings/with-tickets",
        queryParameters: {
          if (bookingType != null) "type": bookingType,
          "page": page,
          "size": 1000,
          "sort": "updatedAt,desc",
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );


      List<dynamic> newBookings = rs.data['content'];
      List<dynamic> newAllBookings = allBooking.data['content'];

      newBookings.sort((a, b) {
        var aDate = DateTime.tryParse(a['updatedAt'] ?? '') ?? DateTime(1970);
        var bDate = DateTime.tryParse(b['updatedAt'] ?? '') ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });

      setState(() {
        if(_startDateTime != null && _endDateTime != null){
          bookingsData = newAllBookings;
          hasMoreData = false;
        } else if (isLoadMore) {
          bookingsData.addAll(newBookings);
          page++;
        } else {
          bookingsData = newBookings;
          page = 1;
        }

        // Lưu cache
        prefs.setString('cached_bookings', jsonEncode(bookingsData));
        prefs.setInt('bookings_last_updated', DateTime.now().millisecondsSinceEpoch);

        isLoading = false;
        isLoadingMore = false;
      });

      if (newBookings.length < 6) {
        setState(() {
          hasMoreData = false;
        });
      }

      print("Bookings: ${rs.data}");
      print("bookingsData $bookingsData");
    } catch (e) {
      print("Error fetching bookings: $e");
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });

      if (e is DioException) {
        print("Dio error: ${e.response?.statusCode}, ${e.response?.data}");
      }
    }
  }

  DateTime? _startDateTime;
  DateTime? _endDateTime;

  DateTime? _tempStartDateTime;
  DateTime? _tempEndDateTime;

  Future<void> _pickDateTime({required bool isStart}) async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );

      if (pickedTime != null) {
        DateTime combined = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isStart) {
            _tempStartDateTime = combined;
          } else {
            _tempEndDateTime = combined;
          }
        });
      }
    }
  }
  void _filterByDateTime() {
    print("_startDateTime $_startDateTime");
    print("_endDateTime $_endDateTime");
    if (_startDateTime == null || _endDateTime == null) {
      print("Chưa chọn thời gian lọc");
      return;
    }

    setState(() {
      bookingsData = bookingsData.where((bookingItem) {
        List<dynamic> tickets = bookingItem['tickets'] ?? [];

        return tickets.any((ticket) {
          String? createdAtStr = ticket['createdAt'];
          if (createdAtStr == null) return false;
          DateTime createdAt = DateTime.parse(createdAtStr);

          return createdAt.isAfter(_startDateTime!) &&
              createdAt.isBefore(_endDateTime!);
        });
      }).toList();
    });

    print("Đã lọc theo thời gian: $_startDateTime -> $_endDateTime");
  }




  String _formatDateTime(DateTime? dt) {
    if (dt == null) return "Chưa chọn";
    return DateFormat("dd-MM-yyyy HH:mm").format(dt);
  }

  @override
  void initState() {
    super.initState();
    _getBookings();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 && hasMoreData && !isLoadingMore) {
        print("LOAD MORE TRIGGERED");
        _getBookings(isLoadMore: true);
      }
    });

  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


  List<Map<String, dynamic>> categories = [
    {
      "id": 1,
      "name": "All Spots",
      "icon": "lib/assets/images/icons/all-spots.svg",
      "description": "View all available spots.",
    },
    {
      "id": 2,
      "name": "Parking Lot",
      "icon": "lib/assets/images/icons/parking-lot.svg",
      "description": "Find the nearest parking lot.",
    },
    {
      "id": 3,
      "name": "Charging Station",
      "icon": "lib/assets/images/icons/charging.svg",
      "description": "Locate charging stations for your vehicle.",
    },
  ];
  List<Map<String, dynamic>> orders = [
    {
      'date': '01/2025',
      'time': '17:55, 02/01',
      'status': 'Parking in Progress',
      'type': 1,
      'location': 'Maplewood Avenue 678, Ground Flewood Avenue 678, Ground Fl',

      'price' : '200\$',
      'statusColor': 'FF9800FF',
    },
    {
      'date': '01/2025',
      'time': '17:55, 02/01',
      'status': 'Completed',
      'location': '8502 Preston Rd. Inglewood, Maine...',
      'type': 2,
      'price' : '200\$',
      'statusColor': '4CAF50FF',
    },
    {
      'date': '01/2025',
      'time': '17:55, 02/01',
      'status': 'Cancel Order',
      'type': 1,
      'location': '2715 Ash Dr. San Jose, South Dakota...',

      'price' : '200\$',
      'statusColor': 'F44336FF',
    },
    {
      'date': '01/2025',
      'time': '17:55, 02/01',
      'status': 'Completed',
      'type': 1,
      'location': 'SparkParking Station',

      'price' : '200\$',
      'statusColor': 'FF9800FF',
    }
  ];

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body:
      isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF5CCD8F),)):
      SafeArea(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(16, 20, 20, 0),
                decoration: BoxDecoration(
                    color: Colors.white, // Màu nền
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1), // Màu bóng với độ trong suốt
                        spreadRadius: 2, // Bóng lan rộng
                        blurRadius: 10, // Độ mờ của bóng
                        offset: Offset(0, 10), // Dịch bóng theo trục x, y
                      ),
                    ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child:
                      Text(
                        "Activities",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.04, // Chiều cao tổng danh sách
                      child: ListView.builder(
                        shrinkWrap: false,
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected = selectedCategoryId == category["id"];
                          return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategoryId = category["id"]; // Cập nhật trạng thái
                                  page = 0;
                                  hasMoreData = true;
                                  bookingsData = []; // reset luôn nếu cần
                                  isLoading = true;
                                });

                                _getBookings(forceRefresh: true);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(

                                  border: Border.all(
                                    color: isSelected ? Color(0xFF00B150) : Colors.black, // Màu của border
                                    width: 0.5, // Độ dày của border
                                  ),
                                  borderRadius: BorderRadius.circular(50.0), // Bo góc
                                  color: isSelected ? Color(0xFF00B150): Colors.white, // Màu nền bên trong
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.08,
                                      height: MediaQuery.of(context).size.height * 0.03,
                                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: SvgPicture.asset(
                                        category["icon"],
                                        color: isSelected ? Colors.white : Colors.black,

                                      ),
                                    ),
                                    const SizedBox(height: 0), // Khoảng cách giữa icon và text
                                    // Tên danh mục
                                    Text(
                                      category["name"],
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected ? Colors.white : Colors.black
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                          );

                        },
                      ),
                    ),
                    const SizedBox(height: 0),
                    ExpansionTile(
                      title: Text("Time filter", style: TextStyle(fontWeight: FontWeight.bold)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _pickDateTime(isStart: true),
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _tempStartDateTime != null
                                              ? DateFormat("dd/MM/yyyy - HH:mm").format(_tempStartDateTime!)
                                              : "Start time",
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _pickDateTime(isStart: false),
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _tempEndDateTime != null
                                              ? DateFormat("dd/MM/yyyy - HH:mm").format(_tempEndDateTime!)
                                              : "End time",
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child:Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _tempStartDateTime = null;
                                          _tempEndDateTime = null;
                                          _startDateTime = null;
                                          _endDateTime = null;
                                        });
                                        _getBookings();
                                      },
                                      child: Text("Reset",style: TextStyle(color: Color(0xff00B150))),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white), // Chỉnh màu nút reset
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xff00B150)),
                                      onPressed: () {
                                        setState(() {
                                          _startDateTime = _tempStartDateTime;
                                          _endDateTime = _tempEndDateTime;
                                        });

                                        _filterByDateTime();
                                      },
                                      child: Text("Filter", style: TextStyle(color: Colors.white),),
                                    ),

                                  ]
                                )

                              ),
                            ],
                          ),
                        ),
                      ],
                    )




                  ],
                ),

              ),

              // Align(
              //   heightFactor: 10,
              //   child: Column(
              //     children: [
              //       Text(
              //         "No Orders Yet",
              //         style: TextStyle(
              //           color: Colors.black,
              //           fontSize: 20,
              //           fontWeight: FontWeight.w500,
              //         ),
              //       ),
              //       Text(
              //         "Start exploring and place your first order now!",
              //         style: TextStyle(
              //           color: Colors.black45,
              //           fontSize: 16,
              //           fontWeight: FontWeight.w400,
              //         ),
              //       ),
              //     ],
              //   ),
              // )

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      isLoading = true; // Cho cảm giác đang tải lại
                      page = 0;
                      hasMoreData = true;
                    });
                    await _getBookings(isLoadMore: false, forceRefresh: true);
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: bookingsData.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      List<Map<String, dynamic>> filteredBookings = bookingsData
                          .where((bookingItem) {
                        final price = bookingItem['booking']?['price'];
                        if (price == null) return false;

                        // 2. Lọc theo enrichedTickets -> createdAt nằm trong khoảng thời gian
                        final tickets = List<Map<String, dynamic>>.from(bookingItem['tickets'] ?? []);
                        final slots = (bookingItem['slots'] as List?) ?? [];
                        final slotMap = { for (var slot in slots) slot['id']: slot };

                        final enrichedTickets = tickets.map<Map<String, dynamic>>((ticket) {
                          final slotId = ticket['slotId'];
                          return {
                            ...ticket,
                            'slot': slotMap[slotId],
                          };
                        }).toList();

                        if (_startDateTime != null && _endDateTime != null) {
                          return enrichedTickets.any((ticket) {
                            try {
                              final ticketDate = DateTime.parse(ticket['createdAt']);
                              return ticketDate.isAfter(_startDateTime!) && ticketDate.isBefore(_endDateTime!);
                            } catch (e) {
                              return false; // Nếu có lỗi khi parse, không tính ticket này
                            }
                          });
                        } else {
                          // Nếu không có thời gian lọc, trả về true để không lọc
                          return true;
                        }
                      })
                          .toList()
                          .cast<Map<String, dynamic>>();
                      if (index < filteredBookings.length && bookingsData[index] != null) {

                        var booking = filteredBookings[index]['booking'];
                        var address = filteredBookings[index]['address'];
                        var locationName = filteredBookings[index]['locationName'];
                        var image = filteredBookings[index]['images'];
                        var tickets = List<Map<String, dynamic>>.from(filteredBookings[index]['tickets']);
                        var slots = (filteredBookings[index]['slots'] as List?) ?? [];
                        var ticketStatuses = tickets.map((t) => t['status'].toString()).toList();
                        var ticketStatusText = ticketStatuses.join(", ");

                        print('ticketStatuss: $ticketStatusText');

                        Map<String, dynamic> slotMap = {
                          for (var slot in slots) slot['id']: slot
                        };

                        // Gán slot tương ứng vào mỗi ticket
                        List<Map<String, dynamic>> enrichedTickets = tickets.map<Map<String, dynamic>>((ticket) {
                          final slotId = ticket['slotId'];
                          return {
                            ...ticket, // chú ý chỗ này cũng cần đảm bảo ticket là Map<String, dynamic>
                            'slot': slotMap[slotId],
                          };
                        }).toList();
                        print("enrichedTickets ${enrichedTickets}");


                        return ActivitesItem(
                          id: (booking['id'] ?? '').toString(),
                          date: (booking['createdAt'] ?? '').toString(),
                          startTime: '',
                          endTime: '',
                          status: (booking['status'] ?? '').toString(),
                          ticketStatus: ticketStatusText ?? '',
                          type: (booking['type'] ?? '').toString(),
                          location: address ?? '',
                          locationName: locationName ?? '',
                          price: double.tryParse(
                              booking['finalPrice']?.toString() ??
                                  booking['price']?.toString() ??
                                  '0.0'
                          ) ?? 0.0,
                          tickets: enrichedTickets ?? [],
                          image: (image != null && image.isNotEmpty ? image[0].toString() : ''),
                          booking: booking ?? {},
                        );
                      } else {
                        return isLoadingMore
                            ? Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(child: CircularProgressIndicator()),
                        )
                            : SizedBox();
                      }
                    },
                  ),
                ),

              ),

            ],

          ),

        ),

      ),


    );

  }
}
class ActivitesItem extends StatefulWidget {
  final String id;
  final String date;
  final String startTime;
  final String endTime;
  final String status;
  final String ticketStatus;
  final String type;
  final String location;
  final String locationName;
  final String image;
  final double price;
  final List<Map<String, dynamic>> tickets;
  final Map<String, dynamic> booking;


  ActivitesItem({super.key,
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.ticketStatus,
    required this.type,
    required this.location,
    required this.price,
    required this.tickets,
    required this.image,
    required this.booking,
    required this.locationName,

  });
  _StateActivitesItem createState() => _StateActivitesItem();
}
class _StateActivitesItem extends State<ActivitesItem>{
  late final String id;
  late String date;
  late String startTime;
  late String endTime;
  late String status;
  late String ticketStatus;
  late String type;
  late String location;
  late String locationName;
  late String image;
  late double price;
  late List<Map<String, dynamic>> tickets;
  late String duration;
  late Map<String, dynamic> booking;

  String formatDate(String dateTimeStr) {
    DateTime dateTime = DateTime.parse(dateTimeStr).toLocal();
    return DateFormat("HH:mm, dd-MM").format(dateTime);
  }
  String formatPrice(double price) {
    final formatter = NumberFormat("#,###", "vi_VN");
    return "${formatter.format(price)} đ";
  }
  String formatTime(String dateTimeStr) {
    DateTime dateTime = DateTime.parse(dateTimeStr).toLocal();
    return DateFormat('HH:mm').format(dateTime);
  }

  Future<void> handleChangeTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    try{
      final rs = await Dio().get(
          "http://18.182.12.54:8082/app-data-service/bookings/with-tickets?type=PARKING&page=0&size=100&sort=updatedAt,desc&bookingId=$id"
      );
    }catch(e){
      print("Change Time Error: $e");
    }
  }

  bool shouldShowChangeTime(String? startTimeStr) {
    if (startTimeStr == null || startTimeStr.isEmpty) return false;


    final startTime = DateTime.tryParse(startTimeStr)?.toLocal();
    if (startTime == null) return false;

    final now = DateTime.now();
    final minutesUntilStart = startTime.difference(now).inMinutes;

    // Chỉ cho đổi nếu còn hơn 15 phút nữa mới đến startTime
    return minutesUntilStart > 15;
  }





  @override
  void initState() {
    super.initState();
    id = widget.id;
    date = widget.date;
    startTime = widget.startTime;
    endTime = widget.endTime;
    status = widget.status;
    ticketStatus = widget.ticketStatus;
    type = widget.type;
    location = widget.location;
    locationName = widget.locationName;
    image = widget.image;
    price = widget.price;
    tickets = widget.tickets;
    booking = widget.booking;
  }

  @override
  Widget build(BuildContext context) {
    final requiresPayment = tickets.any((ticket) =>
    ticket['status'] == 'PAYMENT_REQUIRED' || ticket['status'] == 'EXTEND_PAYMENT_REQUIRED'
    );
    final hasVerifyRequiredTicket = tickets.any((ticket) => ticket['status'] == 'VERIFY_REQUIRED');


    dynamic _swStatus(String status) {
      switch (status) {
        case 'VERIFY_REQUIRED':
          return 'VERIFY REQUIRED';
        case 'PAYMENT_REQUIRED':
          return 'PAYMENT REQUIRED';
        case 'PAID':
        return 'PAID';
        case 'PAYMENT_EXPIRED':
          return 'PAYMENT EXPIRED';
        case 'EXTEND_PAYMENT_REQUIRED':
          return 'EXTEND PAYMENT REQUIRED';
        case 'EXTEND_PAYMENT_PAID':
          return 'EXTEND PAYMENT PAID';
        case 'EXTEND_PAYMENT_CANCELED':
          return 'EXTEND PAYMENT CANCELED';
        case 'EXTEND_PAYMENT_EXPIRED':
          return 'EXTEND PAYMENT EXPIRED';
        case 'EXTEND_REJECTED':
          return 'EXTEND REJECTED';
        case 'COMPLETE':
          return 'COMPLETE';
        case 'CANCELED':
          return 'CANCELED';
        case 'TIME_CHANGE_PAYMENT_REQUIRED':
          return 'TIME CHANGE PAYMENT REQUIRED';
        case 'TIME_CHANGE_PAYMENT_EXPIRED':
          return 'TIME CHANGE PAYMENT EXPIRED';
        case 'TIME_CHANGE_PAYMENT_CANCELED':
          return 'TIME CHANGE PAYMENT CANCELED';
        case 'TIME_CHANGE_REJECTED':
          return 'TIME CHANGE REJECTED';
        case 'TIME_CHANGE_PAYMENT_PAID':
          return 'TIME CHANGE PAYMENT PAID';
          default: "UNKNOW"  ;
      }
    }

    return

          Column(
          children: [
            const SizedBox(height: 20),
            Container(
              //margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child:
              Padding(
                padding: EdgeInsets.all(12),
                child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Text(formatDate(date), style: TextStyle(fontWeight: FontWeight.bold)),
                    //SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatDate(date), style: TextStyle(fontWeight: FontWeight.bold)),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: status == "PAID"
                                || status == "COMPLETE"
                                || status == "EXTEND_PAYMENT_PAID"
                                || status == "TIME_CHANGE_PAYMENT_PAID"
                                ? Color(int.parse("0xFFE1F5FF")) : Color(int.parse("0xFF44336")),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _swStatus(status),
                            style: TextStyle(color: status == "PAID"
                                || status == "COMPLETE"
                                || status == "EXTEND_PAYMENT_PAID"
                                || status == "TIME_CHANGE_PAYMENT_PAID"
                                ? Color(int.parse("0xFF0075C8")) : Color(int.parse("0xFFB3261E")),
                            fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: (){
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>OrderDetails(
                            id: id,
                            locationId: location,
                            type: type,
                            status: status
                        )));
                      },
                      child: Row(
                        children: [
                          if(type == "PARKING")
                            SvgPicture.asset(
                              'lib/assets/images/icons/parking-icon.svg',
                              width: 24,
                              height: 24,
                            ),
                          if(type == "CHARGING")
                            SvgPicture.asset(
                              'lib/assets/images/icons/charge-icon.svg',
                              width: 24,
                              height: 24,
                            ),
                          SizedBox(width: 8),
                          Expanded(
                            child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Text(
                                    locationName,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis, // Thêm dấu "..." nếu quá dài
                                  ),
                                Text(
                                  location,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black54),
                                  maxLines: 1, // Giới hạn số dòng
                                  overflow: TextOverflow.ellipsis, // Thêm "..." nếu text quá dài
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Color(0xff00B150),
                          )

                        ],

                      ),

                    ),
                    SizedBox(height: 15),
                    ...tickets.map((ticket) {
                      final String ticketStatus = ticket['status'];
                      print("tickett1 ${jsonEncode(ticket)}");
                      final DateTime start = DateTime.parse(ticket['startDateTime']);
                      final DateTime end = DateTime.parse(ticket['endDateTime']);
                      final int totalMinutes = end.difference(start).inMinutes;
                      final DateTime createdAt = DateTime.parse(ticket['createdAt']);
                      final String startDateTime = ticket['startDateTime'].toString();


                      final String formattedDuration = totalMinutes.toString();
                      setState(() {
                        duration = formattedDuration;
                      });
                      return ticketStatus == 'PAYMENT_REQUIRED' || ticketStatus == 'EXTEND_PAYMENT_REQUIRED'
                          ? Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(0),
                            height: 1,
                            width: double.infinity,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                      Text(
                      "${ticket['slot']['zone'] != null ? 'Zone ${ticket['slot']['zone']}' : 'Gate ${ticket['slot']['gate'] ?? 'N/A'}'}"
                      " - ${ticket['slot']?['slotNumber']?.toString() ?? 'N/A'}",

                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black, fontSize: 16)),
                                  SizedBox(height: 8),
                                  Text("Extension time", style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black54, fontSize: 14)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: ticketStatus == "PAID" ? Color(0xFFE1F5FF) : Color(0xFF44336),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _swStatus(ticketStatus),
                                      style: TextStyle(
                                        color: ticketStatus == "PAID" ? Color(0xFF0075C8) : Color(0xFFB3261E),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(formattedDuration+"min", style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black54, fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                          : SizedBox.shrink();
                    }).toList(),





                    SizedBox(height: 8),

                    Row(

                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Text("\$""${price.toString()}" , style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        requiresPayment ?
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExtendCheckout(
                                    location: location,
                                    type: type,
                                    tickets: tickets,
                                    price: price,
                                    image: image,
                                    booking: booking
                                ),
                              ),
                            );
                          },
                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff00B150),
                            foregroundColor: Color(0xFF00B150),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(color: Color(0xFF00B150), width: 1),
                            ),
                          ),
                          child: Text(
                            "Payment"
                            ,style: TextStyle(color: Colors.white),),
                        ) :
                        Row(
                          children: [

                            if (tickets.isNotEmpty &&
                                shouldShowChangeTime(tickets.first['startDateTime']) &&
                                tickets.first['status'] != 'CANCELED' &&
                                !tickets.any((ticket) => ticket['isCheckIn'] == true))
                              TextButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    backgroundColor: Colors.transparent,
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) => ShowExtendChangetime(id: id, tickets: tickets),
                                  );
                                },
                                child: Text(
                                  "Change Time",
                                  style: TextStyle(color: Color(0xFF00B150)),
                                ),
                              ),

                            (!hasVerifyRequiredTicket &&
                                tickets.first['isWantingTimeChange'] == true )
                                ? ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ExtendPayment(
                                        type: "TIME_CHANGE",
                                        price: booking['totalTimeChangePrice'] ?? 0,
                                        booking: booking),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff00B150),
                                foregroundColor: Color(0xFF00B150),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(color: Color(0xFF00B150), width: 1),
                                ),
                              ),
                              child: Text(
                                "Pay \$${booking['totalTimeChangePrice'] ?? 0}",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                                : SizedBox.shrink(),

                            // ticketStatus.contains('COMPLETE') || ticketStatus.contains('CANCELED') || ticketStatus.contains('TIME_CHANGE_PAYMENT_PAID') ?
                            // ElevatedButton(
                            //   onPressed: () {
                            //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>OrderDetails(
                            //         id: id,
                            //         locationId: location,
                            //         type: type,
                            //         status: status
                            //     )));
                            //   },
                            //   style:
                            //   ElevatedButton.styleFrom(
                            //     backgroundColor: Colors.white,
                            //     foregroundColor: Color(0xFF00B150),
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(30),
                            //       side: BorderSide(color: Color(0xFF00B150), width: 1),
                            //     ),
                            //   ),
                            //   child: Text("Rate"),
                            // ) : SizedBox.shrink(),
                            ticketStatus.contains('PAID') ?
                            ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => ShowExtend(id: id, tickets: tickets),
                              );
                            // if (result == true) {
                            //   // Gọi lại API để cập nhật giao diện sau khi extend
                            //   fetchBookingDetails();
                            // }
                            },
                            style:
                              ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Color(0xFF00B150),
                              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(color: Color(0xFF00B150), width: 1),
                            ),
                            ),
                            child: Text("Extend"),
                            ) : SizedBox.shrink(),
                            ],
                          )


                      ],
                    ),

                  ],
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.02,

              color: Colors.grey[200],
            )
          ],
        );

  }


}