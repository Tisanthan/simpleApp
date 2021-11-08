import 'package:flutter/material.dart';
import 'package:simpleadd/widget/material_button.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ButtonWidget(
            text: "SignIn",
            onClicked: () => Navigator.pushNamed(context, '/signIn'),
          ),
          ButtonWidget(
            text: "Register",
            onClicked: () => Navigator.pushNamed(context, '/register'),
          )
        ],
      ),
    );
  }
}
