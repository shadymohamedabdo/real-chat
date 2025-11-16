import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../ChatsScreen/ChatScreen.dart';
import '../../Component/awesome_dialog.dart';
import '../../Component/Button.dart';
import '../../Component/logo.dart';
import '../../Component/text.dart';
import '../../Component/textForm.dart';
import '../Register/register.dart';
import 'login_cubit.dart';
class Login extends StatelessWidget {
  Login({super.key});
  final formLogin = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      builder: (context, state) {
        final myCubitLogin = BlocProvider.of<LoginCubit>(context);

        return ModalProgressHUD(
          inAsyncCall: state is LoginLoading,
          child: Scaffold(
            appBar: AppBar(backgroundColor: Colors.blue),
            body: Padding(
              padding: const EdgeInsets.all(7.0),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: formLogin,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const customLogo(),
                      const customText(title: 'Login', fontSize: 25),
                      const Text('Login to continue using app', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 18),
                      const customText(title: 'Email', fontSize: 20),
                      customTextForm(
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: 'please enter your email',
                        hintText: 'Enter your email',
                        myController: myCubitLogin.email,
                      ),
                      const customText(title: 'Password', fontSize: 18),
                      TextFormField(
                        controller: myCubitLogin.password,
                        obscureText: myCubitLogin.isPassword,
                        maxLength: 25,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) async {
                          if (formLogin.currentState?.validate() ?? false) {
                            await myCubitLogin.signInWithEmailAndPassword();
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please enter your password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.password),
                          suffixIcon: IconButton(
                            onPressed: myCubitLogin.togglePasswordVisibility,
                            icon: myCubitLogin.isPassword
                                ? const Icon(Icons.remove_red_eye)
                                : const Icon(Icons.visibility_off),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: const BorderSide(color: Colors.blue, width: 3),
                          ),
                          hintText: 'Enter your password',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () async {
                            await myCubitLogin.sendPasswordResetEmail();
                          },
                          child: const Text(
                            'Forget Password?',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ),
                      ),
                      customButton(
                        onPressed: () async {
                          if (formLogin.currentState?.validate() ?? false) {
                            await myCubitLogin.signInWithEmailAndPassword();
                          }
                        },
                        color: Colors.blue,
                        text: 'Login',
                      ),
                      const SizedBox(height: 20),
                      customButton(
                        onPressed: () => myCubitLogin.signInWithGoogle(),
                        color: Colors.red,
                        text: 'Login with Google',
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const customText(title: "Don't have an account?", fontSize: 14),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => Register()),
                              );
                            },
                            child: const Text('Register'),
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
      listener: (context, state) async {
        if (state is LoginFailure) {
          await customDialog(context, 'Error', state.error, DialogType.error);
        } else if (state is LoginEmailNotVerified) {
          await customDialog(context, 'Warning', 'Check your email and verify it', DialogType.warning);
        } else if (state is LoginSuccess) {
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => ChatPage()),
                  (route) => false,
            );
          }
        } else if (state is PasswordResetSuccess) {
          await customDialog(
            context,
            'Success',
            'Check your email to reset your password',
            DialogType.success,
          );
        }
      },
    );
  }
}
