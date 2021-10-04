// home screen contents
import 'package:app/src/config/image_constants.dart';
import 'package:app/src/utils/app_state_notifier.dart';
import 'package:app/src/widgets/cache_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared/main.dart';
import 'package:app/src/config/string_constants.dart' as string_constants;

class navigationDrawer extends StatelessWidget {
  // ignore: close_sinks
  final AuthenticationBloc authenticationBloc =
      AuthenticationBlocController().authenticationBloc;

  @override
  Widget build(BuildContext context) {
    authenticationBloc.add(GetUserData());
    return WillPopScope(
        onWillPop: () async => false,
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            cubit: authenticationBloc,
            builder: (BuildContext context, AuthenticationState state) {
              if (state is SetUserData) {
                return Drawer(
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
                      TextButton(
                        style: string_constants.flatButtonStyle,
                        onPressed: () {
                          print("dash");
                          Navigator.pushReplacementNamed(context,'/attendance');
                        },
                        child: Text('Click here for Attendance'),
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
                );
              }
              return Scaffold(
                body: Center(
                ),
              );
            }));
  }
}
