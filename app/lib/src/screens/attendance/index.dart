// home screen contents
import 'dart:convert';
import 'dart:io';
import 'package:api_sdk/api_constants.dart';

import 'package:app/src/config/image_constants.dart';
import 'package:app/src/screens/drawer.dart';
import 'package:app/src/screens/home/index.dart';
import 'package:app/src/utils/app_state_notifier.dart';
import 'package:app/src/widgets/cache_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared/main.dart';
import 'package:app/src/config/string_constants.dart' as string_constants;
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
final bool _visible = false;
String attand;
class attendance extends StatefulWidget {
  @override
  attendancee createState() => attendancee();
}
Map<String, String> globals = {
  "success": "",
};

class attendancee extends State<attendance> {

  // ignore: close_sinks
  final AuthenticationBloc authenticationBloc =
      AuthenticationBlocController().authenticationBloc;
  var localAuth = LocalAuthentication();
  final LocalAuthentication localAuthentication = LocalAuthentication();

  @override
  Widget build(BuildContext context) {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    String formattedTime = DateFormat.Hm().format(now);
    authenticationBloc.add(GetUserData());

    return WillPopScope(
        onWillPop: () async => true,

        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(


            cubit: authenticationBloc,
            builder: (BuildContext context, AuthenticationState state) {

              if (state is SetUserData) {

                main2() async{

                  String attand;
                  var attendance = '${apiConstants["auth"]}/AttendanceGetAPI';
                  Map<String, String> queryParams = {
                    'EmpCode': state.currentUserData.id,
                    'selecteddate': DateTime.now().toString()

                  };

                  var attendheaders = {
                    HttpHeaders.contentTypeHeader: 'application/json',
                  };

                  String attendquery = Uri(queryParameters: queryParams).query;

                  var attendUrl = attendance + '?' + attendquery; // result - https://www.myurl.com/api/v1/user?param1=1&param2=2
                  var attendresponse = await http.get(attendUrl, headers: attendheaders);
                  Map<String, dynamic> attendresponseJson = json.decode(attendresponse.body);
                  attand=attendresponseJson['success'];
                  setState(() {
                    globals["success"] = attendresponseJson['success'];



                  });


                }
                main2();






                return Scaffold (
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
                  body:
                  Column(
                    children: <Widget>[




                      if(globals["success"].contains("true")) TextButton(style: string_constants.flatButtonStyle,
                        onPressed: () async {
                          bool isAuthenticated =
                          await localAuthentication.authenticate(localizedReason: "Give your biometric");

                          if (isAuthenticated) {


                            var requestBody = {
                              'EmpCode': state.currentUserData.EmpCode,
                              'selecteddate': formattedDate,
                              'time': formattedTime,
                              'punchtype': "IN"
                            };

                            http.Response response = await http.post(
                              '${apiConstants["AttendancePostAPI"]}',
                              body: requestBody,
                            );

                            print(response.body);

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(response.body.toString()),
                            ));

                          } else {
                            print("Failed");
                          }
                        },
                        child: Text('Punch In'),),


                      if(globals["success"].contains("false")) TextButton(style: string_constants.flatButtonStyle,  onPressed: () async {
                        bool isAuthenticated =
                        await localAuthentication.authenticate(localizedReason: "Give your biometric");

                        if (isAuthenticated) {


                          var requestBody = {
                            'EmpCode': state.currentUserData.EmpCode,
                            'selecteddate': formattedDate,
                            'time': formattedTime,
                            'punchtype': "OUT"
                          };

                          http.Response response = await http.post(
                            '${apiConstants["AttendancePostAPI"]}',
                            body: requestBody,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(response.body.toString()),
                          ));


                        } else {
                          print("Failed");
                        }
                      }, child: Text('Punch Out'),),



                      // Visible only if 'hasName' is true
                    ],
                  ),

                  drawer: navigationDrawer(),
                );
              }
              return Scaffold(
                body: Center (
                ),
              );
            }));
  }
// every method which changes state should exist within class only


}
