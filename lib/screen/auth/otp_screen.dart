
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:parking_project/screen/auth/create_account.dart';
import 'package:parking_project/screen/auth/login_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key,required this.email});


  @override
  _StateOtpScreen createState() => _StateOtpScreen();
}

class _StateOtpScreen extends State<OtpScreen> {
  late Timer _timer;
  int _remainingSeconds = 300; // 2 phút = 120 giây
  final otpController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    resendOtp();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  void sendOTP () async {
    final otpCode = otpController.text.trim();
    print("OTP"+otpCode);

    if (otpCode.isEmpty || otpCode.length < 4) {
      Fluttertoast.showToast(
        msg: "Please enter a valid OTP code!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    setState(() {
      isLoading = true;
    });

    try {
      Dio dio = Dio();
      final response = await dio.post(
        'http://18.182.12.54:8080/identity/users/verify-otp',
        data: {
          "email": widget.email,
          "otp": otpCode,
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {

        Fluttertoast.showToast(
          msg: "OTP verification successful! Please log in now.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Color(0xFF00B150),
          textColor: Colors.white,
          fontSize: 16.0,
        );


        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false, // Xóa toàn bộ lịch sử điều hướng
          );
        });
      } else {
        Fluttertoast.showToast(
          msg: "OTP verification failed:",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } on DioException catch (e) {
      Fluttertoast.showToast(
        msg: "OTP verification failed:",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
  }

  }

  void resendOtp() async {
    try {
      Dio dio = Dio();
      final response = await dio.post(
        'http://18.182.12.54:8080/identity/users/resend-otp?email=${widget.email}',
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {

      } else {
        Fluttertoast.showToast(
          msg: "OTP verification failed:",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } on DioException catch (e) {
      Fluttertoast.showToast(
        msg: "OTP verification failed:",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }


  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  void dispose() {
    _timer.cancel();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 73, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const CreateAccount(),
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
                    const Spacer(),
                    const Text(
                      "OTP Verification",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),


                const SizedBox(height: 48),
                const Text(
                  "We have send an OTP on given email",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${widget.email}",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 8,
                  children: [
                    SvgPicture.asset(
                    'lib/assets/images/icons/time_circle.svg',
                    width: 18,
                    height: 18,
                    color: Color(0xFFF43939),
                    ),
                    Text(
                      "${_formatTime(_remainingSeconds)}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFF43939),
                      ),
                    ),

                    const SizedBox(height: 16),
                    if(_remainingSeconds == 0)
                      ElevatedButton(
                        onPressed: _remainingSeconds == 0
                            ? () {
                          resendOtp();
                          // Action to resend OTP
                          setState(() {
                            _remainingSeconds = 300; // Reset the timer
                            _startTimer();
                          });
                        }
                            : null,
                        child: const Text("Resend OTP"),
                      ),


                  ],
                ),
                const SizedBox(height: 62),
                // OTP Input Field
                PinCodeTextField(
                  appContext: context,
                  length: 4,
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  pinTheme: PinTheme(

                    fieldHeight: 60,
                    fieldWidth: 60,
                    activeColor: Colors.green,
                    inactiveColor: Colors.grey,
                    selectedColor: Color(0xFFF43939),
                    borderWidth: 1.5,
                    fieldOuterPadding: EdgeInsets.all(10),
                  ),
                  onChanged: (value) {},
                  onCompleted: (value) {
                    // Perform action after OTP is completed (e.g., verify OTP)
                  },
                ),



                const SizedBox(height: 250),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      sendOTP();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      backgroundColor: const Color(0xFF00B150),
                    ),
                    child:
                    isLoading ?
                    LoadingAnimationWidget.beat(
                        color: Colors.white, size: 30) :
                    Text(
                      "Send",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
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
                            'Login now',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
