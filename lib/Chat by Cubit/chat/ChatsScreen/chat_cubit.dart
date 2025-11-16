import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:meta/meta.dart';

import '../Component/const.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());
  // object from CollectionReference ('Messages' )
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  /// create new collection (Messages)
  // get data from Messages
  CollectionReference messages = FirebaseFirestore.instance.collection(kMessagesCollection);
//const kMessagesCollection = 'Messages' ;

  Stream<QuerySnapshot> getMessage()  {
    return messages.orderBy('messageTime', descending: true).snapshots();
  }
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    //  message =  field or Sub collection
    // add what you want in your collection(messages) like message,time ,id ...etc
    try {
      await messages.add({
        'message': text.trim(),
        'messageTime': FieldValue.serverTimestamp(),
        // uid = User ID = every user in Firebase Authentication  has different ID
        'senderId': FirebaseAuth.instance.currentUser!.uid,
      });
    } catch (e) {
      emit(ChatFailure( chatError: 'فشل إرسال الرسالة'));
    }
  }
  deleteMessage(String docId,Newcontext)async{
    await FirebaseFirestore.instance
        .collection(kMessagesCollection)
        .doc(docId)
        .delete();
    Get.back(result: Newcontext); // إغلاق بعد الحذف
  }

}