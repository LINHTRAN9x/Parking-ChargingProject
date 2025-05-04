import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingIssesField extends StatefulWidget {
  final String bookingId;

  const BookingIssesField({super.key, required this.bookingId});

  @override
  _StateBookingIssesField createState() => _StateBookingIssesField();
}

class _StateBookingIssesField extends State<BookingIssesField> {
  late String bookingId;
  File? _image;
  String? uploadedImageUrl;
  List<String> _uploadedImages = [];
  bool isLoading = false;

  final TextEditingController _bookingIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedService = "OTHER";
  bool isFormValid = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }
  Future<void> _uploadImage() async {
    if (_image == null) return;

    final uri = Uri.parse("http://18.182.12.54:8085/file/aws/upload-images");
    final request = http.MultipartRequest("POST", uri);
    request.files.add(await http.MultipartFile.fromPath("files", _image!.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      if (responseData.isNotEmpty) {
        setState(() {
          uploadedImageUrl = responseData[0];
          _uploadedImages.add(uploadedImageUrl!);
        });
      }
      print("responseData $responseData");
    } else {
      print("Upload failed: ${response.statusCode}");
    }
  }

  Future<void> submitDispute() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    setState(() {
      isLoading = true;
    });
    final url = "http://18.182.12.54:8086/dispute/api";

    // Prepare the request body
    final body = {
      "email": _emailController.text,
      "service": _selectedService,
      "bookingId": bookingId,
      "title": _titleController.text,
      "description": _descriptionController.text,
      "images": _uploadedImages,
    };

    print("bodyy $body");

    Dio dio = Dio();

    try {
      final response = await dio.post(
        url,
        data: body,
        options: Options(
          headers: {"Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Fluttertoast.showToast(
          msg: "Dispute submitted successfully",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        print("Dispute: ${response.data}");
      } else {
        print("Failed to submit dispute: ${response.statusCode}");
        print(response.data);
        Fluttertoast.showToast(
          msg: "Failed to submit dispute!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print("Error: $e");
      Fluttertoast.showToast(
        msg: "Failed to submit dispute",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }finally {
      setState(() {
        isLoading = false;
      });
    }
  }



  @override
  void initState() {
    super.initState();
    bookingId = widget.bookingId;
    _bookingIdController.text = bookingId;
  }

  void _validateForm() {
    setState(() {
      isFormValid = _emailController.text.isNotEmpty &&
          _selectedService != null &&
          _titleController.text.isNotEmpty &&
          _descriptionController.text.isNotEmpty;
    });
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black54),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar Row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 47, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      'lib/assets/images/icons/arrow-left.svg',
                      width: 24,
                      height: 24,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Booking Issues",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Form content with scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Booking ID"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _bookingIdController,
                      enabled: false,
                      decoration: _inputDecoration(
                        hint: bookingId.substring(0, 6).toUpperCase(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("Email *"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      onChanged: (_) => _validateForm(),
                      decoration:
                      _inputDecoration(hint: "trankieuanh@gmail.com"),
                    ),
                    const SizedBox(height: 16),
                    const Text("Service *"),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: _inputDecoration(),
                      value: _selectedService,
                      onChanged: (value) {
                        setState(() => _selectedService = value ?? "OTHER");  // Default to "OTHER" if value is null
                        _validateForm();
                      },
                      items: const [
                        DropdownMenuItem(value: "OTHER", child: Text("Other")),
                        DropdownMenuItem(value: "BOOKING", child: Text("Booking")),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("Title *"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      onChanged: (_) => _validateForm(),
                      decoration: _inputDecoration(hint: "Enter your title"),
                    ),
                    const SizedBox(height: 16),
                    const Text("Description *"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      onChanged: (_) => _validateForm(),
                      maxLines: 5,
                      decoration: _inputDecoration(),
                    ),
                    const SizedBox(height: 16),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Attached file (${_uploadedImages.length}/4)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (_uploadedImages.length >= 4) return;
                                await _pickImage();
                                await _uploadImage();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              child: const Text(
                                "Upload file",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _uploadedImages.map((imageUrl) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),


                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: isFormValid
                            ? () {
                          submitDispute();
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFormValid
                              ? Colors.green
                              : Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 160, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: isLoading ?
                        LoadingAnimationWidget.beat(
                            color: Colors.white, size: 30) :
                        Text(
                          "Send",
                          style: TextStyle(
                            color:
                            isFormValid ? Colors.white : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
