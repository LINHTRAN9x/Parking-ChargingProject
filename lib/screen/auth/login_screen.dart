
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parking_project/root_page.dart';
import 'package:parking_project/screen/auth/create_account.dart';
import 'package:parking_project/screen/auth/welcome_screen.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});
  @override
  _StateLogin createState() => _StateLogin();
}
class _StateLogin extends State<LoginScreen>{
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _hidePassword = true;
  bool isEmailValid = true;
  bool isLoading = false;

  bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }
  bool isValidPassword(String password) {
    return RegExp(r'^(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,}$').hasMatch(password);
  }


  login() async{
    final email = emailController.text;
    final password = passwordController.text;

    if (!isValidEmail(email)) {
      Fluttertoast.showToast(
        msg: "Invalid email.!",
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
    setState(() {
      isLoading = true;
    });
    try {
      Dio dio = Dio();
      final response = await dio.post(
        'http://18.182.12.54:8080/identity/auth/token',
        data: {
          "email": email,
          "password": password,
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        final token = response.data['result']['token'];

        // Lưu token vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        print("token $token");

        // Chuyển đến màn hình chính
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RootPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${response.data['message']}')),
        );
      }
    } on DioException catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Đăng nhập thất bại: ${e.response?.data['message'] ?? e.message}')),
      // );
      print("Dio error: ${e.message}");
      print("Status code: ${e.response?.statusCode}");
      print("Error response data: ${e.response?.data}");
      Fluttertoast.showToast(
        msg: "Login failed.",
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
  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    // This is where you can initialize the resources needed by your app while
    // the splash screen is displayed.  Remove the following example because
    // delaying the user experience is a bad design practice!
    // ignore_for_file: avoid_print
    print('ready in 3...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 2...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 1...');
    await Future.delayed(const Duration(seconds: 1));
    print('go!');
    FlutterNativeSplash.remove();
  }

  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const WelcomeScreen(),
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
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 93, 20, 20),
                    child: SvgPicture.asset(
                      'lib/assets/images/icons/arrow-left.svg',
                      width: 24,
                      height: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0), // Điều chỉnh padding cho phù hợp
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Căn giữa theo chiều ngang
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                        child: Text(
                          "Hi, Welcome Back!",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                        child: Text(
                          "Hello again, you’ve been missed!",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey
                          ),
                        ),
                      )


                    ],
                  ),
                ),
              ),
               SizedBox(height: MediaQuery.of(context).size.height * 0.08),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: TextField(

                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                    ),
                    labelText: "Enter email", // Nhãn hiển thị trên trường nhập
                    //floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  onChanged: (value) {
                    setState(() {
                      isEmailValid = isValidEmail(value);
                    });
                  },

                ),


              ),
              if (!isEmailValid)
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 16), // Đặt padding giống với TextField
                  child: Align(
                    alignment: Alignment.centerLeft, // Căn về bên trái
                    child: Text(
                      "The email format is incorrect.",
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                ),


               SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: TextField(
                  controller: passwordController,
                  obscureText: _hidePassword,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                    ), // Thêm border cho trường nhập liệu
                    labelText: "Password", // Nhãn hiển thị trên trường nhập
                    //loatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _hidePassword = !_hidePassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
               SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 12,
                    children: [
                      Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 4, 0),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isChecked = !_isChecked;
                                      });
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * 0.04,
                                      height: MediaQuery.of(context).size.height * 0.02,
                                      decoration: BoxDecoration(
                                        color: _isChecked ? Color(0xFF00B150) : Colors.transparent,
                                        border: Border.all(color: _isChecked ? Color(0xFF00B150) : Colors.grey),
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                      child: _isChecked
                                          ? Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 18.0,
                                      )
                                          : null,
                                    ),
                                  ),
                                ),

                                Text(
                                  'Remember password',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ]
                          )

                      ),

                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                      child: Text(
                        'Forgot you password?',
                        style: TextStyle(
                          color: Color(0xFF00B150),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],

              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.05,
                  decoration: BoxDecoration(
                    color: Color(0xFF00B150), // Màu nền xanh
                    borderRadius: BorderRadius.circular(50.0), // Bo góc
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      login();
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0, // Loại bỏ bóng
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 5.0), // Padding cho nút
                    ),
                    child:
                    isLoading ?
                    LoadingAnimationWidget.beat(
                        color: Colors.white, size: 30) :
                    Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white, // Màu chữ trắng
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
               SizedBox(height: MediaQuery.of(context).size.height * 0.27),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0), // Điều chỉnh padding cho phù hợp
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Căn giữa theo chiều ngang
                    children: [
                      const Text(
                        "You don't have an account yet?",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CreateAccount()),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Text(
                            'Sign up now.',
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

    );
  }
}