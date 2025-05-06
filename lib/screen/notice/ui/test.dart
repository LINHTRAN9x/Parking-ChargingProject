import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'dart:async';

//import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vietmap_flutter_navigation/vietmap_flutter_navigation.dart';

import '../../../root_page.dart';

class VietMapNavigationScreen extends StatefulWidget {
  final Map<String, dynamic> station;
  const VietMapNavigationScreen({super.key, required this.station});

  @override
  State<VietMapNavigationScreen> createState() =>
      _VietMapNavigationScreenState();
}

class _VietMapNavigationScreenState extends State<VietMapNavigationScreen> {
  late Map<String, dynamic> station;
  late LatLng selectedStation;
  LatLng? currentLocation;
  bool isMuted = false;

  // Define the map options
  late MapOptions _navigationOption;

  final _vietmapNavigationPlugin = VietMapNavigationPlugin();

  List<LatLng> waypoints = const [
    LatLng(21.0277672, 105.7833585),
    LatLng(21.017984, 105.782374)
  ];
  /// Display the guide instruction image to the next turn
  Widget instructionImage = const SizedBox.shrink();

  Widget recenterButton = const SizedBox.shrink();

  /// RouteProgressEvent contains the route information, current location, next turn, distance, duration,...
  /// This variable is update real time when the navigation is started
  RouteProgressEvent? routeProgressEvent;

  /// The controller to control the navigation, such as start, stop, recenter, overview,...
  MapNavigationViewController? _navigationController;


  @override
  void initState() {
    super.initState();
    station = widget.station;
    print("Stationnnn ${jsonEncode(station)}");
    selectedStation = LatLng(widget.station['y'], widget.station['x']);
    print("selectedStation $selectedStation");
    _getCurrentLocation();
    initialize();
  }
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;


    // Lấy tọa độ hiện tại
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
  }


  Future<void> initialize() async {
    if (!mounted) return;
    _navigationOption = _vietmapNavigationPlugin.getDefaultOptions();

    /// set the simulate route to true to test the navigation without the real location
    _navigationOption.simulateRoute = false;
    print("SELECTED STATION ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++: $station");

    _navigationOption.apiKey =
    'd70d6bf6d67cba21c0f4b48e67842b6755def76452dad943';
    _navigationOption.mapStyle =
    "https://maps.vietmap.vn/api/maps/light/styles.json?apikey=d70d6bf6d67cba21c0f4b48e67842b6755def76452dad943";

    _vietmapNavigationPlugin.setDefaultOptions(_navigationOption);

  }
  MapOptions? options;
  void _myLocation() {
    if (_navigationController != null) {
      _navigationController?.moveCamera(
        latLng: currentLocation ?? LatLng(21.0277672, 105.7833585), // Tọa độ mới
        zoom: 15, // Mức zoom
      );
    }
  }

  _showRecenterButton() {
    recenterButton = TextButton(
        onPressed: () {
          _navigationController?.recenter();
          setState(() {
            recenterButton = const SizedBox.shrink();
          });
        },
        child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white,
                border: Border.all(color: Colors.black45, width: 1)),
            child: const Row(
              children: [
                Icon(
                  Icons.keyboard_double_arrow_up_sharp,
                  color: Colors.lightBlue,
                  size: 35,
                ),
                Text(
                  'Về giữa',
                  style: TextStyle(fontSize: 18, color: Colors.lightBlue),
                )
              ],
            )));
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      PreferredSize(
        preferredSize: Size.fromHeight(50), // Tăng chiều cao của AppBar
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                spreadRadius: 5,
                offset: Offset(0, 3), // Hướng đổ bóng xuống dưới
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            toolbarHeight: 120,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => RootPage()));
              },
            ),
            title: null
            // Column(
            //   children: [
            //     _buildLocationField(
            //       icon: Icons.circle,
            //       color: Colors.green,
            //       label: "My location",
            //     ),
            //     _buildLocationField(
            //       icon: Icons.location_on,
            //       color: Colors.red,
            //       label: station['name'],
            //     ),
            //   ],
            // ),
            // actions: [
            //   IconButton(
            //     icon: Icon(Icons.swap_vert, color: Colors.black),
            //     onPressed: () {
            //       // Xử lý logic đổi vị trí
            //     },
            //   ),
            // ],
          ),
        )

      ),


      body: Stack(
        children: [
          NavigationView(
            mapOptions: _navigationOption,
            onMapCreated: (controller) async {
              _navigationController = controller;

              _navigationController?.moveCamera(
                latLng: currentLocation ?? LatLng(21.0277672, 105.7833585), // Nếu chưa có vị trí hiện tại, dùng tọa độ mặc định
                zoom: 15,
              );
              Future.delayed(Duration(seconds: 1), () async {
                await _getCurrentLocation(); // Chờ lấy vị trí hiện tại

                if (currentLocation != null) {
                  _navigationController?.buildRoute(
                    waypoints: [
                      currentLocation!,
                      selectedStation
                    ],
                    profile: DrivingProfile.cycling,
                  );
                }
              });

            },
            // onMapRendered: ()  {
            //   _navigationController?.buildAndStartNavigation(
            //     waypoints: [
            //       currentLocation!,
            //       selectedStation
            //     ],
            //     profile: DrivingProfile.cycling,
            //   );
            // },
            onRouteProgressChange: (RouteProgressEvent routeProgressEvent) {
              setState(() {
                this.routeProgressEvent = routeProgressEvent;
              });

              _setInstructionImage(routeProgressEvent.currentModifier,
                  routeProgressEvent.currentModifierType);
            },
            onMapLongClick: (LatLng? latLng, Point? point) {
              if (latLng == null) return;
              _navigationController?.buildRoute(waypoints: [
                currentLocation!,
                /// Replace the latitude and longitude with your origin location
                //LatLng(21.0277672, 105.7833585),
                latLng
              ], profile: DrivingProfile.drivingTraffic,);
            },
            onArrival: () {
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 60),
                        SizedBox(height: 12),
                        Text(
                          "Bạn đã tới đích!",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Cảm ơn bạn đã sử dụng dịch vụ",
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: Size(double.infinity, 48),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              instructionImage = const SizedBox.shrink();
                              routeProgressEvent = null;
                            });
                          },
                          child: Text("OK", style: TextStyle(fontSize: 16,color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              );
            },



          ),
          BannerInstructionView(
            routeProgressEvent: routeProgressEvent,
            instructionIcon: instructionImage,
          ),
          Positioned(
            top: 20,
              child: Text(routeProgressEvent?.currentLocation?.speedAccuracyMetersPerSecond?.toString() ?? '0')
          ),
          Positioned(
            bottom: 0,
              child: BottomActionView(
                  recenterButton: recenterButton,
                  controller: _navigationController,
                  routeProgressEvent: routeProgressEvent,
                  onOverviewCallback: _showRecenterButton,
                  onStopNavigationCallback: () {
                    setState(() {
                      instructionImage = const SizedBox.shrink();
                      routeProgressEvent = null;
                    });
                  },
              )
          )


        ],
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 3.0,
          children: [

            FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                _navigationController?.startNavigation();
              },
              tooltip: 'Navigation',
              child: const Icon(Icons.directions),
            ),
            FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () async {
                isMuted = !isMuted;
                await _navigationController?.mute(isMuted);
              },
              tooltip: isMuted ? 'Unmute' : 'Mute',
              child: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
            ),

            // FloatingActionButton(
            //   backgroundColor: Colors.white,
            //   onPressed:  () {
            //     _navigationController?.recenter(); //_myLocation,
            //   },
            //   tooltip: 'My Location',
            //   child: const Icon(Icons.my_location),
            // ),
          ],
        ),
      )



    );
  }
  _setInstructionImage(String? modifier, String? type) {
    if (modifier != null && type != null) {
      List<String> data = [
        type.replaceAll(' ', '_'),
        modifier.replaceAll(' ', '_')
      ];
      String path = 'lib/assets/navigation_symbol/${data.join('_')}.svg';
      setState(() {
        instructionImage = SvgPicture.asset(path, color: Colors.white);
      });
    }
  }
  @override
  void dispose() {
    _navigationController?.onDispose();
    super.dispose();
  }

  Widget _buildLocationField({required IconData icon, required Color color, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: label,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Colors.black, // Màu viền
                    width: 20.0, // Độ dày viền (mặc định là 1.0)
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
