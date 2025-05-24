

import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:parking_project/screen/checkout/ui/booking_success.dart';
import 'package:parking_project/screen/checkout/ui/payment_method.dart';
import 'package:parking_project/screen/checkout/ui/payments.dart';
import 'package:parking_project/screen/checkout/ui/promo.dart';
import 'package:parking_project/screen/home/ui/parking_details.dart';
import 'package:parking_project/screen/home/ui/sparkparking_station.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedSpots;
  List<Map<String, dynamic>> spots;
  List<String> availableSlots;
  final List<Map<String, dynamic>> orders;
  Map<String, dynamic> station;
  List<String> unavailableSlots;
  final int durationMinutes;
  final String dateStart;
  final String dateEnd;
  Map<String, dynamic>? voucher;
  CheckoutScreen({
    Key? key,
    required this.selectedSpots, // Giá trị mặc định là danh sách rỗng
    required this.spots,
    required this.availableSlots,
    required this.orders,
    required this.station,
    required this.durationMinutes,
    required this.unavailableSlots,
    required this.dateStart,
    required this.dateEnd,
    required this.voucher
  }) : super(key: key);


  @override
  _StateCkeckoutScreen createState() => _StateCkeckoutScreen();
}
class _StateCkeckoutScreen extends State<CheckoutScreen>{
  bool _isChecked1 = false;
  bool _isChecked2 = false;

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
    final formatter = NumberFormat("#,###", "vi_VN");
    return "${formatter.format(price)} đ";
  }





  @override
  Widget build(BuildContext context) {
    final selectedSpots = widget.selectedSpots;
    final order = widget.orders[0];
    final station = widget.station;
    final voucher = widget.voucher;

    print('selectedSpots $selectedSpots');
    print("order: $order");
    print("station: $station");
    print("promo $voucher");
    double fixedPrice() {
      double originalPrice = order['price']?.toDouble() ?? 0.0;
      double finalPrice = originalPrice;

      if (voucher != null) {
        if (voucher['percentage'] == true) {
          double percent = voucher['discountAmount']?.toDouble() ?? 0.0;
          finalPrice = originalPrice - (originalPrice * (percent / 100));
        } else {
          double discount = voucher['discountAmount']?.toDouble() ?? 0.0;
          finalPrice = originalPrice - discount;
        }

        // Đảm bảo không âm giá
        if (finalPrice < 0) finalPrice = 0;
      }

      return finalPrice;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child:
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => SparkparkingStation(
                                spots: widget.spots,
                                availableSlots: widget.availableSlots,
                                unavailableSlots: widget.unavailableSlots,
                                durationMinutes: widget.durationMinutes,
                                station: widget.station,
                                dateStart: widget.dateStart,
                                dateEnd: widget.dateEnd,
                              ),
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
                        child: Text(

                          "Check out",
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
          Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFE6E6E6),width: 2),
                borderRadius: BorderRadius.circular(8.0),

              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.27,
                          height: MediaQuery.of(context).size.height * 0.10,
                          child: Image.network(
                            station['images'][0],
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 16,), // Khoảng cách giữa các phần tử
                        Expanded(
                          child:
                              Padding(
                                padding: EdgeInsets.only(top: 3),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,

                                children: [
                                  Text(
                                    station['name'],
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        height: 0
                                    ),

                                    //overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(width: 16),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Row(
                                      spacing: 5,
                                      children: [
                                        Text(
                                          "${station['services'] != null ? station['services'].join(', ') : 'Unknown'} • ",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              height: 2,
                                              color: Colors.black54
                                          ),

                                          overflow: TextOverflow.ellipsis, // Chữ quá dài sẽ được rút gọn
                                        ),
                                        Text(
                                            "${station['distance'] != null ? (station['distance'] >= 1 ? "${station['distance'].toStringAsFixed(1)}km" : "${(station['distance'] * 1000).toInt()}m") : 'Unknown'}",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              height: 2,
                                              color: Colors.black54
                                          ),

                                          overflow: TextOverflow.ellipsis, // Chữ quá dài sẽ được rút gọn
                                        ),
                                      ],
                                    ),
                                  )


                                ],
                              ),
                              )

                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Container(
                    color: Color(0xFFE6E6E6),
                    height: 2,
                    margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  ),
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
                                'Booking date',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF686868)
                              ),
                            ),
                            Text(
                              formatDate(widget.dateStart),
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
                              'Location',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF686868)
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (selectedSpots.isNotEmpty)
                                  for (int i = 0; i < selectedSpots.length; i++)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 1.0),
                                      child: Text(
                                        "${selectedSpots[i]["slotNumber"] ?? "Unnamed Spot"}${i != selectedSpots.length - 1 ? ',' : ''}",
                                        style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87
                                        ),
                                      ),
                                    )
                                else
                                  const Text(
                                    "No spots selected.",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 17,
                                    ),
                                  ),
                              ],
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
                              formatTime(widget.dateStart),
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
                                formatTime(widget.dateEnd) ,
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
                              widget.durationMinutes.toString() + " m",
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87
                              ),
                            )
                          ],
                        ),

                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    color: Color(0xFFE6E6E6),
                    height: 1.4,
                    margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  ),
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
                              'Total fee',
                              style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black
                              ),
                            ),
                            Row(
                              children: [
                                if(voucher !=null && voucher.isNotEmpty)
                                Text(
                                  "\$${order['price']}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.withOpacity(0.6),
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "\$${fixedPrice().toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF00B150),
                                  ),
                                ),
                              ],
                            )

                          ],
                        ),
                        SizedBox(height: 6),


                      ],
                    ),
                  ),



                ],
              ),
            ),
          ),

            ],
          ),


        ),

      ),
      bottomNavigationBar: Container(

        height: MediaQuery.of(context).size.height * 0.16,
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

            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Promo(
                    selectedSpots: selectedSpots.isNotEmpty ? selectedSpots : [],
                    spots: widget.spots,
                    availableSlots: widget.availableSlots,
                    unavailableSlots: widget.unavailableSlots,
                    orders: widget.orders,
                    station: widget.station,
                    durationMinutes: widget.durationMinutes,
                    dateStart: widget.dateStart,
                    dateEnd: widget.dateEnd
                )));
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        SvgPicture.asset('lib/assets/images/icons/promo.svg'),
                        Text('Apply or enter a promo code',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF00B150)
                          ),
                        )
                      ],
                    ),
                    SvgPicture.asset('lib/assets/images/icons/arrow_right.svg',width: 20,height: 20,)
                  ],
                ),
              ),
            ),


            SizedBox(height: 20,),
            Align(
              alignment: Alignment(0, -0.7),
              child: ElevatedButton(
                onPressed: () {
                  // Logic cho khi nút Next được nhấn
                  print("Next button pressed");
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Payments(
                      selectedSpots: selectedSpots.isNotEmpty ? selectedSpots : [],
                      spots: widget.spots,
                      availableSlots: widget.availableSlots,
                      unavailableSlots: widget.unavailableSlots,
                      orders: widget.orders,
                      station: widget.station,
                      durationMinutes: widget.durationMinutes,
                      dateStart: widget.dateStart,
                      dateEnd: widget.dateEnd,
                      voucher: voucher,
                      price: fixedPrice()
                  )));
                },
                style: ElevatedButton.styleFrom(

                  backgroundColor: Color(0xFF00B150), // Màu nền cho nút
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Bo tròn nút
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 140, vertical: 8), // Padding cho nút
                ),
                child: Text(
                  "Payment",
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
