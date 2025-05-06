import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parking_project/screen/checkout/ui/add_bank.dart';
import 'package:parking_project/screen/profile/ui/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/login_screen.dart';

class ChangePass extends StatelessWidget {


  const ChangePass({super.key});



  @override
  Widget build(BuildContext context) {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();

    Future<void> changePass() async {
      String oldPass = oldPassController.text;
      String newPass = newPassController.text;
      if (oldPass.isEmpty || newPass.isEmpty) {

        Fluttertoast.showToast(
          msg: "Please enter require field!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      try{
        final rs = await Dio().post(
          "http://18.182.12.54:8080/identity/users/change-password",
          data: {
            "oldPassword": oldPass,
            "newPassword": newPass,
          },
          options: Options(
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          ),
        );
        Fluttertoast.showToast(
          msg: "Change password success!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );

      }catch(e){
        print("err $e");
        Fluttertoast.showToast(
          msg: "Error, please try again!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }


    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Nút quay lại
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const Settings(),
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
                    "Change Password",
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
                "Old Password",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: oldPassController,

                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  hintText: "",
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "New Password",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: newPassController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  hintText: "",
                ),

              ),

              const SizedBox(height: 20),

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
                    changePass();
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
                    "Update",
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
