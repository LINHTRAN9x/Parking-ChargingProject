
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parking_project/screen/profile/ui/booking_issues_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../activities/ui/extend_checkout.dart';
import '../../activities/ui/order_details.dart';
import '../../home/ui/show_extend.dart';

class BookingIssues extends StatefulWidget {
  const BookingIssues({super.key});

  @override
  _StateBookingIssues createState() => _StateBookingIssues();
}
class _StateBookingIssues extends State<BookingIssues>{
  final DraggableScrollableController _controller = DraggableScrollableController();
  int selectedCategoryId = 1;
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  int page = 0;
  List<dynamic> bookingsData = [];
  List<dynamic> allBookingsData = [];
  ScrollController _scrollController = ScrollController();
  DateTime? _startDateTime;
  DateTime? _endDateTime;

  DateTime? _tempStartDateTime;
  DateTime? _tempEndDateTime;

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
          String createdAtStr = ticket['createdAt'];
          DateTime createdAt = DateTime.parse(createdAtStr);

          return createdAt.isAfter(_startDateTime!) &&
              createdAt.isBefore(_endDateTime!);
        });
      }).toList();
    });

    print("Đã lọc theo thời gian: $_startDateTime -> $_endDateTime");
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
              maxChildSize: 0.94,
              builder: (context, scrollController) {
                return Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(16, 20, 20, 0),
                        decoration: BoxDecoration(
                          color: Colors.white, // Màu nền
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xfff8f8f8), // Màu viền
                              width: 1.0,         // Độ dày viền
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(0),
                              child:
                              Text(
                                "Select booking",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 35, // Chiều cao tổng danh sách
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
                                              width: 30,
                                              height: 25,
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
                                                  child: Text("Lọc", style: TextStyle(color: Colors.white),),
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
                          backgroundColor: Colors.grey[200],
                          color: Colors.black,
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
                                  price: double.tryParse(
                                      booking['finalPrice']?.toString() ??
                                          booking['price']?.toString() ??
                                          '0.0'
                                  ) ?? 0.0,
                                  tickets: enrichedTickets ?? [],
                                  image: (image.isNotEmpty ? image[0].toString() : ''),
                                  booking: booking ?? {},
                                );
                              } else {
                                return Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                            },
                          ),
                        ),

                      ),

                    ],

                  ),
                );

              }
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
    required this.booking

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



    return

      Column(
        children: [

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
                    child:
                    Row(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 72,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: type == "PARKING"
                                ? Image.network(
                              image,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  // Image loaded
                                  return child;
                                } else {
                                  // Show a gray placeholder while the image is loading
                                  return Container(
                                    color: Colors.grey[200], // Gray placeholder
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.black54,
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                            : null,
                                      ),
                                    ),
                                  );
                                }
                              },
                            )
                                : type == "CHARGING"
                                ? Image.network(
                              image,
                              width: 74,
                              height: 74,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  // Image loaded
                                  return child;
                                } else {
                                  // Show a gray placeholder while the image is loading
                                  return Container(
                                    color: Colors.white, // Gray placeholder
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                            : null,
                                      ),
                                    ),
                                  );
                                }
                              },
                            )
                                : SizedBox(),
                          ),
                        ),


                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (type == "PARKING")
                                Text(
                                  'SparkParking Station',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis, // Thêm dấu "..." nếu quá dài
                                ),
                              if (type == "CHARGING")
                                Text(
                                  'GreenCharge Hub',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              Text(
                                "Booking ID: ${id.substring(0, 8)}".toUpperCase(),
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black54, ),
                                maxLines: 1, // Giới hạn số dòng
                                overflow: TextOverflow.ellipsis, // Thêm "..." nếu text quá dài
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> BookingIssesField(bookingId: id)));
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
                          child: Text("Select"),
                        )

                      ],

                    ),

                  ),


                  SizedBox(height: 8),



                ],
              ),
            ),
          ),
          Container(
            height: 1,

            color: Colors.grey[200],
          )
        ],
      );

  }


}
