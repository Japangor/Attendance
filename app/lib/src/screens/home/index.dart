// home screen contents
import 'dart:io';

import 'package:app/src/config/image_constants.dart';
import 'package:app/src/routes/index.dart';
import 'package:app/src/screens/attendance/index.dart';
import 'package:app/src/utils/app_state_notifier.dart';
import 'package:app/src/widgets/cache_image_widget.dart';
import 'package:background_location/background_location.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared/main.dart';
import 'package:app/src/config/string_constants.dart' as string_constants;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:api_sdk/api_constants.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:background_fetch/background_fetch.dart';
const fetchBackground = "fetchBackground";
bool _enabled = true;
int _status = 0;
List<String> _events = [];

const EVENTS_KEY = "fetch_events";
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  var taskId = task.taskId;
  var timeout = task.timeout;
  if (timeout) {
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }

  print("[BackgroundFetch] Headless event received: $taskId");
  var status = await BackgroundFetch.configure(BackgroundFetchConfig(
    minimumFetchInterval: 15,
    forceAlarmManager: false,
    stopOnTerminate: false,
    startOnBoot: true,
    enableHeadless: true,
    requiresBatteryNotLow: false,
    requiresCharging: false,
    requiresStorageNotLow: false,
    requiresDeviceIdle: false,
    requiredNetworkType: NetworkType.NONE,
  ), _onBackgroundFetch);
  print('[BackgroundFetch] configure success: $status');
  var timestamp = DateTime.now();

  var prefs = await SharedPreferences.getInstance();

  // Read fetch_events from SharedPreferences
  var events = <String>[];
  var json = prefs.getString(EVENTS_KEY);
  if (json != null) {
    events = jsonDecode(json).cast<String>();
  }
  // Add new event.
  events.insert(0, "$taskId@$timestamp [Headless]");
  // Persist fetch events in SharedPreferences
  prefs.setString(EVENTS_KEY, jsonEncode(events));

  if (taskId == 'flutter_background_fetch') {
    /* DISABLED:  uncomment to fire a scheduleTask in headlessTask.
    BackgroundFetch.scheduleTask(TaskConfig(
        taskId: "com.transistorsoft.customtask",
        delay: 5000,
        periodic: false,
        forceAlarmManager: false,
        stopOnTerminate: false,
        enableHeadless: true
    ));
     */
  }
  BackgroundFetch.finish(taskId);
}
class HomeScreen extends StatelessWidget {
  // ignore: close_sinks
  final AuthenticationBloc authenticationBloc =
      AuthenticationBlocController().authenticationBloc;

  @override
  Widget build(BuildContext context) {
    authenticationBloc.add(GetUserData());
    BackgroundLocation.setAndroidNotification(
      title: 'Background service is running',
      message: 'Background location in progress',
      icon: '@mipmap/ic_launcher',
    );
    BackgroundLocation.startLocationService(
        distanceFilter: 20);
  BackgroundLocation.setAndroidConfiguration(10);
    BackgroundLocation.getLocationUpdates((location) {
      print(location);
    });

    getCurrentLocation();
    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

    return WillPopScope(
        onWillPop: () async => false,
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            cubit: authenticationBloc,
            builder: (BuildContext context, AuthenticationState state) {
              if (state is SetUserData) {
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
                            authenticationBloc.add(UserLogOut());
                          }),
                    ],
                  ),
                  body:Center( child: Text("Dashboard")),

                  drawer: Drawer(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        DrawerHeader(

                         child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Container(

                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Colors.white),
                                    child: CachedImage(
                                      imageUrl:
                                          state.currentUserData.profilePic,
                                      fit: BoxFit.fitWidth,
                                      errorWidget: Image.network(
                                        state.currentUserData.profilePic,
                                      ),
                                      width: 80,
                                      height: 80,
                                      placeholder: CircularProgressIndicator(),
                                    ),
                                  ),

                                  Switch(
                                    value:
                                        Provider.of<AppStateNotifier>(context)
                                            .isDarkMode,
                                    onChanged: (value) {
                                      Provider.of<AppStateNotifier>(context,
                                              listen: false)
                                          .updateTheme(value);
                                    },
                                  ),
                                ],


                              ),

                            ],
                          ),




                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor,
                          ),

                        ),
                        TextButton(
                          style: string_constants.flatButtonStyle,
                          onPressed: () {
                            print("attend");
                            Navigator.pushReplacementNamed(context,'/attendance');
                          },
                          child: Text('Click here for attendance'),
                        ),
                        ListTile(
                          title: Text("Employee: "+
                              '${state.currentUserData.Employee} ',
                              style: Theme.of(context).textTheme.bodyText2),
                        ),
                        ListTile(
                          title: Text("EmpRole: "+state.currentUserData.EmpRole,
                              style: Theme.of(context).textTheme.bodyText2),
                        ),
                        ListTile(
                          title: Text("Emp Id: "+state.currentUserData.id.toString(),
                              style: Theme.of(context).textTheme.bodyText2),
                        ),  ListTile(
                          title: Text("Emp Code: "+state.currentUserData.EmpCode.toString(),
                              style: Theme.of(context).textTheme.bodyText2),
                        ),


                      ],
                    ),
                  ),
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
    print('This is current Location ' + location.toMap().toString());
  });
}
void _onBackgroundFetch(String taskId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  DateTime timestamp = new DateTime.now();
  // This is the fetch-event callback.
  print("[BackgroundFetch] Event received: $taskId");

  // Persist fetch events in SharedPreferences
  prefs.setString(EVENTS_KEY, jsonEncode(_events));

  if (taskId == "flutter_background_fetch") {
    // Schedule a one-shot task when fetch event received (for testing).

    BackgroundFetch.scheduleTask(TaskConfig(
        taskId: "com.transistorsoft.customtask",
        delay: 5000,
        periodic: false,
        forceAlarmManager: true,
        stopOnTerminate: false,
        enableHeadless: true,
        requiresNetworkConnectivity: true,
        requiresCharging: true
    ));
    var _dio = Dio();

    var formData = FormData.fromMap({
      'pkEmpId': prefs.getString("pkEmpId"),
      'selecteddate': DateTime.now(),
      'lat':BackgroundLocation().getCurrentLocation(),
    });
    Response response = await _dio.post('${apiConstants["geolocation"]}',
      options: Options(headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      }),
      data: jsonEncode(formData),
    );

  }
  // IMPORTANT:  You must signal completion of your fetch task or the OS can punish your app
  // for taking too long in the background.
  BackgroundFetch.finish(taskId);
}

