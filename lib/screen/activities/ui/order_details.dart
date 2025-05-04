import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:parking_project/root_page.dart';
import 'package:parking_project/screen/activities/activity_screen.dart';
import 'package:parking_project/screen/activities/ui/cancel_reason.dart';
import 'package:parking_project/screen/home/home_screen.dart';
import 'package:parking_project/screen/home/ui/show_time_filter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../notice/ui/test.dart';

class OrderDetails extends StatefulWidget {
  final String id;
  final String locationId;
  final String type;
  final String status;

  OrderDetails({super.key, required this.id, required this.locationId, required this.type, required this.status});

  @override
  _StateOrderDetails createState() => _StateOrderDetails();
}
class _StateOrderDetails extends State<OrderDetails>{
  bool isLoading = true;
  var bookingData;
  bool isValidStatus = false;

  String formatDate(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.trim().isEmpty) {
      return "N/A"; // Default value when date is missing
    }

    try {
      DateTime dateTime = DateTime.parse(dateTimeStr).toLocal();
      return DateFormat("dd-MM-yyyy").format(dateTime);
    } catch (e) {
      return "Invalid Date"; // Return an error message for invalid formats
    }
  }
  String formatTime(String dateTimeStr) {
    DateTime dateTime = DateTime.parse(dateTimeStr).toLocal();
    return DateFormat('dd-MM-yyyy/HH:mm').format(dateTime);
  }
  String formatDuration(String durationHours) {
    return (double.parse(durationHours) * 60).toInt().toString();
  }
  String formatPrice(double price) {
    final formatter = NumberFormat("#.###", "en_US");
    return "\$${formatter.format(price)}";
  }

  Future<void> _getBooking() async {
    setState(() {
      isLoading = true;
    });

    String bookingId = widget.id;
    String type = widget.type;
    String status = widget.status;
    if(status == "PAID"  || status == "EXTEND_PAYMENT_EXPIRED" || status == "EXTEND_PAYMENT_PAID"){
      setState(() {
        isValidStatus = true;
      });
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // ✅ Load local data nếu có
    String? cachedData = prefs.getString('cached_booking_$bookingId');
    if (cachedData != null) {
      setState(() {
        bookingData = jsonDecode(cachedData);
        isLoading = false;
      });
    }


    // 🌀 Gọi API để update nếu cần
    String? token = prefs.getString('access_token');
    try {
      setState(() {
        isLoading = true;
      });
      var rs = await Dio().get(
        "http://18.182.12.54:8082/app-data-service/bookings/with-tickets?type=$type&page=0&size=100&sort=updatedAt,desc&bookingId=$bookingId",
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      // Cập nhật lại local và UI
      prefs.setString('cached_booking_$bookingId', jsonEncode(rs.data));
      var rsData = rs.data["content"];

      setState(() {
        bookingData = rsData[0];
        isLoading = false;
      });

      print("Booking (API): ${rs.data}");
    } catch (e) {
      print("Error fetching booking: $e");
      setState(() {
        isLoading = false;
      });
    }
  }
  Map<String, dynamic> station = {};


  Future<void> navigation() async {
    //String stationId = widget.locationId;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    var cachedDataStation = bookingData['location'];

    print("cachedDataStation: $cachedDataStation");

    if (cachedDataStation != null) {

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> VietMapNavigationScreen(station: cachedDataStation)));
    } else {
      print("No cached station data found");
    }
  }




  @override
  void initState() {
    _getBooking();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body:
      isLoading
          ? Center(child: CircularProgressIndicator()):
           bookingData == null ?
           Center(child: Text("Không tìm thấy dữ liệu đặt chỗ!"))
        :
      SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const RootPage(initialIndex: 1)),
                        );
                      },
                      child: SvgPicture.asset(
                        'lib/assets/images/icons/arrow-left.svg',
                        width: 24,
                        height: 24,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Order details",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [


                  // Booking Information
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFE6E6E6),width: 2),
                        borderRadius: BorderRadius.circular(8.0),

                      ),
                      child: Column(
                        children: [

                          SizedBox(width: 16),


                          SizedBox(height: 16),
                          Container(
                            margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Column(
                              spacing: 16,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [

                                    Text(
                                      "${bookingData?['booking']?['type'] ?? ''} STATION",
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87
                                      ),
                                    )
                                  ],
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Booking ID',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF686868)
                                      ),
                                    ),
                                    Expanded(
                                        child: Text(
                                          textAlign: TextAlign.end,
                                          (bookingData?['booking']?['id']?.substring(0, 8) ?? 'No Booking ID').toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                    ),

                                  ],
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total fee',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF686868)
                                      ),
                                    ),
                                    Text(
                                      bookingData['booking']?['finalPrice'] != null
                                          ? formatPrice(bookingData['booking']?['finalPrice'] ?? 0)
                                          : formatPrice(bookingData['booking']?['price'] ?? 0),

                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  color: Color(0xFFE6E6E6),
                                  height: 1.6,
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          //colapse
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: isLoading
                                ? Center(child: CircularProgressIndicator())
                                : Builder(
                              builder: (_) {
                                List tickets = bookingData?['tickets'] ?? [];
                                List slots = bookingData?['slots'] ?? [];

                                // Tạo map để tra cứu slot theo id
                                Map<String, dynamic> slotMap = {
                                  for (var slot in slots) slot['id']: slot
                                };

                                // Gán slot tương ứng vào mỗi ticket
                                List enrichedTickets = tickets.map((ticket) {
                                  final slotId = ticket['slotId'];
                                  return {
                                    ...ticket,
                                    'slot': slotMap[slotId],
                                  };
                                }).toList();

                                return
                                  Column(
                                  children:  enrichedTickets.map((ticket) {
                                    final slot = ticket['slot'];
                                    return Hero(
                                      tag: 'slot_${slot?['slotNumber'] ?? ticket['id']}',
                                      child:
                                      BookingTile(
                                        key: Key(ticket['id'] ?? ''),
                                        slotNumber: slot?['slotNumber'] ?? 'Unknown',
                                        slotQr: ticket['qrCode'] ?? '',
                                        slots: slot?['zone'] ?? slot?['gate'], // kiểm tra cả slot và zone
                                        ticketId: ticket['id'] ?? '',
                                        ticketDate: formatDate(ticket['createdAt']),
                                        ticketStart: formatTime(ticket['startDateTime']),
                                        ticketEnd: formatTime(ticket['endDateTime']),
                                        isValidStatus : isValidStatus
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ),

                          SizedBox(height: 16),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),


      bottomNavigationBar:
      Container(

          height: 126,
          padding: EdgeInsets.all(10),
          // Màu nền cho container
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5), // Màu bóng mờ
                offset: Offset(0, 2), // Vị trí bóng
                blurRadius: 14, // Độ mờ của bóng
              )
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), // Bo tròn góc trên bên trái
              topRight: Radius.circular(15), // Bo tròn góc trên bên phải
            ),
          ),
          child:Column(
            children: [




              SizedBox(height: 20,),
              Row(
                spacing: 16.567,
                children: [
                  GestureDetector(
                      onTap: () {
                        // Open time filter sheet again
                        showModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => CancelReason(bookingId: widget.id)
                        );
                      },
                    child: Container(

                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 38), // Tạo kích thước nút
                      decoration: BoxDecoration(
                        color: Colors.white, // Màu nền
                        border: Border.all(color: Color(0xFF00B150)), // Viền xanh
                        borderRadius: BorderRadius.circular(30), // Bo tròn góc
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12, // Bóng mờ nhẹ
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        "Cancel order",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF00B150),
                          fontWeight: FontWeight.w500// Màu chữ của nút
                        ),
                      ),
                    )

                  ),

                  ElevatedButton(
                    onPressed: () {
                      // Logic cho khi nút Next được nhấn
                      navigation();

                    },
                    style: ElevatedButton.styleFrom(

                      backgroundColor: Colors.white, // Màu nền cho nút
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Color(0xFF00B150), width: 1),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10), // Padding cho nút
                    ),
                    child: Text(
                      "Navigation",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF00B150), // Màu chữ của nút
                      ),
                    ),
                  ),
                ],
              )

            ],
          )

      ),
    );
  }

}

class BookingTile extends StatefulWidget {
  final String slotNumber;
  final String slotQr;
  final String slots;
  final String ticketId;
  final String ticketDate;
  final String ticketStart;
  final String ticketEnd;
  bool isValidStatus;


  BookingTile(
      {super.key, required this.slotNumber, required this.slotQr, required this.slots, required this.ticketId,
        required this.ticketDate, required this.ticketStart, required this.ticketEnd, required this.isValidStatus});
  @override
  _StateBookingTile createState() => _StateBookingTile();
}
class _StateBookingTile extends State<BookingTile>{

  // var duration = ticketStart - ticketEnd;
  String getDuration(String startStr, String endStr) {
    final format = DateFormat("dd-MM-yyyy/HH:mm");
    final start = format.parse(startStr);
    final end = format.parse(endStr);
    final duration = end.difference(start);
    return "${duration.inMinutes}";
  }
  bool isCheckedIn = false;
  Future<bool> _checkIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');


    try {
      var rs = await Dio().post(
        "http://18.182.12.54:8082/app-data-service/tickets/checkin-request/${widget.ticketId}",
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      print("check in ${rs.data}");
      Fluttertoast.showToast(
        msg: "Check in successfully!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return true; // ✅ Thành công
    } catch (e) {
      print("Checkin err $e");
      Fluttertoast.showToast(
        msg: "Check in error!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false; // Lỗi
    }
  }

  Future<bool> _checkOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    try {
      var rs = await Dio().post(
        "http://18.182.12.54:8082/app-data-service/tickets/checkout-request/${widget.ticketId}",
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      print("check out ${rs.data}");
      Fluttertoast.showToast(
        msg: "Check out successfully!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return true;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Check out error!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    //print("duration ${getDuration(ticketStart, ticketEnd)}");
    return
      Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 5),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Bo góc
          side: const BorderSide(
            color: Colors.black12,
            width: 1,
          ),
        ),
        child: ExpansionTile(
          title: Text("Zone ${widget.slots}"", ""${widget.slotNumber}"),

          children: [
            Container(
              margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                spacing: 16,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Booking date',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF686868)
                        ),
                      ),

                      Text(
                        "${widget.ticketDate}",
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Starting time',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF686868)
                        ),
                      ),
                      Text(
                        "${widget.ticketStart}",
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ending time',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF686868)
                        ),
                      ),
                      Text(
                        "${widget.ticketEnd}",
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Duration',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF686868)
                        ),
                      ),
                      Text(
                        getDuration(widget.ticketStart, widget.ticketEnd) + " min",
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87
                        ),
                      )
                    ],
                  ),

                  Container(
                    color: Color(0xFFE6E6E6),
                    height: 1.6,
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                QrImageView(
                  data: widget.slotQr,
                  size: 250,
                  backgroundColor: Colors.white,
                  errorCorrectionLevel: QrErrorCorrectLevel.L,
                ),
                const SizedBox(height: 10),
                Text("ID: ${widget.ticketId.substring(0, 8).toUpperCase()}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    // Logic tải ảnh mã QR
                  },
                  child: const Text("Download image", style: TextStyle(color: Colors.green)),
                ),
                widget.isValidStatus ?
                GestureDetector(
                  onTap: () async {
                    bool? confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(isCheckedIn ? "Confirm Check Out" : "Confirm Check In"),
                        content: Text(isCheckedIn
                            ? "Are you sure you want to Check Out?"
                            : "Are you sure you want to Check In?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text("Confirm"),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      if (!isCheckedIn) {
                        bool success = await _checkIn(); // ⚡ thêm return bool
                        if (success) {
                          setState(() {
                            isCheckedIn = true;
                          });
                        }
                      } else {
                        bool success = await _checkOut(); // ⚡ check out cũng cần return bool
                        if (success) {
                          setState(() {
                            isCheckedIn = false;
                          });
                        }
                      }
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 50),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Color(0xFF00B150)),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      isCheckedIn ? "Check Out" : "Check In",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF00B150),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )

                    : SizedBox.shrink(),
                SizedBox(height: 8),
              ],

            ),
          ],
        ),
      );


  }
}
