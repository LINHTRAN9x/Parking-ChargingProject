import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryList extends StatefulWidget {
  final Function(int?) onCategorySelected;
  const CategoryList({super.key,required this.onCategorySelected});

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  List<Map<String, dynamic>> categories = [
    {
      "id": 1,
      "name": "All Spots",
      "icon": "lib/assets/images/icons/all-spots.svg",
      "description": "View all available spots.",
    },
    {
      "id": 2,
      "name": "Parking Lot",
      "icon": "lib/assets/images/icons/parking-lot.svg",
      "description": "Find the nearest parking lot.",
    },
    {
      "id": 3,
      "name": "Charging Station",
      "icon": "lib/assets/images/icons/charging.svg",
      "description": "Locate charging stations for your vehicle.",
    },
  ];
  int? selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Container(
          height: 37, // Chiều cao tổng danh sách

          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategoryId == category["id"];
              return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategoryId = category["id"]; // Cập nhật trạng thái
                    });
                    // Xử lý khi nhấn vào danh mục
                    print("Selected category: ${category['name']}");
                    widget.onCategorySelected(selectedCategoryId);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Color(0xFF00B150) : Colors.black, // Màu của border
                        width: 1.0, // Độ dày của border
                      ),
                      borderRadius: BorderRadius.circular(50.0), // Bo góc
                      color: Colors.white, // Màu nền bên trong
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 30,
                          height: 25,
                          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: SvgPicture.asset(
                            category["icon"],
                            color: isSelected ? Color(0xFF00B150) : Colors.black,

                          ),
                        ),
                        const SizedBox(height: 0), // Khoảng cách giữa icon và text
                        // Tên danh mục
                        Text(
                          category["name"],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Color(0xFF00B150) : Colors.black
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
              );

            },
          ),
        ),
      ],
    );
  }
}
