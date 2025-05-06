import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parking_project/screen/home/ui/show_time_filter.dart';
import 'package:parking_project/screen/notice/ui/test.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';

import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:vietmap_gl_platform_interface/vietmap_gl_platform_interface.dart';
import 'dart:math' show Random, log;
import 'package:geolocator/geolocator.dart';
import 'package:parking_project/screen/home/ui/category_screen.dart';

import '../../firebase.dart';



class Maps extends StatefulWidget {
  const Maps({super.key});

  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  VietmapController? _mapController;
  StreamSubscription<Position>? _positionStreamSubscription;
  List<Marker> temp = [];
  UserLocation? userLocation;
  bool isVector = true;
  bool _isSearching = false;
  late RouteSimulator routeSimulator;
  List<Map<String, dynamic>> stations = [];
  LatLng? _currentPosition;
  MyLocationRenderMode myLocationRenderMode = MyLocationRenderMode.NORMAL;
  String styleString =
      "https://maps.vietmap.vn/api/maps/light/styles.json?apikey=d70d6bf6d67cba21c0f4b48e67842b6755def76452dad943";
  int selectedCategoryId = 1;
  bool isLoading = false;
  final FirebaseService _firebaseService = FirebaseService();


  void _onMapCreated(VietmapController controller) {
    setState(() {
      _mapController = controller;
    });

    // Future.delayed(Duration(milliseconds: 500), () {
    //   if (_currentPosition != null) {
    //     _mapController!.addSymbol(SymbolOptions(
    //       geometry: _currentPosition,
    //       iconImage: "lib/assets/images/icons/location_marker.png",
    //       iconSize: 2.5,
    //     ));
    //   }
    // });

    // if (_currentPosition != null) {
    //   _mapController?.animateCamera(
    //     CameraUpdate.newLatLngZoom(_currentPosition, 15),
    //   );
    // }

    Future.delayed(Duration(seconds: 3), () {
      //_getCurrentLocation();
      _addChargingStations();
    });
  }
  @override
  void dispose() {
    _searchController.dispose();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Lấy vị trí khi mở app

    _startLocationUpdates();
    _firebaseService.initFCM();
  }
  void _startLocationUpdates() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, // Độ chính xác cao
      distanceFilter: 5, // Cập nhật nếu di chuyển 10m
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      getStations(position.latitude, position.longitude);     // Di chuyển camera theo vị trí mới
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 15),
      );
    });
  }
  Future<void> _getCurrentLocation() async {

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("GPS chưa bật!");

      return;
    }

    // ✅ Kiểm tra quyền vị trí
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        print("Quyền truy cập vị trí bị từ chối!");

        return;
      }
    }

    // 🛰 Lấy vị trí hiện tại
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    // print("GEOLOCATION xac dinh POSITION user: $position");
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);  //position.latitude, position.longitude

    });
    getStations(position.latitude, position.longitude);
    // 🎯 Cập nhật camera đến vị trí hiện tại
    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 15),
      );
    } else {
      print("MapController or currentPosition is null");
    }
    //_addCurrentLocationMarker();
  }
  void _addCurrentLocationMarker(location) {

    if (_mapController != null) {
      _mapController!.addSymbol(SymbolOptions(
        geometry: location,
        iconImage: "lib/assets/images/icons/marker.png", // 🖼 Icon vị trí
        iconSize: 1.5, // Kích thước icon
      ));
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    final dio = Dio();
    final String apiKey = "d70d6bf6d67cba21c0f4b48e67842b6755def76452dad943";
    final String url =
        "https://maps.vietmap.vn/api/autocomplete/v3?apikey=$apiKey&text=$query";

    try {
      final response = await dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        var data = response.data;

        print("API trả về: $data");

        if (data is List) {
          setState(() {
            _searchResults = data
                .where((place) => place is Map<String, dynamic> && place.containsKey('ref_id'))
                .map<Map<String, dynamic>>((place) => Map<String, dynamic>.from(place))
                .toList();

            // In ra danh sách ref_id từ kết quả
            for (var place in _searchResults) {
              print("ref_id: ${place['ref_id']}");
            }
          });
        } else {
          print("Lỗi: Dữ liệu API không phải là danh sách.");
        }
      } else {
        print("Lỗi API: ${response.statusCode} - ${response.statusMessage}");
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
    }
  }
  bool isSymbolTapRegistered = false;
  Future<void> _onLocationTap(Map<String, dynamic> place) async {
    String refId = place['ref_id'];
    print("Người dùng đã chọn địa điểm có ref_id: $refId");

    final dio = Dio();
    final String apiKey = "d70d6bf6d67cba21c0f4b48e67842b6755def76452dad943";
    final String url =
        "https://maps.vietmap.vn/api/place/v3?apikey=$apiKey&refid=$refId";

    try {
      final response = await dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        var data = response.data;
        print("Kết quả trả về: $data");

        // Kiểm tra xem API có chứa tọa độ không
        if (data is Map<String, dynamic> && data.containsKey('lat') && data.containsKey('lng')) {
          double lat = data['lat'];
          double lon = data['lng'];
          LatLng locationSearch = LatLng(lat,lon);
          getStations(lat,lon);
          print("Tọa độ: Lat = $lat, Lon = $lon");
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(locationSearch, 14),
          );
          _addCurrentLocationMarker(locationSearch);
        } else {
          print("Lỗi: API không trả về tọa độ hợp lệ.");
        }
      } else {
        print("Lỗi API: ${response.statusCode} - ${response.statusMessage}");
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
    }
  }

  void getStations(lat, lon) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    print("token $token");

    String serviceParam = '';
    if (selectedCategoryId == 2) {
      serviceParam = 'PARKING';
    } else if (selectedCategoryId == 3) {
      serviceParam = 'CHARGING';
    } else if (selectedCategoryId == 1) {
      serviceParam = '';
    }

    final String url =
        "http://18.182.12.54:8082/app-data-service/locations/nearby"
        "?longitude=$lon&latitude=$lat&maxDistance=100"
        "${serviceParam.isNotEmpty ? '&services=$serviceParam' : ''}"
        "&page=0&size=20";

    try {
      final response = await Dio().get(
        url,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        print("Dữ liệu API trả về: ${response.data['content']}");

        if (response.data['content'] is List) {
          List<Map<String, dynamic>> allStations = response.data['content']
              .where((item) => item is Map<String, dynamic>)
              .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
              .toList();

          setState(() {
            stations = allStations;
          });

          print("Danh sách stations: $stations");
          prefs.setString('stations', jsonEncode(response.data));
          _addChargingStations();
        } else {
          print("Lỗi: API không trả về danh sách!");
        }
      } else {
        print("Lỗi API: ${response.statusCode} - ${response.statusMessage}");
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
    }
  }


  // Tạo một Map để lưu ID của Symbol và trạm sạc tương ứng
  final Map<String, Map<String, dynamic>> symbolStationMap = {};
  void _addChargingStations() {
    if (_mapController == null) return;
    print("Stations $stations");

    _mapController!.clearSymbols();

    for (var station in stations) {
      try {
        final location = station['location'];
        final lat = location['y'];
        final lon = location['x'];

        print("Adding station: ${station['name']} at $lat, $lon");

        String iconPath = "lib/assets/images/icons/default-icon.png"; // Mặc định
        List<String> services = List<String>.from(station['services'] ?? []);

        if (services.contains("CHARGING") && services.contains("PARKING")) {
          iconPath = "lib/assets/images/icons/charging&parking-icon.png";
        } else if (services.contains("CHARGING")) {
          iconPath = "lib/assets/images/icons/charging-icon.png";
        } else if (services.contains("PARKING")) {
          iconPath = "lib/assets/images/icons/parking-icon.png";
        }

        _mapController!.addSymbol(
          SymbolOptions(
            geometry: LatLng(lat, lon),
            iconImage: iconPath,
            iconSize: 0.7,
          ),
        ).then((symbol) {
          print("Added symbol for ${station['name']} with ID: ${symbol.id}");
          symbolStationMap[symbol.id] = station;
        }).catchError((error) {
          print("Error adding symbol for ${station['name']}: $error");
        });
      } catch (e) {
        print("Lỗi khi xử lý station: $e");
      }
    }

    // Đăng ký sự kiện nhấn biểu tượng nếu chưa có
    if (!isSymbolTapRegistered) {
      _mapController?.onSymbolTapped.add((symbol) {
        var selectedStation = symbolStationMap[symbol.id];
        if (selectedStation != null) {
          _showChargingStationDetails(selectedStation);
        }
      });
      isSymbolTapRegistered = true;
    }
  }

  bool isModalOpen = false;

  void _showChargingStationDetails(Map<String, dynamic> station) {
    if (isModalOpen) return;
    final DraggableScrollableController controller = DraggableScrollableController(); // Tạo controller mới
    isModalOpen = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          controller: controller,  // Sử dụng controller mới
          initialChildSize: 0.45,
          minChildSize: 0.4,
          maxChildSize: 0.94,
          expand: false,
          builder: (context, scrollController) {
            return _buildStationDetail(scrollController, station);
          },
        );
      },
    ).whenComplete(() {
      isModalOpen = false; // Reset lại trạng thái khi modal đóng
    });
  }


  Future<void> directionsNavigation(LatLng destination) async {
    LatLng origin = _currentPosition!;
    String apiKey = "d70d6bf6d67cba21c0f4b48e67842b6755def76452dad943";
    String url =
        "https://maps.vietmap.vn/api/route?api-version=1.1&apikey=$apiKey&point=${origin.latitude},${origin.longitude}&point=${destination.latitude},${destination.longitude}&locale=vi&profile=car";

    try {
      Dio dio = Dio();
      Response response = await dio.get(url);


      if (response.statusCode == 200) {
        var data = response.data;
        print("Directions Data: ${data}");

        List<LatLng> routePoints = [];
        for (var point in data["routes"][0]["geometry"]["coordinates"]) {
          routePoints.add(LatLng(point[1], point[0]));
        }

      } else {
        print("Lỗi API VietMap: ${response.statusMessage}");
      }
    } catch (e) {
      print("Lỗi khi gọi API: $e");
    }
  }

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
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body:
      Container(
        height: screenHeight,
        width: double.infinity,
        child: Stack(
          children: [

            VietmapGL(
              myLocationEnabled: true,
              myLocationTrackingMode: MyLocationTrackingMode.TrackingCompass,
              myLocationRenderMode: MyLocationRenderMode.COMPASS,
              trackCameraPosition: true,

              styleString: styleString,
              initialCameraPosition:
              CameraPosition(
                  target: _currentPosition!,
                  zoom: 15),
              onMapCreated: _onMapCreated,
              zoomGesturesEnabled: true,
              compassEnabled: true,
              onMapClick: (point, latlng) {
                print('Vị trí được click: $latlng');

                // setState(() {
                //   _currentPosition = LatLng(latlng.latitude, latlng.longitude);
                //   print('Vị trí đã cập nhật: $_currentPosition');
                // });
              },
              // onMapRenderedCallback: () {
              //   _mapController?.animateCamera(CameraUpdate.newCameraPosition(
              //       CameraPosition(
              //           target: _currentPosition,
              //           zoom: 15,
              //           tilt: 60)
              //
              //   ));
              //
              // },


            ),
            _mapController == null ? const SizedBox.shrink()
            : MarkerLayer(
                ignorePointer: true, // Will ignore all user gestures on the marker
                mapController: _mapController!,
                markers: [
                  Marker(
                      width: 40,
                      height: 40,
                      alignment: Alignment.bottomCenter,
                      child:
                          SvgPicture.asset(
                            "lib/assets/images/icons/car.svg",
                            width: 50,
                            height: 40,
                          ),
                      // Image.asset(
                      //   "lib/assets/images/icons/car-1.png",
                      //   width: 40,
                      // ),
                      // Icon(Icons.car,size: 40,color: Colors.blueAccent,),
                      latLng: _currentPosition!),
                ]),


            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(15,5,15,5),
                    margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50.0),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                    ),
                    child:
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search...",
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () => _searchLocation(_searchController.text),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _isSearching = value.isNotEmpty;
                        });
                        _searchLocation(value);
                      },
                    ),
                  ),
                  if (!_isSearching) CategoryList(
                    onCategorySelected: (categoryId) {
                      setState(() {
                        selectedCategoryId = categoryId!;
                      });
                      getStations(_currentPosition!.latitude, _currentPosition!.longitude);
                    },
                  ),
                  // 📌 Danh sách gợi ý
                  if (_searchResults.isNotEmpty)
                    Container(
                      height: 200,
                      margin: EdgeInsets.fromLTRB(20, 5, 20, 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                      ),
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {

                          var place = _searchResults[index];
                          final name = place["display"] ?? "Không có tên";
                          final address = place["address"] ?? "Không có địa chỉ";
                          //var lat = place['geometry']['coordinates'][1];
                          //var lng = place['geometry']['coordinates'][0];

                          return
                            ListTile(
                            title: Text(name),
                            onTap: () {
                              setState(() {
                                //_currentPosition = LatLng(lat, lng);
                                _searchResults.clear();
                                _searchController.clear();
                                _isSearching = false;
                                _onLocationTap(place);
                              });
                              // _mapController?.animateCamera(
                              //   CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15),
                              // );
                            },
                          );
                        },
                      ),

                    ),

                ],

              ),


            ),

            Positioned(
              bottom: 10,
              right: 10,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: _getCurrentLocation,
                child: Icon(Icons.my_location),
              ),
            ),





      ],
        )


      ),


    );
  }

  Widget _buildStationDetail(ScrollController scrollController, Map<String, dynamic> station) {
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
              child: ListView.builder(
                controller: scrollController,
                itemCount: 1, // Chỉ hiển thị một trạm đã chọn
                itemBuilder: (context, index) {
                  // double rating = station['rating'] is double
                  //     ? station['rating']
                  //     : (station['rating'] as int).toDouble();

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
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: station['images'].length,
                            itemBuilder: (context, imgIndex) {
                              return Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child:
                                  Image.network(
                                    (station['images'] != null && station['images'].isNotEmpty)
                                        ? station['images'][imgIndex]
                                        : "https://via.placeholder.com/150",
                                    fit: BoxFit.cover,
                                    width: 180,
                                    height: 150,
                                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child; // Ảnh đã tải xong
                                      } else {
                                        return Container(
                                          width: 180,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300], // Màu nền mờ giả
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                                  : null,
                                            ),
                                          ),
                                        ); // Hiển thị loading cho đến khi ảnh load xong
                                      }
                                    },
                                  )
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
                                station['name']?? "error",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  // Text(
                                  //   '$rating',
                                  //   style: const TextStyle(
                                  //     fontSize: 14,
                                  //     fontWeight: FontWeight.bold,
                                  //     color: Colors.black,
                                  //   ),
                                  // ),
                                  // const SizedBox(width: 4),
                                  // ..._buildRatingStars(rating),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${station['services'] != null ? station['services'].join(', ') : 'Unknown'} • "
                                    "${station['distance'] != null ? (station['distance'] >= 1 ? "${station['distance'].toStringAsFixed(1)}km" : "${(station['distance'] * 1000).toInt()}m") : 'Unknown'}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Always Open •  ${station['availableSeats'] ?? 0} / ${station['totalSeats'] ?? 0} seats",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00B150),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      print("Booking Now pressed for ${station['name']}");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ShowTimeFilter(station: station)),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF00B150),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SvgPicture.asset(
                                          "lib/assets/images/icons/calendar.svg",
                                          height: 18,
                                          width: 18,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Booking Now',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      debugPrint("Directions pressed for $station", wrapWidth: 1024);
                                      //directionsNavigation(LatLng(station['latitude'], station['longitude']));
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> VietMapNavigationScreen(station: station['location'])));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side: const BorderSide(color: Color(0xFF00B150), width: 2),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SvgPicture.asset(
                                          "lib/assets/images/icons/navigator.svg",
                                          height: 18,
                                          width: 18,
                                          color: Color(0xFF00B150),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Directions',
                                          style: TextStyle(color: Color(0xFF00B150)),
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
  }


}
