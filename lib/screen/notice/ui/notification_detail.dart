import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import '../../../root_page.dart';

class NotificationDetailView extends StatelessWidget {
  final String htmlContentUrl;
  final String title;

  NotificationDetailView({super.key, required this.htmlContentUrl, required this.title});

  Future<String> fetchHtmlContent(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load HTML content');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const RootPage(initialIndex: 2)),
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
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Nội dung HTML
            Expanded(
              child: FutureBuilder<String>(
                future: fetchHtmlContent(htmlContentUrl),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Html(
                        data: snapshot.data!,
                        style: {
                          "body": Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                          ),
                          "img": Style(
                            width: Width.auto(),
                            height: Height.auto(),
                          ),
                        },
                        // Custom widget to load images correctly

                      ),
                    );
                  } else {
                    return const Center(child: Text("No content available"));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
