import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  bool isPassword = false;
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  LoginCubit() : super(LoginInitial());

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPassword = !isPassword;
    emit(LoginPasswordToggled());
  }

  // Login with Google
  Future signInWithGoogle() async {
    try {
      emit(LoginLoading());
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        emit(LoginFailure("No account selected"));
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      await userCredential.user!.reload();

      if (userCredential.user!.emailVerified) {
        emit(LoginSuccess());
      } else {
        emit(LoginEmailNotVerified());
      }
    } catch (e) {
      emit(LoginFailure("Failed to sign in with Google. Please try again."));
    }
  }

  // Login with Email & Password
  Future signInWithEmailAndPassword() async {
    try {
      emit(LoginLoading());
      final data = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );

      await FirebaseAuth.instance.currentUser!.reload();

      if (data.user!.emailVerified) {
        emit(LoginSuccess());
      } else {
        emit(LoginEmailNotVerified());
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
          emit(LoginFailure('كلمة المرور غير صحيحة أو الحساب غير صالح.'));
          break;
        case 'invalid-email':
          emit(LoginFailure('صيغة البريد الإلكتروني غير صحيحة.'));
          break;
        case 'user-not-found':
          emit(LoginFailure('لا يوجد مستخدم بهذا البريد.'));
          break;
        case 'too-many-requests':
          emit(LoginFailure('عدد المحاولات كبير. حاول لاحقًا.'));
          break;
        default:
          emit(LoginFailure('حدث خطأ غير متوقع: ${e.code}'));
      }
    } catch (e) {
      emit(LoginFailure('Unexpected error: $e'));
    }
  }

  // Password Reset
  Future sendPasswordResetEmail() async {
    if (email.text.trim().isEmpty) {
      emit(LoginFailure('Please enter your email'));
      return;
    }

    try {
      emit(LoginLoading());
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text.trim());
      email.clear();
      password.clear();
      emit(PasswordResetSuccess());
    } catch (e) {
      emit(LoginFailure('This email is unavailable, please register'));
    }
  }
}
