part of 'login_cubit.dart';

@immutable
abstract class LoginState {}
// any state has 2 function

//       1 / rebuild ui after doing your changes  =
//       void togglePasswordVisibility() {
//     isPassword = !isPassword;
//     emit(LoginPasswordToggled());  // rebuild ui after doing your function// }

// 2 /  give it mission(or function) in listener state  like
// if (state is LoginFailure) {
// await customDialog(context, 'Error', state.error, DialogType.error);// }

class LoginInitial extends LoginState {}
class LoginLoading extends LoginState {}
class LoginPasswordToggled extends LoginState {}
class LoginSuccess extends LoginState {}
class PasswordResetSuccess extends LoginState {}
class LoginEmailNotVerified extends LoginState {}
class LoginFailure extends LoginState {
  final String error;
  LoginFailure(this.error);
}