// ignore_for_file: unnecessary_this

import 'package:flutter/material.dart';
import 'package:simpleadd/viewmodel/firebase_core.dart';
import 'package:simpleadd/widget/error_message.dart';

class SignInScreen extends StatefulWidget {
  final FirebaseCor cor = new Auth();
  SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _obsecureText = !_obsecureText;
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  late String _password;
  late String _email;
  late String _errorMessage;
  late bool _isLoading, _obsecureText = false;

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      print('Form Validate : true');
      return true;
    }
    print('Form Validate : false');
    return false;
  }

  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (validateAndSave()) {
      String userId = "";
      try {
        userId = await widget.cor.signIn(_email, _password);
        print('Signed in: $userId');
        setState(() {
          _isLoading = false;
        });

        if (userId.length > 0 && userId != null) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/upload', (route) => false);
        }
      } catch (e) {
        print('Error: $e');
        var errorMessage;
        switch (e) {
          case "ERROR_INVALID_EMAIL":
            errorMessage = "Your email address appears to be malformed.";
            break;
          case "ERROR_WRONG_PASSWORD":
            errorMessage = "Your password is wrong.";
            break;
          case "ERROR_USER_NOT_FOUND":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "ERROR_USER_DISABLED":
            errorMessage = "User with this email has been disabled.";
            break;
          case "ERROR_TOO_MANY_REQUESTS":
            errorMessage = "Too many requests. Try again later.";
            break;
          case "ERROR_OPERATION_NOT_ALLOWED":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }
        setState(() {
          _isLoading = false;
          _errorMessage = errorMessage;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(top: 300.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      margin:
                          EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                      child: TextFormField(
                        onSaved: (value) => _email = value!.trim(),
                        maxLines: 1,
                        keyboardType: TextInputType.emailAddress,
                        autofocus: false,
                        validator: (val) =>
                            val!.isEmpty ? 'Email can\'t be empty' : null,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).nextFocus(),
                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          labelText: "Email Address",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                      child: TextFormField(
                        onSaved: (value) => _password = value!,
                        maxLines: 1,
                        autofocus: false,
                        obscureText: _obsecureText,
                        // code to move to next input field
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).unfocus(),
                        validator: (val) => val!.length < 6
                            ? (val.isEmpty
                                ? 'Password can\'t be empty'
                                : 'Password too short.')
                            : null,
                        decoration: InputDecoration(
                          // prefixIcon: Icon(Icons.security),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.remove_red_eye,
                              color: _obsecureText ? Colors.blue : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() =>
                                  this._obsecureText = !this._obsecureText);
                            },
                          ),
                          fillColor: Colors.white,
                          labelText: "Password",
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                        ),
                      ),
                    ),
                    showErrorMessage(_errorMessage),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.center,
                child: MaterialButton(
                  elevation: 5.0,
                  colorBrightness: Brightness.dark,
                  splashColor: Colors.greenAccent,
                  minWidth: 200.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  color: const Color.fromRGBO(0, 172, 191, 1.0),
                  onPressed: () => validateAndSubmit(),
                  child: SizedBox(
                    height: 30,
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              "sighIn",
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
