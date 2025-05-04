import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parking_project/screen/auth/login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0; // Vị trí hiện tại của trang
  late Timer _autoScrollTimer;

  List<String> images = [
    'lib/assets/images/welcome_1.png',
    'lib/assets/images/welcome_2.png', 
    'lib/assets/images/welcome_3.png',
  ];

  List<String> texts = [
    'Welcome', // Văn bản cho ảnh 1
    'Hollaaa', // Văn bản cho ảnh 2
    'Find Parking'
  ];
  List<String> caption = [
    'Find a best possible way to park',
    'Find the best possible parking space nearby your desired destination',
    'Find your perfect parking space wherever and whenever you need'
  ];
  @override
  void initState() {
    super.initState();

    // Khởi tạo Timer để tự động chuyển trang
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }
  @override
  void dispose() {
    // Hủy Timer khi widget bị hủy
    _autoScrollTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(0, 50, 20, 0),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Color(0xFF00B150),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Thay thế Expanded bằng Container với chiều cao cố định
                  Container(
                    height: 430, // Điều chỉnh chiều cao của phần PageView
                    margin: EdgeInsets.fromLTRB(0, 42, 0, 84),
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Column(
                      children: [
                        // PageView.builder
                        Expanded(

                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: images.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index; // Cập nhật vị trí hiện tại khi vuốt
                              });
                            },
                            itemBuilder: (context, index) {
                              return SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      images[index],
                                      width: 398,
                                      height: 218,
                                    ),
                                    const SizedBox(height: 106),
                                    Text(
                                      texts[index],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      caption[index],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },

                          ),
                        ),

                        // Dấu chấm ở dưới thanh trượt
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(images.length, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),

                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              height: 8,
                              width: 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? const Color(0xFF00B150)
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nút đăng nhập Google
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: SizedBox(
                      width: double.infinity, // Chiều rộng tối đa
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          // Thực hiện hành động đăng nhập qua Google
                          print("Login with Google");
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFE6E6E6), // Màu nền cho nút Google
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            elevation: 0
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Căn giữa nội dung
                          children: [
                            SvgPicture.asset(
                              'lib/assets/images/icons/google.svg', // Đường dẫn tới icon

                            ),
                            const SizedBox(width: 10), // Khoảng cách giữa icon và text
                            const Text(
                              'Login with Google',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Nút đăng nhập Facebook
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: SizedBox(
                      width: double.infinity, // Chiều rộng tối đa
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          // Thực hiện hành động đăng nhập qua Google
                          print("Login with Facebook");
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFE6E6E6), // Màu nền cho nút Google
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            elevation: 0
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Căn giữa nội dung
                          children: [
                            SvgPicture.asset(
                              'lib/assets/images/icons/facebook.svg', // Đường dẫn tới icon

                            ),
                            const SizedBox(width: 10), // Khoảng cách giữa icon và text
                            const Text(
                              'Login with Google',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ],

                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 45),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0), // Điều chỉnh padding cho phù hợp
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Căn giữa theo chiều ngang
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Color(0xFF00B150),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),


                ],
              ),
            ),
          )

      )

    );
  }
}
