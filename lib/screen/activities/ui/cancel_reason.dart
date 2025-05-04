import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CancelReason extends StatefulWidget {
  String bookingId;
  CancelReason({super.key, required this.bookingId});

  @override
  _CancelReasonState createState() => _CancelReasonState();
}

class _CancelReasonState extends State<CancelReason> {
  String? selectedReason; // Lưu lý do được chọn

  final List<String> reasons = [
    "I changed my plans.",
    "My vehicle is fully charged.",
    "The location is too far.",
    "The service fee is too high.",
    "I found another charging station that is more convenient."
  ];

  Future<void> cancelBooking() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 🌀 Gọi API để update nếu cần
    String? token = prefs.getString('access_token');
    try{
      var rs = await Dio().post(
          "http://18.182.12.54:8082/app-data-service/bookings/cancel",
          data: {
            "bookingId": widget.bookingId,
            "cancelReason": selectedReason,
          },
          options: Options(
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",  // Sử dụng token xác thực
            },
      ));
      if (rs.statusCode == 200) {
        print("Booking cancelled successfully");
      } else {
        print("Failed to cancel booking: ${rs.statusMessage}");
      }
    }catch(e){
      print("Error cancelling booking: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body:
        GestureDetector(
        onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.transparent,
            child:DraggableScrollableSheet(
              initialChildSize: 0.5, // Kích thước ban đầu
              minChildSize: 0.4,
              maxChildSize: 0.94,
              builder: (context, scrollController) {
                return Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // Tiêu đề & nút đóng
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select cancellation reason",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      Divider(),
                      // Danh sách lựa chọn
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: reasons.length,
                          itemBuilder: (context, index) {
                            return RadioListTile<String>(
                              title: Text(reasons[index]),
                              value: reasons[index],
                              groupValue: selectedReason,
                              onChanged: (value) {
                                setState(() {
                                  selectedReason = value;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      // Nút Agree
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: selectedReason != null
                            ? () {
                          print("Selected Reason: $selectedReason");
                          cancelBooking();
                        }
                            : null, // Disabled nếu chưa chọn
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00B150),
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50), // Full width
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text("Agree",
                            style: TextStyle(
                                fontSize: 17
                            )
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        )

    );
  }
}
