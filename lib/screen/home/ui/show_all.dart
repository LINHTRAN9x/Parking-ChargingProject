
import 'package:flutter/material.dart';
import 'package:parking_project/screen/home/ui/show_all_tab.dart';

class ShowAll extends StatelessWidget {
  const ShowAll({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: 60,
        child: Container(

          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 0.5,
              ),
            ),
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(_createRoute());
            },
            style: ElevatedButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              backgroundColor: Colors.white,
              elevation: 0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(
              'Show all parking & charging',
              style: TextStyle(
                color: Color(0xFF00B150), // Màu chữ
                fontSize: 15
              ),
              ),
          ),
        )

    )
    );

  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const ShowAllTab(),
    opaque: false,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),

        child: child,
      );
    },
  );
}