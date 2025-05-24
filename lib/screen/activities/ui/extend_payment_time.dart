import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parking_project/main.dart';
import 'package:parking_project/screen/checkout/checkout_screen.dart';
import 'package:parking_project/screen/checkout/ui/add_bank.dart';
import 'package:parking_project/screen/checkout/ui/add_credit_card.dart';
import 'package:parking_project/screen/checkout/ui/booking_success.dart';
import 'package:parking_project/screen/checkout/ui/payment_method.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../root_page.dart';
//import 'package:vnpay_flutter/vnpay_flutter.dart';

class ExtendPaymentTime extends StatefulWidget {
  final Map<String, dynamic> booking;
  final double price;
  final String type;
  ExtendPaymentTime({super.key,
    required this.booking,
    required this.price, required this.type
  });

  @override
  _StateExtendPayment createState() => _StateExtendPayment();
}
class _StateExtendPayment extends State<ExtendPaymentTime>{
  bool _isChecked1 = false;
  bool _isChecked2 = false;
  String responseCode = '';

  double convertVNDToUSD(double vndAmount) {
    double exchangeRate = 25000.0;
    return vndAmount / exchangeRate;
  }

  Future<String?> getPayPalToken() async {
    String clientId = "Af236NCNep6PNvqW-JMvdG_zeyLhL8nfZcmZsa16eoyMAlE2pOnphjfFkrZl_I2nbT_8xCPKLJDY3rwj";
    String secretKey = "EBeNaDaZNDHwi_gDDKKIK1313WMmu304dXfL7trEJxuszEcTRHmWivqvHeHHuBosHARCWeIUQQHVJ2HH";
    try {
      var response = await Dio().post(
        "https://api.sandbox.paypal.com/v1/oauth2/token",
        data: {"grant_type": "client_credentials"},
        options: Options(
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/x-www-form-urlencoded",
            "Authorization": "Basic " + base64Encode(utf8.encode("$clientId:$secretKey")),
          },
        ),
      );

      return response.data["access_token"];
    } catch (e) {
      print("Lỗi lấy PayPal Token: $e");
      return null;
    }
  }

  void processPayment(BuildContext context) {
    //double totalVND = widget.orders.fold(0, (sum, order) => sum + (order['finalPrice'] ?? order['price']));
    if (widget.booking.isEmpty) {
      print("Không có đơn hàng nào để thanh toán.");
      return;
    }

    double totalUSD = widget.price;

    var now = DateTime.now().millisecondsSinceEpoch;
    var i = "${widget.booking["id"]}_$now";


    final order = widget.booking['booking'];
    print("orderr $order");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => UsePaypal(
          sandboxMode: true,
          clientId: "Af236NCNep6PNvqW-JMvdG_zeyLhL8nfZcmZsa16eoyMAlE2pOnphjfFkrZl_I2nbT_8xCPKLJDY3rwj",
          secretKey: "EBeNaDaZNDHwi_gDDKKIK1313WMmu304dXfL7trEJxuszEcTRHmWivqvHeHHuBosHARCWeIUQQHVJ2HH",
          returnURL: "https://samplesite.com/return",
          cancelURL: "https://samplesite.com/cancel",
          transactions: [
            {
              "amount": {
                "total": totalUSD.toStringAsFixed(2),
                "currency": "USD",
                "details": {
                  "subtotal": totalUSD.toStringAsFixed(2),
                  "shipping": "0",
                  "handling_fee": "0",
                  "tax": "0",
                  "shipping_discount": "0"
                }
              },
              "description": "Thanh toán đặt chỗ đậu xe",
              "invoice_number": i
            }
          ],
          note: "Cảm ơn bạn đã sử dụng dịch vụ!",
          onSuccess: (Map params) async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? token = prefs.getString('access_token');
            print("Thanh toán thành công: $params");
            if (!navigatorKey.currentState!.mounted) return;
            String paymentId = params['paymentId'];
            String? paypalToken = await getPayPalToken();
            // String paypalToken = "A21AAKd9mY0lHa4A3_TfjFWFdxtnbwM6S9amYDUo7w3CBLFGwv5jNWLnNqYfq7EV1wQyMeTe2lk86I4JysU9vhWwcp-ZWNuow";
            bool isPaymentCheck = false;
            try {
              var rs = await Dio().get(
                "https://api.sandbox.paypal.com/v1/payments/payment/$paymentId",
                options: Options(
                  headers: {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer $paypalToken",
                  },
                ),
              );

              var paymentData = rs.data;
              var payerId = paymentData['payer']['payer_info']['payer_id'];
              print("✅ Payer ID: $payerId");


              if (order.isNotEmpty) {
                var bookingId = order['id'];
                print("bookingIdd $bookingId");
                var initialPrice = paymentData["transactions"][0]["amount"]["total"];
                var totalAmount = paymentData["transactions"][0]["amount"]["total"];
                var transactionFee = paymentData["transactions"][0]["related_resources"][0]["sale"]["transaction_fee"]["value"];

                var response = await Dio().post(
                  "http://18.182.12.54:8084/payment/payments/verify",
                  data: {
                    "bookingId": bookingId,
                    "voucherId": "",
                    "type" : widget.type,
                    "initialPrice": initialPrice,  // Ép kiểu an toàn
                    "payPalPaymentDto": {
                      "paymentId": paymentData["id"],
                      "saleId": paymentData["transactions"][0]["related_resources"][0]["sale"]["id"],
                      "payerId": payerId,
                      "buyerEmail": paymentData["payer"]["payer_info"]["email"],
                      "merchantId": paymentData["transactions"][0]["payee"]["merchant_id"],
                      "totalAmount": initialPrice,  // Ép kiểu an toàn
                      "transactionFee": transactionFee,  // Ép kiểu an toàn
                      "currency": paymentData["transactions"][0]["amount"]["currency"],
                      "refundUrl": paymentData["transactions"][0]["related_resources"][0]["sale"]["links"][1]["href"],
                      "transactionTime": paymentData["create_time"],
                    }
                  },
                  options: Options(
                    headers: {
                      "Content-Type": "application/json",
                      "Authorization": "Bearer $token",
                    },
                  ),
                );

                print("API Response: ${response.data}");
                setState(() {
                  isPaymentCheck = true;
                });
              }
              else {
                print("Lỗi: order rỗng!");
                isPaymentCheck = false;
              }
            } catch (e) {
              print("Lỗi khi xác nhận thanh toán: $e");
              isPaymentCheck = false;
              Fluttertoast.showToast(
                msg: "You Payment Is Not Complete, please try again!",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER, // Hiển thị ở giữa màn hình
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }


            print("Đang đóng toàn bộ WebView...");

            if (isPaymentCheck == true) {
              navigatorKey.currentState?.pushReplacement(
                MaterialPageRoute(builder: (context) => BookingSuccess(bookingId: order['id'],type: order['type'],totalUSD : totalUSD)),
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => BookingSuccess(bookingId: order['id'],type: order['type'],totalUSD : totalUSD)),
              );
            }else{
              if (navigatorKey.currentState?.mounted == true) {
                navigatorKey.currentState?.pushReplacement(
                  MaterialPageRoute(builder: (context) => BookingSuccess(bookingId: order['id'],type: order['type'],totalUSD : totalUSD)),
                );
              }
            }
          },

          onError: (error) {
            print("Lỗi thanh toán: $error");
            navigatorKey.currentState?.pop(context);

            Navigator.pop(context);
            Fluttertoast.showToast(
              msg: "You Payment Is Not Complete, please try again!",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER, // Hiển thị ở giữa màn hình
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          },
          onCancel: () {
            print("Người dùng đã hủy thanh toán");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Thanh toán đã bị hủy!")),
            );
          },
        ),
      ),
    );
  }
  // Future<void> onPayment() async {
  //   double totalVND = widget.orders.fold(0, (sum, order) => sum + (order['finalPrice'] ?? order['price']));
  //   double totalUSD = convertVNDToUSD(totalVND);
  //   final paymentUrl = VNPAYFlutter.instance.generatePaymentUrl(
  //     url: 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html', //vnpay url, default is https://sandbox.vnpayment.vn/paymentv2/vpcpay.html
  //     version: '2.0.1',
  //     tmnCode: 'R6B5TKFO', //vnpay tmn code, get from vnpay
  //     txnRef: DateTime.now().millisecondsSinceEpoch.toString(),
  //     orderInfo: 'Payment with VNPAY', //order info, default is Pay Order
  //     amount: totalVND,
  //     returnUrl: 'https://samplesite.com/return', //https://sandbox.vnpayment.vn/apis/docs/huong-dan-tich-hop/#code-returnurl
  //     ipAdress: '192.168.10.10',
  //     vnpayHashKey: 'BKS5JM3WN28OQ98R5DS3L11K9TQBBGII', //vnpay hash key, get from vnpay
  //     vnPayHashType: VNPayHashType.HMACSHA512, //hash type. Default is HMACSHA512, you can chang it in: https://sandbox.vnpayment.vn/merchantv2,
  //     vnpayExpireDate: DateTime.now().add(const Duration(hours: 1)),
  //   );
  //   await VNPAYFlutter.instance.show(
  //     paymentUrl: paymentUrl,
  //     onPaymentSuccess: (params) {
  //       setState(() {
  //         responseCode = params['vnp_ResponseCode'];
  //         print("responseCode $responseCode");
  //       });
  //     },
  //     onPaymentError: (params) {
  //       setState(() {
  //         responseCode = params['vnp_ResponseCode'];
  //         print("responseCode $responseCode");
  //       });
  //     },
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
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
                            Navigator.pushAndRemoveUntil(
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
                                    (route) => route.isFirst
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
                            "Payment Method" ,
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
                    padding: EdgeInsets.fromLTRB( 16,0,16,0),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Payment Method",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const PaymentMethod()));
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        "View all",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF00B150)
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      SvgPicture.asset(
                                        "lib/assets/images/icons/arrow_right.svg"
                                        ,width: null
                                        ,height: null,)
                                    ],
                                  ),
                                )

                              ],
                            ),
                          ),
                          Container(
                            color: Color(0xFFE6E6E6),
                            height: 1,
                            margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                        'lib/assets/images/icons/wallet.svg'
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Wallets',
                                      style: TextStyle(
                                          fontSize: 16,
                                          height: 3
                                      ),
                                    )
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isChecked1 = !_isChecked1;
                                    });
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width  * 0.047,
                                    height: MediaQuery.of(context).size.height * 0.02,
                                    decoration: BoxDecoration(
                                      color: _isChecked1 ? Color(0xFF00B150) : Colors.transparent, // Màu nền khi checked
                                      border: Border.all(color: _isChecked1 ? Color(0xFF00B150) : Colors.grey), // Màu viền khi checked
                                      borderRadius: BorderRadius.circular(18.0), // Tạo bo tròn cho checkbox
                                    ),
                                    child: _isChecked1
                                        ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 18.0,
                                    )
                                        : null,
                                  ),
                                )

                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: EdgeInsets.fromLTRB(16,0,16,16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                        'lib/assets/images/icons/card.svg'
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Visa / Credit card',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    )
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isChecked2 = !_isChecked2;
                                    });
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width  * 0.047,
                                    height: MediaQuery.of(context).size.height * 0.02,
                                    decoration: BoxDecoration(
                                      color: _isChecked2 ? Color(0xFF00B150) : Colors.transparent, // Màu nền khi checked
                                      border: Border.all(color: _isChecked2 ? Color(0xFF00B150) : Colors.grey), // Màu viền khi checked
                                      borderRadius: BorderRadius.circular(18.0), // Tạo bo tròn cho checkbox
                                    ),
                                    child: _isChecked2
                                        ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 18.0,
                                    )
                                        : null,
                                  ),
                                )

                              ],
                            ),
                          ),
                          // Padding(
                          //   padding: EdgeInsets.all(16.0),
                          //   child: Column(
                          //     children: [
                          //       ElevatedButton(
                          //         onPressed: () => processPayment(context),
                          //         child: Text("Thanh toán bằng PayPal"),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Padding(
                            padding: EdgeInsets.all(5.0),
                            child: SizedBox(
                              width: 350,
                              child: FloatingActionButton.extended(
                                onPressed: () => processPayment(context),
                                backgroundColor: Colors.blue[600],
                                icon: const Icon(Icons.paypal, color: Colors.white),
                                label: const Text(
                                  'Pay with PayPal',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),

                          ),
                          // Padding(
                          //   padding: const EdgeInsets.all(10.0),
                          //   child: SizedBox(
                          //     width: 350,
                          //     child: FloatingActionButton.extended(
                          //       onPressed: onPayment,
                          //       backgroundColor: Colors.pink[800],
                          //       icon: const Icon(Icons.payment, color: Colors.white),
                          //       label: const Text(
                          //         'Pay with VN Pay',
                          //         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          //       ),
                          //     ),
                          //   ),
                          //
                          // )
                        ],
                      ),
                    )
                )
              ]


          ),
        ),

      ),
    );
  }
}