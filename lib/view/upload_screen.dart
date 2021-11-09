import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:simpleadd/constants/constant.dart';

enum AppState {
  free,
  picked,
  cropped,
}

class UploadScreen extends StatefulWidget {
  String? addTitle, description, price, docId, rurl;
  bool edit;
  UploadScreen(
      {Key? key,
      this.rurl,
      this.addTitle,
      this.description,
      this.price,
      this.docId,
      this.edit = false})
      : super(key: key);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  late String _title, _add, _price, _name = "tisu";
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

  final TitleController = TextEditingController();
  final DescController = TextEditingController();
  final PriceController = TextEditingController();

  bool get edit => widget.edit;

  MaterialBanner _showMaterialBanner(BuildContext context) {
    return MaterialBanner(
        content: const Text('Please add the Image and check the form'),
        leading: const Icon(Icons.error),
        padding: const EdgeInsets.all(15),
        backgroundColor: primaryColor,
        contentTextStyle: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.purple),
            ),
          ),
        ]);
  }

  Future<void> handleUploadTask() async {
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('uploads/')
        .child('$_title.png')
        .putFile(_image);
    try {
      // Storage tasks function as a Delegating Future so we can await them.
      firebase_storage.TaskSnapshot snapshot = await task;
      setState(() async {
        _url = await task.snapshot.ref.getDownloadURL();
      });
      // _url = await task.snapshot.ref.getDownloadURL();
      print('Uploaded ${snapshot.bytesTransferred} bytes.');
    } on firebase_core.FirebaseException catch (e) {
      // The final snapshot is also available on the task via `.snapshot`,
      // this can include 2 additional states, `TaskState.error` & `TaskState.canceled`
      print("image exeption${task.snapshot}");

      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
      }
      // ...
    }
  }

  Future<void> addNotice() async {
    // Call the user's CollectionReference to add a new user
    if (edit) {
      return users.doc(widget.docId).set({
        'title': _title, // John Doe
        'add': _add,
        'postedBy': _name,
        'price': _price,
        'time': DateFormat.yMd().add_jm().format(DateTime.now()),
        'createdAt': DateTime.now(),
        'url': (state == AppState.picked) ? _url : widget.rurl,
        'uid': userId,
      }).then((value) {
        print("Notice Updated");
      }).catchError((error) {
        print("Failed to Update notice: $error");
      });
    }
    return users.add({
      'title': _title, // John Doe
      'add': _add,
      'postedBy': _name,
      'price': _price,
      'time': DateFormat.yMd().add_jm().format(DateTime.now()),
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
      print("yessssssssssss");
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
    if (form != null && form.validate() && state == AppState.picked) {
      form.save();
      print('Form Validate : true');
      return true;
    } else {
      ScaffoldMessenger.of(context)
        ..removeCurrentMaterialBanner()
        ..showMaterialBanner(_showMaterialBanner(context));
      print('Form Validate : false');
      return false;
    }
  }

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
        _name = documentSnapshot["name"];
        // print('Document data: ${documentSnapshot.data()}');
      } else {
        print('Document does not exist on the database');
      }
    });
    if (edit) {
      TitleController.text = widget.addTitle!;
      DescController.text = widget.description!;
      PriceController.text = widget.price!;
      print("editable");
    }
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
                  width: 30,
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
                margin: bmargin,
                child: TextFormField(
                  style: const TextStyle(color: primaryColor),
                  onSaved: (value) => _title = value!,
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  controller: TitleController,
                  autofocus: false,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter title" : null,
                  decoration: InputDecoration(
                    // floatingLabelStyle:
                    //     const TextStyle(color: primaryColor),
                    fillColor: lprimaryColor,
                    labelText: "ADD's Title",
                    hintText: "Online Advertisement",
                    hintStyle: const TextStyle(color: primaryColor),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.white, width: 2.0),
                        borderRadius: BorderRadius.circular(30.0)),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: lprimaryColor, width: 2.0),
                        borderRadius: BorderRadius.circular(30.0)),
                    filled: true,
                    // border: OutlineInputBorder(
                    //   borderSide: BorderSide(color: Colors.white),
                    // ),
                  ),
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                child: TextFormField(
                  style: const TextStyle(color: primaryColor),
                  minLines: 5,
                  onSaved: (value) => _add = value!,
                  maxLines: 7,
                  controller: DescController,
                  keyboardType: TextInputType.multiline,
                  autofocus: false,
                  textInputAction: TextInputAction.newline,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  validator: (val) => val!.isEmpty
                      ? "Describes something about your ADD"
                      : null,
                  decoration: InputDecoration(
                    fillColor: lprimaryColor,
                    labelText: "ADD's Descriptions",
                    hintMaxLines: 5,
                    hintStyle: const TextStyle(color: primaryColor),
                    hintText:
                        "FaceBook Page \nTwitter Notify \nDigital Margeting \n#marketing #design",
                    // border: OutlineInputBorder(
                    //   borderSide: BorderSide(),
                    // ),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.white, width: 2.0),
                        borderRadius: BorderRadius.circular(30.0)),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: lprimaryColor, width: 2.0),
                        borderRadius: BorderRadius.circular(30.0)),
                    filled: true,
                  ),
                ),
              ),
              Container(
                margin: bmargin,
                child: TextFormField(
                  style: const TextStyle(color: primaryColor),
                  onSaved: (value) => _price = value!,
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  autofocus: false,
                  controller: PriceController,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  validator: (val) => val!.isEmpty ? "Enter Amount" : null,
                  decoration: InputDecoration(
                    // floatingLabelStyle:
                    //     const TextStyle(color: primaryColor),
                    prefixText: "LKR: ",
                    fillColor: lprimaryColor,
                    labelText: "Price",
                    hintText: "599.00",
                    hintStyle: const TextStyle(color: primaryColor),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.white, width: 2.0),
                        borderRadius: BorderRadius.circular(30.0)),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: lprimaryColor, width: 2.0),
                        borderRadius: BorderRadius.circular(30.0)),
                    filled: true,
                    // border: OutlineInputBorder(
                    //   borderSide: BorderSide(color: Colors.white),
                    // ),
                  ),
                ),
              ),
              Container(
                margin: bmargin,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(30.0),
                  color: lprimaryColor,
                  // border: Border.all(color: Colors.blueAccent),
                ),
                child: Column(
                  children: <Widget>[
                    // const Center(
                    //   child: Text(
                    //     "Import Picture",
                    //     style: TextStyle(
                    //         fontWeight: FontWeight.bold, color: Colors.black),
                    //   ),
                    // ),
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
                                  child: Icon(
                                    Icons.camera,
                                    color: Colors.white,
                                  ),
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
                                  child: Icon(
                                    Icons.mobile_friendly,
                                    color: Colors.white,
                                  ),
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
                margin: const EdgeInsets.all(10.0),
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(20)
                    // border: Border.all(color: Colors.blueAccent),
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
