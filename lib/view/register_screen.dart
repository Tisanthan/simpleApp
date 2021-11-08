import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simpleadd/viewmodel/firebase_core.dart';
import 'package:simpleadd/widget/error_message.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({Key? key}) : super(key: key);
  final FirebaseCor cor = new Auth();

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final databaseReference = FirebaseFirestore.instance;

  late User user;

  bool _obsecureText = false;

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _obsecureText = !_obsecureText;
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();

  late String _name, _phone, _password, _email, _errorMessage, userID;

  late bool _isLoading;

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
        userId = await widget.cor.signUp(_email, _password);
        print('Registerd in: $userId');
        await databaseReference.collection("users").doc(userId).set({
          'name': _name,
          'email': _email,
        });
        print('Data recorded successfully');
        Navigator.pushNamed(context, "/upload");
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
          case "ERROR_EMAIL_ALREADY_IN_USE":
            errorMessage = "The email has alredy been registed";
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
      body: Padding(
        padding: const EdgeInsets.only(top: 300.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                    child: TextFormField(
                      onSaved: (value) => _name = value!,
                      maxLines: 1,
                      keyboardType: TextInputType.name,
                      autofocus: false,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).nextFocus(),
                      validator: (val) =>
                          val!.isEmpty ? "Enter your name" : null,
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        labelText: "Name",
                        hintText: "Tisanthan",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
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
                        hintText: "tisanthanp@gmail.com",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                        top: 10.0, left: 10.0, right: 10.0),
                    child: TextFormField(
                      onSaved: (value) => _password = value!,
                      maxLines: 1,
                      autofocus: false,
                      obscureText: _obsecureText,
                      // code to move to next input field
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                      validator: (val) => val!.length < 6
                          ? (val.isEmpty
                              ? 'Password can\'t be empty'
                              : 'Password too short.')
                          : null,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.remove_red_eye,
                            color: _obsecureText ? Colors.blue : Colors.grey,
                          ),
                          onPressed: () {
                            setState(
                                () => this._obsecureText = !this._obsecureText);
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
                color: Color.fromRGBO(0, 172, 191, 1.0),
                onPressed: () => validateAndSubmit(),
                child: SizedBox(
                  height: 30,
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            "Regiter",
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
