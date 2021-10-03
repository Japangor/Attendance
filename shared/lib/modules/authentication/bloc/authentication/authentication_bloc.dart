import 'dart:convert';
import 'dart:io';

import 'package:api_sdk/api_constants.dart';
import 'package:bloc/bloc.dart';
import 'package:shared/main.dart';
import 'package:shared/modules/authentication/models/current_user_data.dart';

import 'package:shared/modules/authentication/resources/authentication_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'authentication_bloc_public.dart';
import 'package:http/http.dart' as http;
class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(AuthenticationInitial());
  final AuthenticationRepository authenticationService =
      AuthenticationRepository();
  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event) async* {
    final SharedPreferences sharedPreferences = await prefs;
    if (event is AppLoadedup) {
      yield* _mapAppSignUpLoadedState(event);
    }

    if (event is UserSignUp) {
      yield* _mapUserSignupToState(event);
    }

    if (event is UserLogin) {
      yield* _mapUserLoginState(event);
    }
    if (event is UserLogOut) {
      sharedPreferences.setString('Employee', null);
      sharedPreferences.setInt('Employee', null);
      yield UserLogoutState();
    }
    if (event is GetUserData) {
      int currentUserId = sharedPreferences.getInt('userId');
      final data = await authenticationService.getUserData(currentUserId ?? 4);
      final currentUserData = UserData.fromJson(data);
      yield SetUserData(currentUserData: currentUserData);


    }
    if (event is GetUserData2) {
      final data = await authenticationService.getUserData(4);
      final currentUserData = Token.fromJson(data);
      yield SetUserData(getattend: currentUserData);


    }
  }

  Stream<AuthenticationState> _mapAppSignUpLoadedState(
      AppLoadedup event) async* {
    yield AuthenticationLoading();
    try {
      await Future.delayed(Duration(milliseconds: 500)); // a simulated delay
      final SharedPreferences sharedPreferences = await prefs;
      if (sharedPreferences.getString('Employee') != null) {
        print(sharedPreferences.getString('attendancetype'));
        yield AppAutheticated();
      } else {
        yield AuthenticationStart();
      }
    } catch (e) {
      yield AuthenticationFailure(
          message: e.message ?? 'An unknown error occurred');
    }
  }

  Stream<AuthenticationState> _mapUserSignupToState(UserSignUp event) async* {
    final SharedPreferences sharedPreferences = await prefs;
    yield AuthenticationLoading();
    try {
      await Future.delayed(Duration(milliseconds: 500)); // a simulated delay
      final data = await authenticationService.signUpWithEmailAndPassword(
          event.email, event.password);

      if (data["error"] == null) {
        final currentUser = UserData.fromJson(data);
        if (currentUser != null) {

          yield AppAutheticated();
        } else {
          yield AuthenticationNotAuthenticated();
        }
      } else {
        yield AuthenticationFailure(message: data["error"]);
      }
    } catch (e) {
      yield AuthenticationFailure(
          message: e.toString() ?? 'An unknown error occurred');
    }
  }

  Stream<AuthenticationState> _mapUserLoginState(UserLogin event) async* {
    final SharedPreferences sharedPreferences = await prefs;
    yield AuthenticationLoading();
    try {
      await Future.delayed(Duration(milliseconds: 500)); // a simulated delay
      final data = await authenticationService.loginWithEmailAndPassword(
          event.email, event.password);


      var loginurl = '${apiConstants["auth"]}/LoginApi';
      Map<String, String> loginparam = {
        'username': event.email,
        'password': event.password,
        'lat':event.lat,
        'longt':event.long
      };

      var headers = {
        HttpHeaders.authorizationHeader: 'Token ',
        HttpHeaders.contentTypeHeader: 'application/json',
      };

      String loginquery = Uri(queryParameters: loginparam).query;

      var loginrequestUrl = loginurl + '?' + loginquery; // result - https://www.myurl.com/api/v1/user?param1=1&param2=2
      var response = await http.get(loginrequestUrl, headers: headers);
      Map<String, dynamic> loginresponseJson = json.decode(response.body);
      print(loginresponseJson['success']);

      if (loginresponseJson["success"] == "true") {
        print((loginresponseJson.toString()));
        final currentUser = CurrentUserData.fromJson(loginresponseJson);
        if (currentUser != null) {
          sharedPreferences.setInt('pkEmpId', currentUser.data.id).toString();
          sharedPreferences.setString('Employee', currentUser.data.firstName);
          sharedPreferences.setString('EmpRole', currentUser.data.lastName);
          sharedPreferences.setString('Employee', currentUser.data.email);

          // currentUser.data.email=responseJson['profilePic'];
          // print(currentUser.data.email);


          final currentUserData = UserData(profilePic: loginresponseJson['profilePic'],EmpCode: loginresponseJson['EmpCode'],Employee: loginresponseJson['Employee'],EmpRole: loginresponseJson['EmpRole'],id: loginresponseJson['pkEmpId']);

          var attendance = '${apiConstants["auth"]}/AttendanceGetAPI';
          Map<String, String> queryParams = {
            'EmpCode': currentUserData.id,
            'selecteddate': DateTime.now().toString()

          };

          var attendheaders = {
            HttpHeaders.contentTypeHeader: 'application/json',
          };

          String attendquery = Uri(queryParameters: queryParams).query;

          var attendUrl = attendance + '?' + attendquery; // result - https://www.myurl.com/api/v1/user?param1=1&param2=2
          var attendresponse = await http.get(attendUrl, headers: attendheaders);
          Map<String, dynamic> attendresponseJson = json.decode(attendresponse.body);
          print(DateTime.now().toString());
          final setattendance = Token(attendance: attendresponseJson['success']);

          SetUserData(currentUserData: currentUserData);

          SetUserData(getattend: setattendance);

          final currentUser2 = Token.fromJson(attendresponseJson);
          currentUser2.attendance=attendresponseJson['success'];
          sharedPreferences.setString('attendancetype', currentUser2.attendance);

          print((currentUser2.attendance));


          yield AppAutheticated();
        } else {
          yield AuthenticationFailure(message: loginresponseJson["error"]);
        }
      } else {
        yield AuthenticationFailure(message: loginresponseJson["error"]);
      }
    } catch (e) {
      yield AuthenticationFailure(
          message: e.toString());
    }
  }
}
