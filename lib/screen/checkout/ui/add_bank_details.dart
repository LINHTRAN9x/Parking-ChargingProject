import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parking_project/screen/checkout/ui/add_bank.dart';

class AddBankDetails extends StatelessWidget {
  final String bankName;

  const AddBankDetails({super.key, required this.bankName});

  @override
  Widget build(BuildContext context) {
    final conectionMethodController = TextEditingController();
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
              /// ⬅️ Nút quay lại
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const AddBank(),
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
                    bankName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                "Connection method",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: conectionMethodController,

                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  hintText: "Card number",
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
              const SizedBox(height: 40),
              const Text(
                "Preconditions for Linking",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              const Text(
                "Customers must have an active Bank account or card and provide complete personal information such as ID/Passport and registered phone number.",
                style: TextStyle(fontSize: 13,color: Colors.black54),
              ),

              const SizedBox(height: 20),
              const Text(
                "Bank Verification",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              const Text(
                "Bank verifies the account or card status and personal details to ensure eligibility for linking.",
                style: TextStyle(fontSize: 13,color: Colors.black54),
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
