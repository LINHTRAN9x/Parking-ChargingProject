import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parking_project/screen/home/ui/show_time_filter.dart';
import 'package:parking_project/screen/home/ui/sparkparking_station.dart';

class ShowAllTab extends StatefulWidget {
  const ShowAllTab({super.key});

  @override
  _ShowAllTabState createState() => _ShowAllTabState();
}

class _ShowAllTabState extends State<ShowAllTab> {
  final DraggableScrollableController _controller = DraggableScrollableController();
  final List<Map<String, dynamic>> parkingLocations =  [
    {
      'id': 1,
      'name': 'Parking Lot A',
      'type': 'Parking Lot',
      'address': '123 Main St',
      'rating' : 4.9,
      'images': [
        'https://via.placeholder.com/150',
        'https://via.placeholder.com/150/0000FF',
        'https://via.placeholder.com/150/FF0000',
      ],
    },
    {
      'id': 2,
      'name': 'Charging Station B',
      'type': 'Charging Station',
      'address': '456 Elm St',
      'rating' : 3.4,
      'images': [
        'https://via.placeholder.com/150',
        'https://via.placeholder.com/150/00FF00',
      ],
    },
    {
      'id': 3,
      'name': 'Parking Lot C',
      'type': 'Parking Lot',
      'address': '789 Oak St',
      'rating' : 2.5,
      'images': [
        'https://via.placeholder.com/150',
      ],
    },
    {
      'id': 4,
      'name': 'Parking Lot D',
      'type': 'Parking Lot',
      'address': '789 Oak St',
      'rating' : 3,
      'images': [
        'https://via.placeholder.com/150',
      ],
    },
  ];

  // Hàm tạo danh sách sao dựa trên rating
  List<Widget> _buildRatingStars(double rating) {
    int fullStars = rating.floor();
    double decimal = rating - fullStars;
    List<Widget> stars = [];

    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.amber, size: 16));
    }

    if (decimal >= 0.5) {
      stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 16));
    }

    for (int i = stars.length; i < 5; i++) {
      stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 16));
    }

    return stars;
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {

      if (_controller.size <= 0.4) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body:
      GestureDetector(
        onTap: () => Navigator.pop(context), // Đóng modal khi bấm ra ngoài
    child: Container(
      color: Colors.transparent,
      child: DraggableScrollableSheet(
        controller: _controller,
        initialChildSize: 0.70, // Bắt đầu ở 70% chiều cao
        minChildSize: 0.4, // Kích thước nhỏ nhất khi vuốt xuống
        maxChildSize: 0.94, // Kích thước lớn nhất khi vuốt lên
        builder: (context, scrollController) {
          return ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.blueAccent,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Thanh kéo trên cùng
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                    ListView.builder(
                      controller: scrollController,
                      itemCount: parkingLocations.length,
                      itemBuilder: (context, index) {
                        final location = parkingLocations[index];
                        double rating = location['rating'] is double
                            ? location['rating']
                            : (location['rating'] as int).toDouble();
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hiển thị ảnh
                              SizedBox(
                                height: 150, // Chiều cao của vùng ảnh
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: location['images'].length,
                                  itemBuilder: (context, imgIndex) {
                                    return Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          location['images'][imgIndex],
                                          fit: BoxFit.cover,
                                          width: 180,
                                          height: 150,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Hiển thị thông tin địa điểm
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      location['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    Row(
                                      children: [
                                        Text(
                                          '${rating}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        // Hiển thị sao dựa trên rating
                                        ..._buildRatingStars(rating),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      location['type'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Always Open',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF00B150),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      spacing: 13,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            // Xử lý sự kiện đặt chỗ
                                            print("Booking Now pressed for ${location['name']}");
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(builder: (context) => const ShowTimeFilter()),
                                            // );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF00B150),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min, // Đảm bảo nội dung của nút vừa với nội dung
                                            children: [
                                              SvgPicture.asset(
                                                "lib/assets/images/icons/calendar.svg",
                                                height: 18,
                                                width: 18,
                                                color: Colors.white, // Màu của SVG
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'Booking Now',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Xử lý sự kiện điều hướng
                                            print("Directions pressed for ${location['name']}");
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            side: const BorderSide(color: Color(0xFF00B150), width: 2),

                                            elevation: 0, // Loại bỏ bóng của nút
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min, // Đảm bảo nội dung của nút vừa với nội dung
                                            children: [
                                              SvgPicture.asset(
                                                "lib/assets/images/icons/navigator.svg",
                                                height: 18,
                                                width: 18,
                                                color: Color(0xFF00B150),
                                              ),
                                              const SizedBox(width: 8), // Khoảng cách giữa icon và text
                                              const Text(
                                                'Directions',
                                                style: TextStyle(
                                                  color: Color(0xFF00B150),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),


                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );

        },
      ),
    )
      )

    );
  }
}
