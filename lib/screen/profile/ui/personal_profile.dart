import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parking_project/root_page.dart';
import 'package:parking_project/screen/checkout/ui/add_bank.dart';
import 'package:parking_project/screen/profile/profile_screen.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PersonalProfile extends StatefulWidget {

  const PersonalProfile({super.key});
  _StatePersonalProfile createState() => _StatePersonalProfile();
}

class _StatePersonalProfile extends State<PersonalProfile> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ⬅️ Nút quay lại
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const RootPage(initialIndex: 3)),
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
                    "Personal profile",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Align(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!) as ImageProvider
                          : const AssetImage('assets/images/default_avatar.png'),
                    ),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Icon(Icons.camera_alt, color: Colors.black, size: 20),
                      ),
                    ),
                  ],
                ),
              ),


              const SizedBox(height: 30),
              const Text(
                "Full name",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: fullNameController,

                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  hintText: "Tran Kieu Anh",
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "Email",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress, // Định dạng bàn phím email
                textInputAction: TextInputAction.done, // Hành động khi nhấn Enter
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  hintText: "Kieuanh@gmail.com",
                  prefixIcon: Icon(Icons.email), // Biểu tượng email cho dễ nhận diện
                ),
              ),


              const SizedBox(height: 20),
              const Text(
                "Phone Number",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  hintText: "",
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
