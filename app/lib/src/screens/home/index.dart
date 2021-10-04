// home screen contents
import 'dart:io';

import 'package:app/src/config/image_constants.dart';
import 'package:app/src/routes/index.dart';
import 'package:app/src/screens/attendance/index.dart';
import 'package:app/src/screens/drawer.dart';
import 'package:app/src/utils/app_state_notifier.dart';
import 'package:app/src/widgets/cache_image_widget.dart';
import 'package:background_location/background_location.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocation/geolocation.dart';
import 'package:provider/provider.dart';
import 'package:shared/main.dart';
import 'package:app/src/config/string_constants.dart' as string_constants;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:api_sdk/api_constants.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:background_fetch/background_fetch.dart';




const fetchBackground = "fetchBackground";
bool _enabled = true;
int _status = 0;
List<String> _events = [];
String latitude = 'waiting...';
String longitude = 'waiting...';
const EVENTS_KEY = "fetch_events";

class HomeScreen extends StatelessWidget {

  // ignore: close_sinks
  final AuthenticationBloc authenticationBloc =
      AuthenticationBlocController().authenticationBloc;
  Map<String, String> globals = {
    "success": "",
  };
  @override
  Widget build(BuildContext context) {
    authenticationBloc.add(GetUserData());
    WidgetsFlutterBinding.ensureInitialized();
    FlutterBackgroundService.initialize(onStart);


    BackgroundLocation.startLocationService(
        distanceFilter: 20);
    BackgroundLocation.setAndroidConfiguration(10);
    BackgroundLocation.getLocationUpdates((location) {
      print(location);
    });
    void main2() async{

    }


    getCurrentLocation();

    return WillPopScope(
        onWillPop: () async => false,
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            cubit: authenticationBloc,
            builder: (BuildContext context, AuthenticationState state) {

              if (state is SetUserData) {

                void onStart() {

                  WidgetsFlutterBinding.ensureInitialized();
                  final service = FlutterBackgroundService();
                  service.onDataReceived.listen((event) {
                    if (event["action"] == "setAsForeground") {
                      service.setForegroundMode(true);
                      return;
                    }

                    if (event["action"] == "setAsBackground") {
                      service.setForegroundMode(false);
                    }

                    if (event["action"] == "stopService") {
                      service.stopBackgroundService();
                    }
                  });

                  // bring to foreground
                  service.setForegroundMode(true);
                  Timer.periodic(Duration(seconds: 600), (timer) async {






                    if (!(await service.isServiceRunning())) timer.cancel();
                    service.setNotificationInfo(
                      title: "My App Service",
                      content: "Updated at ${DateTime.now()}",
                    );

                    service.sendData(
                      {"current_date": DateTime.now().toIso8601String()},
                    );
                    _getCurrentLocation() async {
                      Geolocation.enableLocationServices().then((result) {
                        // Request location
                        print(result);
                      }).catchError((e) {
                        // Location Services Enablind Cancelled
                        print(e);
                      });

                      Geolocation.currentLocation(accuracy: LocationAccuracy.best)
                          .listen((result) {
                        if (result.isSuccessful) {

                          latitude = result.location.latitude.toString();
                          longitude = result.location.longitude.toString();
                          print("Lat:"+latitude);
                          print("Long:"+longitude);


                        }
                      });


                    }
                    _getCurrentLocation();

                    var now = new DateTime.now();
                    var formatter = new DateFormat('yyyy-MM-dd');
                    String formattedDate = formatter.format(now);
                    print(formattedDate); // 2021-06-24
                    String formattedTime = DateFormat.Hm().format(now);
                    var requestBody = {
                      'pkEmpId': state.currentUserData.id,
                      'selecteddate': formattedDate,
                      'time':formattedTime,
                      'lat':longitude,
                      'long':latitude,
                    };

                    http.Response response = await http.post('${apiConstants["geolocation"]}',
                      body: requestBody,
                    );

                    print(response.body);

                  });
                }
                WidgetsFlutterBinding.ensureInitialized();
                FlutterBackgroundService.initialize(onStart);
                onStart();

                return Scaffold(
                  appBar: AppBar(
                    centerTitle: true,
                    title: Text(
                      string_constants.app_bar_title,
                      style: Theme.of(context).appBarTheme.textTheme.bodyText1,
                    ),
                    actions: [
                      IconButton(
                          icon: Icon(Icons.logout),
                          onPressed: () {
                            FlutterBackgroundService().sendData(
                              {"action": "stopService"},
                            );
                            authenticationBloc.add(UserLogOut());
                          }),
                    ],
                  ),
                  body:Center( child: Text("Dashboard")),
                  drawer: navigationDrawer(),

                  // drawer: Drawer(
                  //   child: ListView(
                  //     padding: EdgeInsets.zero,
                  //     children: <Widget>[
                  //       DrawerHeader(
                  //
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Row(
                  //               mainAxisAlignment:
                  //               MainAxisAlignment.spaceBetween,
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //
                  //                 Container(
                  //
                  //                   decoration: BoxDecoration(
                  //                       borderRadius: BorderRadius.circular(50),
                  //                       color: Colors.white),
                  //                   child: CachedImage(
                  //                     imageUrl:
                  //                     state.currentUserData.profilePic,
                  //                     fit: BoxFit.fitWidth,
                  //                     errorWidget: Image.network(
                  //                       state.currentUserData.profilePic,
                  //                     ),
                  //                     width: 80,
                  //                     height: 80,
                  //                     placeholder: CircularProgressIndicator(),
                  //                   ),
                  //                 ),
                  //
                  //                 Switch(
                  //                   value:
                  //                   Provider.of<AppStateNotifier>(context)
                  //                       .isDarkMode,
                  //                   onChanged: (value) {
                  //                     Provider.of<AppStateNotifier>(context,
                  //                         listen: false)
                  //                         .updateTheme(value);
                  //                   },
                  //                 ),
                  //               ],
                  //
                  //
                  //             ),
                  //
                  //           ],
                  //         ),
                  //
                  //
                  //
                  //
                  //         decoration: BoxDecoration(
                  //           color: Theme.of(context).dividerColor,
                  //         ),
                  //
                  //       ),
                  //       TextButton(
                  //         style: string_constants.flatButtonStyle,
                  //         onPressed: () {
                  //           print("attend");
                  //           Navigator.pushReplacementNamed(context,'/attendance');
                  //         },
                  //         child: Text('Click here for attendance'),
                  //       ),
                  //       ListTile(
                  //         title: Text("Employee: "+
                  //             '${state.currentUserData.Employee} ',
                  //             style: Theme.of(context).textTheme.bodyText2),
                  //       ),
                  //       ListTile(
                  //         title: Text("EmpRole: "+state.currentUserData.EmpRole,
                  //             style: Theme.of(context).textTheme.bodyText2),
                  //       ),
                  //       ListTile(
                  //         title: Text("Emp Id: "+state.currentUserData.id.toString(),
                  //             style: Theme.of(context).textTheme.bodyText2),
                  //       ),  ListTile(
                  //         title: Text("Emp Code: "+state.currentUserData.EmpCode.toString(),
                  //             style: Theme.of(context).textTheme.bodyText2),
                  //       ),
                  //
                  //
                  //     ],
                  //   ),
                  // ),

                );

              }
              return Scaffold(
                body: Center(

                ),
              );
            }));
  }

}
void getCurrentLocation() {
  BackgroundLocation().getCurrentLocation().then((location) {

    print(location.longitude);

    print('This is current Location ' + location.toMap().toString());
  });
}
void onStart() {

  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();
  service.onDataReceived.listen((event) {
    if (event["action"] == "setAsForeground") {
      service.setForegroundMode(true);
      return;
    }

    if (event["action"] == "setAsBackground") {
      service.setForegroundMode(false);
    }

    if (event["action"] == "stopService") {
      service.stopBackgroundService();
    }
  });

  // bring to foreground
  service.setForegroundMode(true);
  Timer.periodic(Duration(seconds: 600), (timer) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String firstName = "";





    if (!(await service.isServiceRunning())) timer.cancel();
    service.setNotificationInfo(
      title: "My App Service",
      content: "Updated at ${DateTime.now()}",
    );

    service.sendData(
      {"current_date": DateTime.now().toIso8601String()},
    );
    _getCurrentLocation() async {
      Geolocation.enableLocationServices().then((result) {
        // Request location
        print(result);
      }).catchError((e) {
        // Location Services Enablind Cancelled
        print(e);
      });

      Geolocation.currentLocation(accuracy: LocationAccuracy.best)
          .listen((result) {
        if (result.isSuccessful) {

          latitude = result.location.latitude.toString();
          longitude = result.location.longitude.toString();
          print("Lat:"+latitude);
          print("Long:"+longitude);


        }
      });


    }
    _getCurrentLocation();


  });
}




