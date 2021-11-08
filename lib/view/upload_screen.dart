import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum AppState {
  free,
  picked,
  cropped,
}

class UploadScreen extends StatefulWidget {
  UploadScreen({Key? key}) : super(key: key);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  late String _title, _add, _name = "tisu";
  late String? userId;
  late File _image;
  late String _url;
  // final picker = ImagePicker();
  final ImagePicker picker = ImagePicker();
  late bool _inProcess;
  final _formKey = GlobalKey<FormState>();
  late AppState state;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  //firebase implement
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User? user;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('notices');
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future<void> handleUploadTask() async {
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('uploads/')
        .child('$_title.png')
        .putFile(_image);
    try {
      // Storage tasks function as a Delegating Future so we can await them.
      firebase_storage.TaskSnapshot snapshot = await task;
      _url = await task.snapshot.ref.getDownloadURL();
      print('Uploaded ${snapshot.bytesTransferred} bytes.');
    } on firebase_core.FirebaseException catch (e) {
      // The final snapshot is also available on the task via `.snapshot`,
      // this can include 2 additional states, `TaskState.error` & `TaskState.canceled`
      print(task.snapshot);

      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
      }
      // ...
    }
  }

  Future<void> addNotice() async {
    // Call the user's CollectionReference to add a new user
    return users.add({
      'title': _title, // John Doe
      'add': _add,
      'postedBy': _name,
      'time': "${DateTime.now()}",
      'createdAt': DateTime.now(),
      'url': _url,
      'uid': userId,
    }).then((value) {
      print("Notice Added");
    }).catchError((error) {
      print("Failed to add notice: $error");
    });
  }

  // getImage(ImageSource source) async {
  //   await _pickImage(source);
  // }

  Future<Null> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _inProcess = false;
        state = AppState.picked;
      } else {
        print('No image selected.');
        _inProcess = false;
      }
    });
  }

  uploadNotice() async {
    setState(() {
      _inProcess = true;
    });

    if (user == null) {
      print("user nulled");
      setState(() {
        _inProcess = false;
      });
    } else if (validateAndSave()) {
      await {
        if (_image != null)
          {await handleUploadTask()}
        else
          {
            print("image null"),
            setState(() {
              _inProcess = false;
            })
          }
      };
      await addNotice();
      setState(() {
        _formKey.currentState!.reset();
        state = AppState.free;
        _inProcess = false;
        print("submited");
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      });
    } else {
      setState(() {
        _inProcess = false;
      });
      print("not submied");
    }
    setState(() {
      _inProcess = false;
    });
  }

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

  // String? noticeValidate(String value) {
  //   if (value.length < 50 && state == AppState.free) {
  //     if (value.isEmpty && state == AppState.free) {
  //       return "Description shuld be either filled or import Phot";
  //     } else {
  //       return "Notice contains above 50 charecter or import notice";
  //     }
  //   } else if (value.length < 50 || value.isEmpty && state == AppState.picked) {
  //     if (value.isEmpty && state == AppState.picked) {
  //       return "Please crop the imported Notice or fill the notice";
  //     } else if (state == AppState.picked) {
  //       return "Crop the impoterd notice or continue writting";
  //     } else {
  //       return null;
  //     }
  //   } else {
  //     return null;
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _url =
        "https://firebasestorage.googleapis.com/v0/b/vadamar-343ee.appspot.com/o/uploads%2FnoNotice.png?alt=media&token=a89461cb-1dab-4bc5-889f-9bd37dd3146c";
    _inProcess = false;
    state = AppState.free;
    initUser();
  }

  initUser() async {
    user = await auth.currentUser;
    userId = user!.uid;
    print(userId);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        // _name = documentSnapshot.data()!["name"];
        print('Document data: ${documentSnapshot.data()}');
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload"),
      ),
      bottomNavigationBar: BottomAppBar(
        child: MaterialButton(
          elevation: 5.0,
          colorBrightness: Brightness.dark,
          splashColor: Colors.greenAccent,
          minWidth: MediaQuery.of(context).size.width,
          height: 50.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          color: Color.fromRGBO(0, 172, 191, 1.0),
          onPressed: () => uploadNotice(),
          child: _inProcess
              ? const SizedBox(
                  height: 30,
                  width: 100,
                  child: CircularProgressIndicator(),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const <Widget>[
                    Text(
                      "Upload ADD",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    Icon(Icons.upload_sharp),
                  ],
                ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                child: TextFormField(
                  minLines: 1,
                  maxLines: 3,
                  onSaved: (newValue) => _title = newValue!,
                  keyboardType: TextInputType.multiline,
                  validator: (value) =>
                      value!.isEmpty ? "Please enter title" : null,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Title',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                child: TextFormField(
                  minLines: 5,
                  maxLines: 50,
                  onChanged: (newValue) => _add = newValue,
                  keyboardType: TextInputType.multiline,
                  validator: (value) =>
                      value!.isEmpty ? "please enter description" : null,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Write Description content or take a photo',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: Column(
                  children: <Widget>[
                    const Center(
                      child: Text(
                        "Import Picture",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.only(
                              top: 10.0, left: 10.0, right: 10.0, bottom: 20),
                          child: MaterialButton(
                            elevation: 5.0,
                            colorBrightness: Brightness.light,
                            splashColor: Colors.greenAccent,
                            height: 50.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            color: Color.fromRGBO(0, 172, 191, 1.0),
                            onPressed: () => _pickImage(ImageSource.camera),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const <Widget>[
                                Text(
                                  "Camera",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                                Divider(
                                  thickness: 2.0,
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Icon(Icons.camera),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                              top: 10.0, left: 10.0, right: 10.0, bottom: 20),
                          child: MaterialButton(
                            elevation: 5.0,
                            colorBrightness: Brightness.light,
                            splashColor: Colors.greenAccent,
                            height: 50.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            color: const Color.fromRGBO(0, 172, 191, 1.0),
                            onPressed: () => _pickImage(ImageSource.gallery),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const <Widget>[
                                Text(
                                  "Device",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Icon(Icons.phone),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: state == AppState.picked
                    ? Image.file(_image)
                    : const Center(
                        child: Text("No Notice imported"),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
