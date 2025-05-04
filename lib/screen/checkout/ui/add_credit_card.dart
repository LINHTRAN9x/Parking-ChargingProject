import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parking_project/screen/checkout/ui/add_bank.dart';
import 'package:parking_project/screen/checkout/ui/payment_method.dart';

class AddCreditCard extends StatelessWidget {

  const AddCreditCard({super.key});

  @override
  Widget build(BuildContext context) {
    final expiryDateController = TextEditingController();
    final ccvController = TextEditingController();
    final cardNumberController = TextEditingController();
    final cardNameController = TextEditingController();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const PaymentMethod(),
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
                            (route) => route.isFirst,
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
                  Text(
                    "Add Credit/Debit Card",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              Container(
                padding: EdgeInsets.all(20.0),
                color: Color(0xFFE5F5E9),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 10.0,
                      children: [
                        SvgPicture.asset("lib/assets/images/icons/shield-tick.svg"),
                        Column(
                          children: [
                            const Text(
                              "Your card information is secure",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color: Color(0xFF00B150)),
                            ),
                          ],
                        )

                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 35.0),
                      child: Text(
                        "Your card details are protected with advanced encryption technology",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                      ),
                    )

                  ],
                ),
              ),
              


              const SizedBox(height: 20),
              const Text(
                "Card number",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: cardNumberController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  hintText: "Enter your card number",
                ),

              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  /// Expiry Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Expiry date (MM/YY)",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: expiryDateController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(32)),
                            ),
                            hintText: "Exp. date",
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// CCV
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "CCV",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: ccvController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(32)),
                            ),
                            hintText: "Ex: 243",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Text(
                "Card holder name",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: cardNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  hintText: "Full name or cardholder",
                ),
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
                    //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const PaymentMethod()));
                  },
                  style: ElevatedButton.styleFrom(

                    backgroundColor: Color(0xFF00B150), // Màu nền cho nút
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Bo tròn nút
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 150, vertical: 8), // Padding cho nút
                  ),
                  child: Text(
                    "Add card",
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
