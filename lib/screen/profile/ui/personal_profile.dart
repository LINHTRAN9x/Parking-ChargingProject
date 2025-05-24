import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:parking_project/root_page.dart';
import 'package:parking_project/screen/checkout/ui/add_bank.dart';
import 'package:parking_project/screen/profile/profile_screen.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalProfile extends StatefulWidget {
  final Map user;

  const PersonalProfile({super.key, required this.user});
  _StatePersonalProfile createState() => _StatePersonalProfile();
}

class _StatePersonalProfile extends State<PersonalProfile> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();
  late Map user;
  bool isLoading = false;

  File? _imageFile;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text = pickedDate.toIso8601String().split('T').first; // yyyy-MM-dd
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> uploadImage(File imageFile, String token) async {
    setState(() {
      isLoading = true;
    });
    try {
      FormData formData = FormData.fromMap({
        "files": await MultipartFile.fromFile(imageFile.path),
      });

      Response response = await Dio().post(
        "http://18.182.12.54:8085/file/aws/upload-images",
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = response.data;
        if (responseData.isNotEmpty) {
          return responseData[0]; // Returning the uploaded image URL
        } else {
          return '';
        }
      } else {
        throw Exception('Image upload failed');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }finally{
      setState(() {
        isLoading = false;
      });
    }

  }

  Future<void> updateProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    String avatarUrl = '';

    try {
      if (_imageFile != null) {
        avatarUrl = await uploadImage(_imageFile!, token!);
      }

      var data = {
    "firstName": firstNameController.text,
    "lastName": lastNameController.text,
        "username": fullNameController.text,
    "phone": phoneController.text,
    "avatarUrl": avatarUrl.isNotEmpty ? avatarUrl : null,
    "dob": dobController.text,
    };
      print("daaata $data");

      final response = await Dio().patch(
        "http://18.182.12.54:8080/identity/users/update-user",
        data: {
          "firstName": firstNameController.text,
          "lastName": lastNameController.text,
          "username" : fullNameController.text,
          "phone": phoneController.text,
          "avatarUrl": avatarUrl.isNotEmpty ? avatarUrl : null,
          "dob": dobController.text,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
      print("jhs: ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Profile updated: ${response.data['result']}");

      } else {
        Fluttertoast.showToast(
          msg: "Profile update failed!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER, // Hiển thị ở giữa màn hình
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );


      }
    } catch (e) {
      print("Error updating profile: $e");
      Fluttertoast.showToast(
        msg: "Profile update failed!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER, // Hiển thị ở giữa màn hình
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      Fluttertoast.showToast(
        msg: "Profile updated successfully!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }



  @override
  void initState() {
    super.initState();
    user = widget.user;
    firstNameController.text = user['firstName'] ?? '';
    lastNameController.text = user['lastName'] ?? '';
    fullNameController.text = user['username'] ?? '';
    emailController.text = user['email'] ?? '';
    phoneController.text = user['phone'] ?? '';
    dobController.text = user['dob'] ?? '';
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
               SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Align(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!) as ImageProvider
                          :  (user['avatarUrl'] != null && user['avatarUrl'] != '')
                              ? NetworkImage(user['avatarUrl'])
                              : AssetImage('lib/assets/images/default_avatar.png') as ImageProvider,

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
               SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              const Text(
                "First name",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: firstNameController,

                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  hintText: user['firstName'] ?? '',
                ),
              ),
              const Text(
                "Last name",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: lastNameController,

                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  hintText: user['lastName'] ?? '',
                ),
              ),

               SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              const Text(
                "User name",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: fullNameController,

                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  hintText: user['username'] ?? '',
                ),
              ),

               SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              const Text(
                "Email",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: emailController,
                readOnly: true,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  hintText: user['email'] ?? '',
                  prefixIcon: Icon(Icons.email), // Biểu tượng email cho dễ nhận diện
                ),
              ),


               SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              const Text(
                "Phone Number",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  hintText: user['phone'] ?? '',
                ),
              ),
               SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              const Text(
                "Date of Birth",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: dobController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  hintText: user['dob'] ?? '',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
              ),


            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(

          height: MediaQuery.of(context).size.height * 0.14,
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




              SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
              Align(
                alignment: Alignment(0, -0.7),
                child: ElevatedButton(
                  onPressed: () {
                    // Logic cho khi nút Next được nhấn
                    updateProfile();
                    //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const PaymentMethod()));
                  },
                  style: ElevatedButton.styleFrom(

                    backgroundColor: Color(0xFF00B150), // Màu nền cho nút
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Bo tròn nút
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 150, vertical: 8), // Padding cho nút
                  ),
                  child: isLoading ?
                  LoadingAnimationWidget.beat(
                      color: Colors.white, size: 30) :
                  Text(
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
