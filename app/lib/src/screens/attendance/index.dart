// home screen contents
import 'dart:convert';
import 'dart:io';
import 'package:api_sdk/api_constants.dart';

import 'package:app/src/config/image_constants.dart';
import 'package:app/src/screens/home/index.dart';
import 'package:app/src/utils/app_state_notifier.dart';
import 'package:app/src/widgets/cache_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared/main.dart';
import 'package:app/src/config/string_constants.dart' as string_constants;
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

SharedPreferences prefs;
final String attand="";
final bool _visible = false;

class attendance extends StatelessWidget {


  // ignore: close_sinks
  final AuthenticationBloc authenticationBloc =
      AuthenticationBlocController().authenticationBloc;
  var localAuth = LocalAuthentication();
  final LocalAuthentication localAuthentication = LocalAuthentication();

  @override
  Widget build(BuildContext context) {

    authenticationBloc.add(GetUserData());
main2();

    return WillPopScope(
        onWillPop: () async => true,

        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(


            cubit: authenticationBloc,
            builder: (BuildContext context, AuthenticationState state) {

              if (state is SetUserData) {
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
                      Visibility(visible:_visible ,child: TextButton(style: string_constants.flatButtonStyle,
                        onPressed: () async {
                          bool isAuthenticated =
                          await localAuthentication.authenticate(localizedReason: "Give your biometric");

                          if (isAuthenticated) {
                            var _dio = Dio();

                            var formData = FormData.fromMap({
                              'pkEmpId': state.currentUserData.id,
                              'selecteddate': DateTime.now(),
                              'punchtype':"I"
                            });
                            Response response = await _dio.post('${apiConstants["AttendancePostAPI"]}',
                              options: Options(headers: {
                                HttpHeaders.contentTypeHeader: "application/json",
                              }),
                              data: jsonEncode(formData),
                            );

                          } else {
                            print("Failed");
                          }
                        },
                        child: Text('Punch In'),),
                      ),


                   TextButton(style: string_constants.flatButtonStyle,
                  onPressed: () async {
                    bool isAuthenticated =
                    await localAuthentication.authenticate(localizedReason: "Give your biometric");

                    if (isAuthenticated) {
                      var _dio = Dio();

                      var formData = FormData.fromMap({
                        'pkEmpId': state.currentUserData.id,
                        'selecteddate': DateTime.now(),
                        'punchtype':"I"
                      });
                      Response response = await _dio.post('${apiConstants["AttendancePostAPI"]}',
                        options: Options(headers: {
                          HttpHeaders.contentTypeHeader: "application/json",
                        }),
                        data: jsonEncode(formData),
                      );

                    } else {
                     print("Failed");
                    }
                  },
                  child: Text('Punch In'),),


                     TextButton(style: string_constants.flatButtonStyle,  onPressed: () async {
                       bool isAuthenticated =
                       await localAuthentication.authenticate(localizedReason: "Give your biometric");

                       if (isAuthenticated) {


                         var _dio = Dio();

                         var formData = FormData.fromMap({
                           'pkEmpId': state.currentUserData.id,
                           'selecteddate': DateTime.now(),
                           'punchtype':"O"
                         });
                         Response response = await _dio.post('${apiConstants["AttendancePostAPI"]}',
                           options: Options(headers: {
                             HttpHeaders.contentTypeHeader: "application/json",
                           }),
                           data: jsonEncode(formData),

                         );
                         print(response);


                       } else {
                         print("Failed");
                       }
                     }, child: Text('Punch Out'),),



                      // Visible only if 'hasName' is true
                    ],
                  ),

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
                                        AllImages().kDefaultImage,
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
                            print("dash");
                            Navigator.pushReplacementNamed(context,'/home');
                          },
                          child: Text('Click here for Dashboard'),
                        ),
                        ListTile(
                          title: Text("Employe"+
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
                body: Center (
                ),
              );
            }));
  }
}
void main2() async{
  String attand;bool _visible;
  final SharedPreferences sharedPreferences = await prefs;
  prefs = await SharedPreferences.getInstance();
  attand=prefs.getString('attendancetype');
  if(attand=='false')
    {
      _visible=true;
    }
  print(attand+"safgas");


}