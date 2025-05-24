import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:parking_project/root_page.dart';
import 'package:parking_project/screen/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingSuccess extends StatefulWidget {
  String bookingId;
  String type;
  double totalUSD;

  BookingSuccess({super.key, required this.bookingId, required this.type, required this.totalUSD});
  @override
  _BookingSuccessState createState() => _BookingSuccessState();
}
class _BookingSuccessState extends State<BookingSuccess>{
  Map<String, dynamic>? bookingData;
  bool isLoading = true;
  late double totalUSD;
  @override
  void initState() {
    super.initState();
    _getBooking();
    totalUSD = double.parse(widget.totalUSD.toStringAsFixed(2));
    print("totalUSD $totalUSD");
  }

  String formatDate(String dateTimeStr) {
    DateTime dateTime = DateTime.parse(dateTimeStr).toLocal();
    return DateFormat("dd-MM-yyyy").format(dateTime);
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
    String bookingId = widget.bookingId;
    String type = widget.type;
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
      if (rsData != null && rsData is List && rsData.isNotEmpty) {
        setState(() {
          bookingData = rsData[0];
          isLoading = false;
        });
      } else {
        setState(() {
          bookingData = null;
          isLoading = false;
        });
      }

      print("Booking (API): ${rs.data}");
    } catch (e) {
      print("Error fetching booking: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String getFinalBookingPrice(Map<String, dynamic>? booking) {
    if (booking == null) return formatPrice(totalUSD);
    return formatPrice(
        booking['finalTotalTimeChangePrice'] ??
            booking['totalTimeChangePrice'] ??
            booking['finalPrice'] ??
            booking['price'] ??
            booking['finalTotalExtensionPrice'] ??
            booking['totalExtensionPrice'] ??
            totalUSD
    );
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (bookingData == null) {
      return const Scaffold(
        body: Center(child: Text("Không tìm thấy dữ liệu đặt chỗ!")),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body:
      SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                        "lib/assets/images/icons/tick-circle.svg"
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Booking Successful!",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Your ${widget.type ?? 'unknown'}  spot is ready for you",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black45),
                    ),
                  ),
                  const SizedBox(height: 30),

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
                                        "\$${totalUSD.toString()}",
                                      //getFinalBookingPrice(bookingData?['booking']),

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
      bottomNavigationBar: Container(

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
              Align(
                alignment: Alignment(0, -0.7),
                child: ElevatedButton(
                  onPressed: () {
                    // Logic cho khi nút Next được nhấn
                    print("Next button pressed");
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> RootPage()));
                  },
                  style: ElevatedButton.styleFrom(

                    backgroundColor: Color(0xFF00B150), // Màu nền cho nút
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Bo tròn nút
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 130, vertical: 10), // Padding cho nút
                  ),
                  child: Text(
                    "Back to home",
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
    );
  }


}

class BookingTile extends StatelessWidget {
  final String slotNumber;
  final String slotQr;
  final String slots;
  final String ticketId;
  final String ticketDate;
  final String ticketStart;
  final String ticketEnd;

  const BookingTile({super.key, required this.slotNumber, required this.slotQr, required this.slots, required this.ticketId,
    required this.ticketDate, required this.ticketStart, required this.ticketEnd});

  // var duration = ticketStart - ticketEnd;
  String getDuration(String startStr, String endStr) {
    final format = DateFormat("dd-MM-yyyy/HH:mm");
    final start = format.parse(startStr);
    final end = format.parse(endStr);
    final duration = end.difference(start);
    return "${duration.inMinutes}";
  }
  @override
  Widget build(BuildContext context) {
    print("duration ${getDuration(ticketStart, ticketEnd)}");
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
          title: Text("Zone $slots"", ""$slotNumber"),

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
                        "$ticketDate",
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
                        "$ticketStart",
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
                        "$ticketEnd",
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
                        getDuration(ticketStart, ticketEnd) + " min",
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
                // QrImageView(
                //   data: slotQr,
                //   size: 250,
                //   backgroundColor: Colors.white,
                // ),
                Image.memory(
                  base64Decode(slotQr.replaceFirst(RegExp(r'data:image/[^;]+;base64,'), '')),
                  width: 250,
                  height: 250,
                ),
                const SizedBox(height: 10),
                Text("ID: ${ticketId.substring(0, 8)}".toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    // Logic tải ảnh mã QR
                  },
                  child: const Text("Download image", style: TextStyle(color: Colors.green)),
                ),
              ],
            ),
          ],
        ),
      );


  }
}
