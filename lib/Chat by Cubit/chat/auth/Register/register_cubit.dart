import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  /// إنشاء حساب جديد
  Future<void> createUserWithEmailAndPassword(String email, String password) async {

    try {
      emit(RegisterLoading());
      // ✅ إنشاء المستخدم مباشرة بدون التحقق المسبق
      final data = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ✅ إرسال رابط التحقق
      await data.user!.sendEmailVerification();

      // ❗ المستخدم لسه ما فعّلش الإيميل
      emit(RegisterEmailNotVerified());

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(RegisterFailure('كلمة المرور ضعيفة جدًا.'));
      } else if (e.code == 'invalid-email') {
        emit(RegisterFailure('صيغة البريد الإلكتروني غير صحيحة.'));
      } else if (e.code == 'email-already-in-use') {
        emit(RegisterFailure('هذا البريد مسجّل بالفعل. استخدم بريدًا آخر.'));
      } else {
        emit(RegisterFailure(e.message ?? 'حدث خطأ غير معروف.'));
      }
    } catch (e) {
      emit(RegisterFailure('خطأ غير متوقع: $e'));
    }
  }

  /// 🔄 التحقق يدويًا إذا المستخدم فعّل الإيميل
  Future<void> checkEmailVerification() async {
    await FirebaseAuth.instance.currentUser?.reload();
    bool isVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (isVerified) {
      emit(RegisterSuccess());
    } else {
      emit(RegisterEmailNotVerified());
    }
  }
}