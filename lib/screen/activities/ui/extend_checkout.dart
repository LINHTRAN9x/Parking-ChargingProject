
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:parking_project/screen/activities/activity_screen.dart';
import 'package:parking_project/screen/activities/ui/extend_payment.dart';

import '../../../root_page.dart';
import '../../checkout/ui/promo.dart';

class ExtendCheckout extends StatefulWidget{
  final String location;
  final String type;
  final double price;
  final String image;
  final List<Map<String, dynamic>> tickets;
  final Map<String, dynamic> booking;
  const ExtendCheckout({super.key, required this.location,required this.type, required this.tickets,
    required this.price, required this.image, required this.booking});

  _StateExtendCheckout createState() => _StateExtendCheckout();
}
class _StateExtendCheckout extends State<ExtendCheckout> {

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
    }
  }
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tickets = widget.tickets;
    final extendPaymentTickets = tickets.where((ticket) => ticket['status'] == 'EXTEND_PAYMENT_REQUIRED' || ticket['status'] == 'PAYMENT_REQUIRED').toList();
    final totalPrice = extendPaymentTickets.fold<double>(
      0,
          (sum, ticket) => sum + (ticket['price'] ?? 0),
    );

    debugPrint("ticketsss $tickets", wrapWidth: 1024);
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => const RootPage(initialIndex: 1),
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
                )
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
                              width: MediaQuery.of(context).size.width * 0.24,
                              height: MediaQuery.of(context).size.height * 0.10,
                              child: Image.network(
                                widget.image,
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
                                        widget.location,
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
                                              widget.type,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  height: 2,
                                                  color: Colors.black54
                                              ),

                                              overflow: TextOverflow.ellipsis, // Chữ quá dài sẽ được rút gọn
                                            ),
                                            // Text(
                                            //   "${station['distance'] != null ? (station['distance'] >= 1 ? "${station['distance'].toStringAsFixed(1)}km" : "${(station['distance'] * 1000).toInt()}m") : 'Unknown'}",
                                            //   style: TextStyle(
                                            //       fontSize: 14,
                                            //       fontWeight: FontWeight.w400,
                                            //       height: 2,
                                            //       color: Colors.black54
                                            //   ),
                                            //
                                            //   overflow: TextOverflow.ellipsis, // Chữ quá dài sẽ được rút gọn
                                            // ),
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

                      SizedBox(height: 13),
                      ...extendPaymentTickets.map((ticket) {
                        final String ticketStatus = ticket['status'];
                        print("tickett2 $ticket");
                        final DateTime start = DateTime.parse(ticket['startDateTime']);
                        final DateTime end = DateTime.parse(ticket['endDateTime']);
                        final int totalMinutes = end.difference(start).inMinutes;

                        final String formattedDuration = totalMinutes.toString();
                        return ticketStatus != 'PAYMENT_EXPIRED'
                            ? Column(
                          children: [
                            Container(
                              margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              height: 1,
                              //width: double.infinity,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 8),
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              child: Row(
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
                                          color: ticketStatus == "CONFIRMED" ? Color(0xFFE1F5FF) : Color(0xFF44336),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          _swStatus(ticketStatus),
                                          style: TextStyle(
                                            color: ticketStatus == "CONFIRMED" ? Color(0xFF0075C8) : Color(0xFFB3261E),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(formattedDuration+" min", style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black54, fontSize: 14)),
                                    ],
                                  ),
                                ],
                              ),
                            )

                          ],
                        )
                            : SizedBox.shrink();
                      }).toList(),
                      Container(
                        margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        height: 1,
                        //width: double.infinity,
                        color: Colors.grey[300],
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
                                Text(
                                  "\$${totalPrice}",
                                  style: TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF00B150)
                                  ),
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
            )
          )
        ),
      bottomNavigationBar: Container(

          height: MediaQuery.of(context).size.height * 0.17,
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
                  //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const Promo()));
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
                    Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) => ExtendPayment(
                          booking: widget.booking,
                          price: totalPrice,
                          type: 'EXTEND'
                        )));
                  },
                  style: ElevatedButton.styleFrom(

                    backgroundColor: Color(0xFF00B150), // Màu nền cho nút
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Bo tròn nút
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 170, vertical: 8), // Padding cho nút
                  ),
                  child: Text(
                    "PAY",
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