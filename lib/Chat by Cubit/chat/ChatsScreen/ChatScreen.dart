import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../auth/Login/Login.dart';
import 'MessageScreen.dart';
import 'chat_cubit.dart';
class ChatPage extends StatelessWidget {
  ChatPage({super.key});
  final chatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final myCubitChat = BlocProvider.of<ChatCubit>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                GoogleSignIn google = GoogleSignIn();
                google.disconnect();
                await FirebaseAuth.instance.signOut();
                Get.offAll(Login());
              },
              icon: const Icon(Icons.exit_to_app_outlined))
        ],
        backgroundColor: Colors.blue,
        title: const Text(
          'Chat',
          style: TextStyle(fontSize: 22),
        ),
        centerTitle: true,
      ),
      body:
      Column(
        children: [
          Expanded(
            // QuerySnapshot = all the document that you have = data
            // StreamBuilder ==  realtime changes = change occurs (modification, deleted or added).
            child: StreamBuilder<QuerySnapshot>(
              stream: myCubitChat.getMessage(),
              /// to Scroll ListView to the end ?
              // 1 /  descending: true
              // 2 /  reverse: true,

              // snapshot = place store your data
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading messages"));
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                var docs = snapshot.data!.docs;
                return BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    return ListView.builder(
                      reverse: true,
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        var message = docs[index]['message'];
                        var senderId = docs[index]['senderId'];
                        var messageTime = docs[index]['messageTime'] ?? Timestamp.now();
                        bool isMe = senderId == FirebaseAuth.instance.currentUser!.uid;
                        //  change time from firebase to  DateTime(real)
                        DateTime time = messageTime.toDate();
                        String formattedTime = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                        if (isMe) {
                          return GestureDetector(
                            onTap: () {
                              showDeleteDialog(docs[index].id,context);
                            },
                            child: MessageScreen(
                              message: message,
                              isMe: isMe,
                              time: formattedTime,
                            ),
                          );
                        } else {
                          return MessageScreen(
                            message: message,
                            isMe: isMe,
                            time: formattedTime,
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: chatController,
              onSubmitted: (value) {
                myCubitChat.sendMessage(value);
                chatController.clear();
              },
              decoration: InputDecoration(
                suffixIcon:  IconButton(
                    onPressed: () {
                      myCubitChat.sendMessage(chatController.text);
                      chatController.clear();
                    },
                    icon:Icon(Icons.send,) ),
                hintText: 'Send Message',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: Colors.blue, width: 3),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: Colors.green),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  void showDeleteDialog(String docId,context) {
    final myCubit = BlocProvider.of<ChatCubit>(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("هل تريد حذف الرسالة؟"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: context), // إلغاء
            child: const Text("لا"),
          ),
          TextButton(
            onPressed: () async {
              await myCubit.deleteMessage(docId, context);
            },
            child: const Text("نعم"),
          ),
        ],
      ),
    );
  }
}