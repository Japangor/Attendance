import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/rest/rest_api_handler_data.dart';

class ApiSdk {
  static loginWithEmailAndPassword(dynamic body) async {
    final response = await RestApiHandlerData.getData(
        '${apiConstants["auth"]}/LoginApi');
    return response;
  }

  static signUpWithEmailAndPassword(dynamic body) async {
    final response = await RestApiHandlerData.postData(
        '${apiConstants["auth"]}/register', body);
    return response;
  }

  static getUserData(int id) async {
    final response =
        await RestApiHandlerData.getData('${apiConstants["auth"]}/LoginAPI?username=govardhandive&password=govardhan1&lat=37.4219983&longt=65464646');
    return response;
  }

  // static fetchTopId() async {
  //   final response = await RestApiHandlerData.getData(
  //       '${apiConstants["hacker_news"]}/topstories.json');
  //   return response;
  // }
  //
  // static fetchItems(int id) async {
  //   final response = await RestApiHandlerData.getData(
  //       '${apiConstants["hacker_news"]}/item/$id.json');
  //   return response;
  // }
}
