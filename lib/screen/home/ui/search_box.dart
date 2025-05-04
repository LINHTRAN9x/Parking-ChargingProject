
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:parking_project/screen/activities/ui/order_details.dart';
import 'package:parking_project/screen/home/ui/category_screen.dart';
import 'package:parking_project/screen/home/ui/show_all.dart';
import 'package:parking_project/screen/home/ui/show_all_tab.dart';

class SearchBox extends StatelessWidget{
  const SearchBox({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child:  Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(1,1,1,13),
            child:
            SearchAnchor(
                builder: (BuildContext context, SearchController controller){
                  return SearchBar(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => const OrderDetails()),
                        // );
                      },
                      backgroundColor: MaterialStateColor.resolveWith((states) => Colors.white), // Nền trắng
                      leading: SvgPicture.asset(
                        "lib/assets/images/icons/light_search-rounded.svg",
                        width: 30,
                        height: 30,
                      ),
                      hintText: "Search here...",


                      shape: MaterialStateProperty.resolveWith<RoundedRectangleBorder>(
                            (states) {
                          return RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            side: BorderSide(
                              color: states.contains(MaterialState.focused) ? Colors.black87 : Colors.white10, // Viền đậm hơn khi focus
                              width: 1.0, // Độ dày viền
                            ),
                          );
                        },
                      ),
                      elevation: MaterialStateProperty.all(4.0), // Đổ bóng
                      trailing: [
                        IconButton(
                          icon: SvgPicture.asset("lib/assets/images/icons/close-circle.svg"),
                          onPressed: () {
                            // Xử lý khi nhấn icon "x"
                            //SearchController.of(context)?.clear(); // Xóa nội dung ô tìm kiếm
                          },
                        ),
                      ]
                  );
                },
                suggestionsBuilder: (BuildContext context, SearchController controller) {
                  return List<Text>.generate(5, (int index) {
                    return Text("Item ${index}");
                  },
                  );
                }
            ),


          ),
          //CategoryList(),

        ],
      )


    );

  }


}