
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parking_project/screen/checkout/checkout_screen.dart';
import 'package:parking_project/screen/checkout/ui/add_bank.dart';
import 'package:parking_project/screen/checkout/ui/add_credit_card.dart';

class PaymentMethod extends StatefulWidget {
  const PaymentMethod({super.key});

  @override
  _StatePaymentMethod createState() => _StatePaymentMethod();
}
class _StatePaymentMethod extends State<PaymentMethod>{
  bool _isChecked1 = false;
  bool _isChecked2 = false;
  String? selectedValue;
  bool isExpanded = false;
  bool isExpanded1 = false;
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
                          // Navigator.pushAndRemoveUntil(
                          //   context,
                          //   PageRouteBuilder(
                          //     pageBuilder: (context, animation, secondaryAnimation) => const CheckoutScreen(),
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
                          //     (route) => route.isFirst
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

                  child:
                    ExpansionTile(
                      title: Padding(
                        padding: EdgeInsets.fromLTRB(8,10,8,10),
                        child: Row(
                          children: <Widget>[
                            SvgPicture.asset('lib/assets/images/icons/wallet.svg',width: 25,height: 25,), // Biểu tượng ví
                            SizedBox(width: 8),
                            Text(
                              'Wallets', // Tiêu đề
                              style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      // Biểu tượng ví
                      trailing: SvgPicture.asset(isExpanded
                          ? 'lib/assets/images/icons/arrow-up.svg'
                          : 'lib/assets/images/icons/arrow-down.svg'),
                      onExpansionChanged: (expanded) {
                        setState(() {
                          isExpanded = expanded;
                        });
                      },
                      children: <Widget>[

                        Padding(
                            padding: EdgeInsets.fromLTRB(46, 0, 46, 10),

                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                            'lib/assets/images/icons/logo_mbbank.svg'
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'MB',
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
                                          selectedValue = 'MB';
                                        });
                                      },
                                      child: Container(
                                        width: 20.0,
                                        height: 20.0,
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
                                    ),


                                  ],
                                ),
                                Container(
                                  height: 1,
                                  color: Color(0xFFE6E6E6),
                                )
                              ],
                            )


                        ),
                        ListTile(
                          title: Text('+ Add linked bank account'),
                          textColor: Color(0xFF00B150),
                          onTap: () {
                            // Hành động thêm tài khoản ngân hàng
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const AddBank()));
                          },
                        ),
                      ],
                    ),
                  )




                ),
              SizedBox(height: 19),
              Padding(
                  padding: EdgeInsets.fromLTRB( 16,0,16,0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFE6E6E6),width: 2),
                      borderRadius: BorderRadius.circular(8.0),

                    ),

                    child:
                    ExpansionTile(
                      title: Padding(
                        padding: EdgeInsets.fromLTRB(8,10,8,10),
                        child: Row(
                          children: <Widget>[
                            SvgPicture.asset('lib/assets/images/icons/card.svg',width: 25,height: 25,), // Biểu tượng ví
                            SizedBox(width: 8),
                            Text(
                              'Visa / Credit card', // Tiêu đề
                              style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      // Biểu tượng ví
                      trailing: SvgPicture.asset(isExpanded1
                          ? 'lib/assets/images/icons/arrow-up.svg'
                          : 'lib/assets/images/icons/arrow-down.svg'),
                      onExpansionChanged: (expanded) {
                        setState(() {
                          isExpanded1 = expanded;
                        });
                      },
                      children: <Widget>[

                        Padding(
                          padding: EdgeInsets.fromLTRB(46, 0, 46, 10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          'lib/assets/images/icons/visa.svg',
                                          width: 15,
                                          height: 15,
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Vietnam Prosperity Joint Stock Commercial Bank',
                                            style: TextStyle(
                                              fontSize: 16,
                                              height: 1.5,
                                            ),
                                            maxLines: 2, // Giới hạn hiển thị tối đa 1 dòng
                                            overflow: TextOverflow.ellipsis, // Hiển thị "..." nếu văn bản bị cắt
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isChecked2 = !_isChecked2;
                                        selectedValue = 'Vietnam Prosperity Joint Stock Commercial Bank';
                                      });
                                    },
                                    child: Container(
                                      width: 20.0,
                                      height: 20.0,
                                      decoration: BoxDecoration(
                                        color: _isChecked2 ? Color(0xFF00B150) : Colors.transparent,
                                        border: Border.all(color: _isChecked2 ? Color(0xFF00B150) : Colors.grey),
                                        borderRadius: BorderRadius.circular(18.0),
                                      ),
                                      child: _isChecked2
                                          ? Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 18.0,
                                      )
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Container(
                                height: 1,
                                color: Color(0xFFE6E6E6),
                              ),
                            ],
                          ),
                        ),

                        ListTile(
                          title: Text('+ Add Credit/Debit Card'),
                          textColor: Color(0xFF00B150),
                          onTap: () {
                            // Hành động thêm tài khoản ngân hàng
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const AddCreditCard()));
                          },
                        ),
                      ],
                    ),
                  )




              )],


          ),
        ),

      ),
    );
  }
}