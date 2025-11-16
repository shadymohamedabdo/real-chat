import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Chat by Cubit/chat/ChatsScreen/ChatScreen.dart';
import 'Chat by Cubit/chat/ChatsScreen/chat_cubit.dart';
import 'Chat by Cubit/chat/auth/Login/Login.dart';
import 'Chat by Cubit/chat/auth/Login/login_cubit.dart';
import 'Chat by Cubit/chat/auth/Register/register_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      appId: 'com.example.myapp',
      apiKey: 'AIzaSyDOsAwzakSvA0XAwr27XMsmDCO3zr5tl1A',
      messagingSenderId: '540179920029',
      projectId: 'chat-app-29c07',
    ),
  );
  runApp(const MyApp()); }

class MyApp extends StatelessWidget {

  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider( create: (context) => LoginCubit(),),
        BlocProvider( create: (context) => RegisterCubit(),),
        BlocProvider( create: (context) => ChatCubit(),)
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home:
          // to have not login in every time
          FirebaseAuth.instance.currentUser != null &&
              // to force him Verified his email before logging
              FirebaseAuth.instance.currentUser!.emailVerified
              ? ChatPage()
              :  Login()
      ),
    );
  }
}




// void main() async{
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//       options:  const FirebaseOptions(
//         // after working email&pass
//           appId: 'com.example.myapp', //from build gradle in app
//           apiKey: 'AIzaSyDOsAwzakSvA0XAwr27XMsmDCO3zr5tl1A', // from your project in firebase(Web API Key )
//           messagingSenderId: '540179920029', //from your project in firebase in Cloud Messaging(Sender ID)
//           projectId: 'chat-app-29c07' //general
//       )
//   );
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       // home: Taskss(),
//       debugShowCheckedModeBanner: false,
//       // to have not login in every time
//       home: FirebaseAuth.instance.currentUser != null &&
//           // to force him Verified his email before logging
//           FirebaseAuth.instance.currentUser!.emailVerified ?
//       ChatPage() : BlocProvider(
//     create: (_) => LoginCubit(),
//     child: const Login(),
//     ));
//   }
// }

