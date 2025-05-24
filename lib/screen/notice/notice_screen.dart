import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parking_project/screen/notice/ui/notification_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoticeScreen extends StatefulWidget {


  NoticeScreen({super.key});
  _StateNoticeScreen createState() => _StateNoticeScreen();
}
class _StateNoticeScreen extends State<NoticeScreen>{
  List<dynamic> notis = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  int page = 0;
  ScrollController _scrollController = ScrollController();


  Future<void> getNotis({bool isLoadMore = false, bool forceRefresh = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Kiểm tra điều kiện không tải thêm khi không cần thiết
    if (isLoadMore && (isLoadingMore || !hasMoreData)) return;

    // Kiểm tra cache nếu không tải thêm và không bắt buộc làm mới
    if (!isLoadMore && !forceRefresh) {
      String? cached = prefs.getString('cached_notis');
      if (cached != null) {
        List<dynamic> localData = jsonDecode(cached);
        if (localData.isNotEmpty) {
          setState(() {
            notis = localData;
            isLoading = false;
          });
          return;
        }
      }
    }

    // Đặt trạng thái loading khi bắt đầu tải
    if (!isLoadMore) {
      setState(() => isLoading = true);
    } else {
      setState(() => isLoadingMore = true);
    }

    String? token = prefs.getString('access_token');
    try {
      var rs = await Dio().get(
        'http://18.182.12.54:8083/notification/notifications?allPublic=true&page=$page', // Thêm trang vào URL
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );
      List<dynamic> newNoti = rs.data['result'];

      // Kiểm tra nếu không còn dữ liệu, đặt hasMoreData là false
      if (newNoti.isEmpty) {
        setState(() {
          hasMoreData = false; // Không còn dữ liệu
        });
      }

      // Sắp xếp các thông báo theo ngày giảm dần
      newNoti.sort((a, b) {
        var aDate = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(1970);
        var bDate = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });

      // In ra log cho dữ liệu lấy được
      print("rss ${jsonEncode(rs.data['result'])}");

      setState(() {
        if (isLoadMore) {
          // Kiểm tra dữ liệu mới có trùng với dữ liệu cũ không trước khi thêm vào
          List<dynamic> newNotis = [];
          for (var item in newNoti) {
            // Kiểm tra nếu dữ liệu mới không có trong danh sách hiện tại
            if (!notis.any((existing) => existing['id'] == item['id'])) {
              newNotis.add(item);
            }
          }

          if (newNotis.isNotEmpty) {
            notis.addAll(newNotis);
            page++;
          } else {
            // Không có dữ liệu mới để thêm
            hasMoreData = false;
          }
        } else {
          // Nếu không phải tải thêm, chỉ thay thế danh sách hiện tại
          notis = newNoti;
          page = 1;
        }

        // Lưu cache
        prefs.setString('cached_notis', jsonEncode(notis));
        prefs.setInt('notis_last_updated', DateTime.now().millisecondsSinceEpoch);

        // Đặt trạng thái loading
        isLoading = false;
        isLoadingMore = false;
      });

    } catch (e) {
      print("errr $e");
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  String formatTime(String dateTimeStr) {
    DateTime dateTime = DateTime.parse(dateTimeStr).toLocal();
    return DateFormat('dd-MM-yyyy/HH:mm').format(dateTime);
  }


  @override
  void initState() {
    super.initState();
    getNotis();
    _scrollController.addListener(() {
      // Kiểm tra xem người dùng đã cuộn đến cuối danh sách chưa
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        // Tải thêm dữ liệu khi cuộn đến cuối
        if (hasMoreData && !isLoadingMore) {
          getNotis(isLoadMore: true);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF5CCD8F)))
          : SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 20, 20, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: const Text(
                "Notification",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // ListView phải nằm trong Expanded
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => getNotis(forceRefresh: true), // Kéo lên để tải lại
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: notis.length,
                  itemBuilder: (context, index) {
                    return NotificationItem(
                      title: notis[index]["title"] ?? '',
                      message: notis[index]["introduction"] ?? '',
                      time: formatTime(notis[index]["createdAt"].toString()),
                      icon: notis[index]["thumbnailUrl"] ?? '',
                      htmlContentUrl: notis[index]['htmlContentUrl'],
                      isRead: notis[index]["isRead"] ?? '',
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



class NotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final String icon;
  final String htmlContentUrl;
  final bool isRead;

  const NotificationItem({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.htmlContentUrl,
    required this.isRead
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isRead ? Colors.white : Colors.grey.shade200,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: () {
          // Navigate to the detail view when tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationDetailView(
                title: title,
                htmlContentUrl: htmlContentUrl,
              ),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          backgroundImage: NetworkImage(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward, color: Colors.green),
      ),
    );
  }
}

