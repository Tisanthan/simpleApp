import 'package:flutter/material.dart';
import 'package:simpleadd/constants/constant.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onClicked;

  const ButtonWidget(
      {Key? key,
      required this.text,
      required this.onClicked,
      this.color = Colors.white,
      this.backgroundColor = primaryColor})
      : super(key: key);
  @override
  Widget build(BuildContext context) => MaterialButton(

      // style: ElevatedButton.styleFrom(
      //     primary: backgroundColor,
      //     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
      elevation: 5.0,
      colorBrightness: Brightness.dark,
      splashColor: Colors.white,
      minWidth: 70.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      color: backgroundColor,
      onPressed: onClicked,
      child: Text(
        text,
        style: TextStyle(fontSize: 20, color: color),
      ));
}
