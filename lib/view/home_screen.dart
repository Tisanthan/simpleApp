import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simpleadd/viewmodel/firebase_core.dart';
import 'package:simpleadd/widget/custom_dialog.dart';
import 'package:simpleadd/widget/list_card.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String userId;
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User? user;
  final FirebaseCor core = new Auth();

  initUser() async {
    user = await auth.currentUser;
    setState(() {});
  }

  @override
  void initState() {
    // user = core.getCurrentUser() as User;
    initUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Addverticement"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (user == null) {
            showDialog(
                context: context, builder: (context) => const CustomDialog());
          } else {
            Navigator.pushNamed(context, '/upload');
          }
        },
        label: const Text("Post"),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Container(
            height: 200.0,
            child: CarouselSlider(
              options: CarouselOptions(
                height: 180.0,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
              items: [1, 2, 3, 4, 5].map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(color: Colors.amber),
                        child: Center(
                          child: Text(
                            'text $i',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ));
                  },
                );
              }).toList(),
            ),
          ),
          const ListCard(),
        ],
      )),
    );
  }
}
