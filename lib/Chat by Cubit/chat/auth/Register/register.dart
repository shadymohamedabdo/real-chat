import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:chat/Chat%20by%20Cubit/chat/auth/Register/register_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../ChatsScreen/ChatScreen.dart';
import '../../Component/awesome_dialog.dart';
import '../../Component/Button.dart';
import '../../Component/logo.dart';
import '../../Component/text.dart';
import '../../Component/textForm.dart';
import '../Login/Login.dart';

class Register extends StatelessWidget {
  Register({super.key});
  final formRegister = GlobalKey<FormState>();

  final username = TextEditingController();
  final password = TextEditingController();
  final email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) async {
        if (state is RegisterFailure) {
          await customDialog(context, 'Error', state.errorMessage, DialogType.error);
        } else if (state is RegisterEmailNotVerified) {
          await customDialog(
            context,
            'تحقق من التفعيل',
            'تم إرسال رابط التفعيل لبريدك الإلكتروني.\nبعد التفعيل، اضغط على "تحقق من التفعيل".',
            DialogType.warning,
          );
        } else if (state is RegisterSuccess) {
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => ChatPage()),
                  (route) => false,
            );
          }
        }
      },
      builder: (context, state) {
        final myCubitRegister = BlocProvider.of<RegisterCubit>(context);

        return ModalProgressHUD(
          inAsyncCall: state is RegisterLoading,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue,
            ),
            body: Padding(
              padding: const EdgeInsets.all(7.0),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: formRegister,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const customLogo(),
                      const customText(title: 'Sign up', fontSize: 25),
                      const Text('Sign up for using app', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 10),
                      const customText(title: 'Username', fontSize: 18),
                      customTextForm(
                        prefixIcon: const Icon(Icons.person_add_rounded),
                        validator: 'please Enter your name',
                        hintText: 'Username',
                        myController: username,
                      ),
                      const customText(title: 'Email', fontSize: 20),
                      customTextForm(
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: 'please Enter your email',
                        hintText: 'Enter your email',
                        myController: email,
                      ),
                      const customText(title: 'Password', fontSize: 18),
                      customTextForm(
                        onFieldSubmitted: (value) async {
                          if (formRegister.currentState!.validate()) {
                            await myCubitRegister.createUserWithEmailAndPassword(
                              email.text.trim(),
                              password.text.trim(),
                            );
                          }
                        },
                        prefixIcon: const Icon(Icons.password),
                        validator: 'please Enter your password',
                        hintText: 'Enter your password',
                        myController: password,
                      ),
                      customButton(
                        onPressed: () async {
                          if (formRegister.currentState!.validate()) {
                            await myCubitRegister.createUserWithEmailAndPassword(
                              email.text.trim(),
                              password.text.trim(),
                            );
                          }
                        },
                        color: Colors.blue,
                        text: 'Sign Up',
                      ),

                      // ✅ زر "تحقق من التفعيل" لما يضغط يتأكد هل المستخدم فعّل ولا لأ
                      if (state is RegisterEmailNotVerified) ...[
                        ///"لو الشرط اتحقق، ضيف العناصر اللي جوه الـ List دي ([]) ضمن الـ Widget Tree".
                        ///if (condition) ...[widgets]
                        const SizedBox(height: 20),
                        customButton(
                          onPressed: () async {
                            await myCubitRegister.checkEmailVerification();
                          },
                          color: Colors.green,
                          text: 'تحقق من التفعيل',
                        ),
                      ],

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const customText(title: 'Have an account ?', fontSize: 14),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => Login()),
                              );
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}