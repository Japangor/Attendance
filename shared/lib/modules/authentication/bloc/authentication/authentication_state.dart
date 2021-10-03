import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:shared/main.dart';
import 'package:shared/modules/authentication/models/current_user_data.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class AppAutheticated extends AuthenticationState {}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationStart extends AuthenticationState {}

class UserLogoutState extends AuthenticationState {}

class SetUserData extends AuthenticationState {
  final UserData currentUserData;
  final Token getattend;
  SetUserData({this.currentUserData,this.getattend});
  @override
  List<Object> get props => [currentUserData,getattend];
}


class AuthenticationNotAuthenticated extends AuthenticationState {}

class AuthenticationFailure extends AuthenticationState {
  final String message;

  AuthenticationFailure({@required this.message});

  @override
  List<Object> get props => [message];
}
