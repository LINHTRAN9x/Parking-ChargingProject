import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parking_project/screen/auth/login_screen.dart';
import 'package:parking_project/screen/auth/otp_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});
  @override
  _StateCreateAccount createState() => _StateCreateAccount();
}

class _StateCreateAccount extends State<CreateAccount> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final rePasswordController = TextEditingController();
  bool _hidePassword = true;
  bool isLoading = false;
  bool isEmailValid = true;


  // Kiểm tra định dạng email hợp lệ
  bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }
  bool isValidPassword(String password) {
    return RegExp(r'^(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,}$').hasMatch(password);
  }

  void create() async {
    final email = emailController.text;
    final password = passwordController.text;
    final rePassword = rePasswordController.text;


    if (!isValidEmail(email)) {
      Fluttertoast.showToast(
        msg: "Invalid email or password!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER, // Hiển thị ở giữa màn hình
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    if (!isValidPassword(password)) {
      Fluttertoast.showToast(
        msg: "The password must be at least 8 characters long, with one uppercase letter and one number!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    if (password != rePassword) {
      Fluttertoast.showToast(
        msg: "Passwords do not match!",
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
        'http://18.182.12.54:8080/identity/users',
        data: {
          "email": email,
          "password": password,
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        // Đăng ký thành công, chuyển sang màn hình OTP
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OtpScreen(email:email)),
        );
      }
      else {
        String errorMessage = 'Có lỗi xảy ra. Vui lòng thử lại.';

        if (response.data != null && response.data is Map<String, dynamic>) {
          String apiMessage = response.data['message'] ?? '';
          print("HHHHHHHH" + apiMessage);

          if (apiMessage == 'User existed') {
            // Nếu tài khoản đã tồn tại, chuyển hướng sang màn hình OTP
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OtpScreen(email: email)),
            );
            return; // Không hiển thị lỗi nữa
          } else {
            errorMessage = apiMessage;
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.statusCode == 400) {
        // Lấy message từ API
        String apiMessage = e.response?.data['message'] ?? '';

        if (apiMessage == 'User existed') {
          // Nếu tài khoản đã tồn tại, chuyển sang màn hình OTP
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OtpScreen(email: email)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(apiMessage)),
          );
        }
      } else {
        // Lỗi không xác định
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register: ${e.message}')),
        );
      }

      print('Error: *********************************************************** ${e.message}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
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

                const SizedBox(height: 20),
                const Text(
                  "Register an account",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Connect with your friends today!",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                      borderSide: BorderSide(
                        color: Colors.red
                      )
                    ),
                    labelText: "Enter email"
                  ),
                  onChanged: (value) {
                    setState(() {
                      isEmailValid = isValidEmail(value);
                    });
                  },
                ),
                if (!isEmailValid)
                  Padding(
                    padding: const EdgeInsets.only(top: 5, left: 10),
                    child: Text(
                      "The email format is incorrect",
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),

                const SizedBox(height: 24),
                TextField(
                  controller: passwordController,
                  obscureText: _hidePassword,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                    ),
                    labelText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _hidePassword = !_hidePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: rePasswordController,
                  obscureText: _hidePassword,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                    ),
                    labelText: "Re-password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _hidePassword = !_hidePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      create();
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
                        "Sign up",
                        style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 250),
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


