
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

Future<void> customDialog(
    BuildContext context,
    String title,
    String desc,
    DialogType dialogType,
    ) async {
  await AwesomeDialog(
    context: context,
    dialogType: dialogType,
    animType: AnimType.rightSlide,
    title: title,
    desc: desc,
    btnOkOnPress: () {}, // ضروري عشان الديلوج يختفي بعد الضغط
  ).show();
}
