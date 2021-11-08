import 'package:flutter/material.dart';

Widget showErrorMessage(_errorMessage) {
  if (_errorMessage.length > 0 && _errorMessage != null) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: new Text(
          _errorMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 13.0,
              color: Colors.red,
              height: 1.0,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  } else {
    return new Container(
      height: 0.0,
    );
  }
}
