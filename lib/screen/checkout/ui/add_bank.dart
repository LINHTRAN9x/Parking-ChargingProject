import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parking_project/screen/checkout/ui/add_bank_details.dart';
import 'package:parking_project/screen/checkout/ui/payment_method.dart';

class AddBank extends StatelessWidget {
  const AddBank({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> banks = [
      {"id": 1, "name": "TPBank", "image": "lib/assets/images/icons/tp-bank.png"},
      {"id": 2, "name": "BIDV", "image": "lib/assets/images/icons/bidv-bank.png"},
      {"id": 3, "name": "Techcombank", "image": "lib/assets/images/icons/techcombank.png"},
      {"id": 5, "name": "MB Bank", "image": "lib/assets/images/icons/mb-bank.png"},
      {"id": 9, "name": "Sacombank", "image": "lib/assets/images/icons/sacombank.png"},
      {"id": 6, "name": "Agribank", "image": "lib/assets/icons/agribank.png"},
      {"id": 7, "name": "VietinBank", "image": "lib/assets/icons/vietinbank.png"},
      {"id": 10, "name": "Shinhan Bank", "image": "lib/assets/icons/shinhan-bank.png"},
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 20, 0),
              child: Row(
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
                  const SizedBox(width: 10),
                  const Text(
                    "Add linked bank account",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // GridView hiển thị danh sách ngân hàng
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5, // 5 ngân hàng trên một hàng
                    crossAxisSpacing: 10, // Khoảng cách ngang giữa các ô
                    mainAxisSpacing: 15, // Khoảng cách dọc giữa các ô
                    childAspectRatio: 0.8, // Tỉ lệ khung hình (chiều rộng / chiều cao)
                  ),
                  itemCount: banks.length,
                  itemBuilder: (context, index) {
                    final bank = banks[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddBankDetails(bankName: bank["name"]),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          // Logo ngân hàng
                          Container(
                            padding: const EdgeInsets.all(0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              bank["image"],
                              width: 60,
                              height: 60,
                              fit: BoxFit.contain,
                            ),
                          ),

                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
