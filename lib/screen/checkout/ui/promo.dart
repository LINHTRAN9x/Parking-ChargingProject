import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parking_project/screen/checkout/checkout_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Promo extends StatefulWidget {
  final List<Map<String, dynamic>> selectedSpots;
  List<Map<String, dynamic>> spots;
  List<String> availableSlots;
  List<String> unavailableSlots;
  final int durationMinutes;
  final List<Map<String, dynamic>> orders;
  Map<String, dynamic> station;
  final String dateStart;
  final String dateEnd;
  Promo({super.key,
    required this.selectedSpots, // Giá trị mặc định là danh sách rỗng
    required this.spots,
    required this.availableSlots,
    required this.orders,
    required this.station,
    required this.durationMinutes,
    required this.unavailableSlots,
    required this.dateStart,
    required this.dateEnd
  });

  @override
  _StatePromo createState() => _StatePromo();
}

class _StatePromo extends State<Promo> {
  int? _selectedIndex;
  Map<String, dynamic>? _selectedVoucher;
  List<dynamic> vouchers = [];
  bool isLoading = false;

  Future<void> getVoucher() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    try{
      var rs = await Dio().get(
        "http://18.182.12.54:8084/payment/vouchers/user/usable?page=0&size=5",
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
      )

      );
      print("Danh sách voucher: ${rs.data['content']}");
      setState(() {
        vouchers = rs.data['content'];
        isLoading = false;
      });
    }catch(e){
      print("Lỗi get voucher: $e");
      isLoading = false;
    }
  }


  @override
  void initState() {
    super.initState();
    getVoucher();

  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _promoCodeController = TextEditingController();


    @override
    void dispose() {
      _promoCodeController.dispose();
      super.dispose();
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 47, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(
                        context,
                        // PageRouteBuilder(
                        //   pageBuilder:
                        //       (context, animation, secondaryAnimation) =>
                        //           const CheckoutScreen(),
                        //   transitionsBuilder:
                        //       (context, animation, secondaryAnimation, child) {
                        //     const begin = Offset(-1.0, 0.0);
                        //     const end = Offset.zero;
                        //     const curve = Curves.easeInOut;
                        //
                        //     var tween = Tween(begin: begin, end: end)
                        //         .chain(CurveTween(curve: curve));
                        //     var offsetAnimation = animation.drive(tween);
                        //
                        //     return SlideTransition(
                        //       position: offsetAnimation,
                        //       child: child,
                        //     );
                        //   },
                        // ),
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
                    "Select Voucher",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Search Box
            SizedBox(
              height: 20,
            ),
            isLoading ?
                Center(child: CircularProgressIndicator()) :
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promoCodeController,
                        decoration: const InputDecoration(
                          hintText: "Enter a promo code",
                          border: InputBorder.none, // Remove underline border
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        // Handle promo code logic
                        String promoCode = _promoCodeController.text.trim();
                        if (promoCode.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Promo code "$promoCode" applied!'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a promo code.'),
                            ),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Use",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            // Vouchers List
            Expanded(
              child: ListView.builder(
                itemCount: vouchers.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final voucher = vouchers[index];
                  final isDisabled = voucher['remainingUsage'] == 0;

                  // Parse ngày hết hạn
                  final expiryDate = DateTime.parse(voucher['validUntil']);
                  final formattedExpiry =
                      "Expiry: ${expiryDate.hour.toString().padLeft(2, '0')}:${expiryDate.minute.toString().padLeft(2, '0')} ${expiryDate.day.toString().padLeft(2, '0')}/${expiryDate.month.toString().padLeft(2, '0')}/${expiryDate.year}";
                  final discountDisplay = voucher['percentage'] == true
                      ? '-${voucher['discountAmount']}%'
                      : '-${voucher['discountAmount']}\$';

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Icon (dùng hình thật nếu muốn)
                            Opacity(
                              opacity: isDisabled ? 0.3 : 1.0,
                              child: Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    voucher['thumbnailUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.card_giftcard, color: Colors.green, size: 24);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Voucher Details
                            Expanded(
                              child:
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Opacity(
                                    opacity: isDisabled ? 0.3 : 1.0,
                                    child: Text(
                                      voucher['title'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),

                                      Opacity(
                                        opacity: isDisabled ? 0.3 : 1.0,
                                        child: Text(
                                          discountDisplay,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Opacity(
                                        opacity: isDisabled ? 0.3 : 1.0,
                                        child: Text(
                                          formattedExpiry,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      // const SizedBox(height: 4),





                                ],
                              ),
                            ),
                            // Radio Button
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_selectedIndex == index) {
                                    _selectedIndex = null;
                                    _selectedVoucher = null;
                                  } else {
                                    _selectedIndex = index;
                                    _selectedVoucher = vouchers[index]; // Lưu lại toàn bộ object voucher
                                  }
                                });
                                print("_seletedVoucher $_selectedVoucher");
                              },
                              child: Container(
                                width: 20.0,
                                height: 20.0,
                                decoration: BoxDecoration(
                                  color: _selectedIndex == index
                                      ? const Color(0xFF00B150)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: _selectedIndex == index
                                        ? const Color(0xFF00B150)
                                        : Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                child: _selectedIndex == index
                                    ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18.0,
                                )
                                    : null,
                              ),
                            )
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                          height: 1,
                          color: const Color(0xFFE6E6E6),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 106,
        padding: EdgeInsets.all(10),
        // Màu nền cho container
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Màu bóng mờ
              offset: Offset(0, 1), // Vị trí bóng
              blurRadius: 6, // Độ mờ của bóng
            )
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15), // Bo tròn góc trên bên trái
            topRight: Radius.circular(15), // Bo tròn góc trên bên phải
          ),
        ),
        child: Align(
          alignment: Alignment(0, -0.7),
          child: ElevatedButton(
            onPressed: () {
              // Logic cho khi nút Next được nhấn

              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>CheckoutScreen(
                  selectedSpots: widget.selectedSpots.isNotEmpty ? widget.selectedSpots : [],
                  spots: widget.spots,
                  availableSlots: widget.availableSlots,
                  orders: widget.orders,
                  station: widget.station,
                  durationMinutes: widget.durationMinutes,
                  unavailableSlots: widget.unavailableSlots,
                  dateStart: widget.dateStart,
                  dateEnd: widget.dateEnd,
                  voucher: _selectedVoucher
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
              "Use",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white, // Màu chữ của nút
              ),
            ),
          ),
        ),
      ),
    );
  }
}
