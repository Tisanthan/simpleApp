import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simpleadd/constants/constant.dart';
import 'package:simpleadd/viewmodel/firebase_core.dart';
import 'package:simpleadd/widget/custom_dialog.dart';
import 'package:simpleadd/widget/list_card.dart';
import 'package:simpleadd/widget/my_sliver_app.dart';

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
    return SafeArea(
      child: Scaffold(
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
        body: Container(
          // color: TisuColors.TisuPrimaryColor,
          color: TisuBackWhire,
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: const SliverAppBar(
                    pinned: false,
                    floating: true,
                    snap: true,
                    expandedHeight: 50,
                    title: Text("Simple Adverticement"),
                    backgroundColor: primaryColor,
                  ),
                ),
                SliverPersistentHeader(
                  floating: false,
                  delegate: MySliverAppBar(
                    expandedHeight: 200,
                  ),
                  pinned: false,
                ),
              ];
            },
            body: ListCard(),
          ),
        ),
        // const ListCard(),
        //     SingleChildScrollView(
        //         child: Column(
        //   children: [
        //     Container(
        //       height: 200.0,
        //       child: CarouselSlider(
        //         options: CarouselOptions(
        //           height: 180.0,
        //           autoPlay: true,
        //           enlargeCenterPage: true,
        //         ),
        //         items: [1, 2, 3, 4, 5].map((i) {
        //           return Builder(
        //             builder: (BuildContext context) {
        //               return Container(
        //                   width: MediaQuery.of(context).size.width,
        //                   margin: EdgeInsets.symmetric(horizontal: 5.0),
        //                   decoration: BoxDecoration(color: Colors.amber),
        //                   child: Center(
        //                     child: Text(
        //                       'text $i',
        //                       style: TextStyle(fontSize: 16.0),
        //                     ),
        //                   ));
        //             },
        //           );
        //         }).toList(),
        //       ),
        //     ),
        //     const ListCard(),
        //   ],
        // )),
      ),
    );
  }
}

// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:simpleadd/view/detailed_screen.dart';
// import 'package:simpleadd/viewmodel/firebase_core.dart';
// import 'package:simpleadd/widget/custom_dialog.dart';
// import 'package:simpleadd/widget/list_card.dart';

// class HomeScreen extends StatefulWidget {
//   HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   late String userId;
//   final FirebaseAuth auth = FirebaseAuth.instance;
//   late User? user;
//   final FirebaseCor core = new Auth();

//   initUser() async {
//     user = await auth.currentUser;
//     setState(() {});
//   }

//   @override
//   void initState() {
//     // user = core.getCurrentUser() as User;
//     initUser();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Addverticement"),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           if (user == null) {
//             showDialog(
//                 context: context, builder: (context) => const CustomDialog());
//           } else {
//             Navigator.pushNamed(context, '/upload');
//           }
//         },
//         label: const Text("Post"),
//       ),
//       body: ListCard(),
//     );
//   }
// }

// // StreamBuilder<QuerySnapshot>(
// //             stream: FirebaseFirestore.instance
// //                 .collection('notices')
// //                 .orderBy('createdAt', descending: true)
// //                 .limit(5)
// //                 .snapshots(includeMetadataChanges: true),
// //             builder:
// //                 (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
// //               if (snapshot.hasError) {
// //                 return const Center(child: Text("error"));
// //               }

// //               if (snapshot.connectionState == ConnectionState.waiting) {
// //                 return const Center(
// //                   child: SizedBox(
// //                     width: 40,
// //                     height: 40,
// //                     child: CircularProgressIndicator(),
// //                   ),
// //                 );
// //               }

// //               var style = TextStyle(fontSize: 16.0, color: Colors.white);

// //               return SizedBox(
// //                 height: 200.0,
// //                 child: CarouselSlider(
// //                   options: CarouselOptions(
// //                     height: 180.0,
// //                     autoPlay: true,
// //                     enlargeCenterPage: true,
// //                   ),
// //                   items: snapshot.data!.docs.map(
// //                     (DocumentSnapshot document) {
// //                       return Builder(
// //                         builder: (BuildContext context) {
// //                           return GestureDetector(
// //                             child: Container(
// //                               width: MediaQuery.of(context).size.width,
// //                               margin: EdgeInsets.symmetric(horizontal: 5.0),
// //                               decoration: BoxDecoration(
// //                                 //color: Colors.amber,
// //                                 image: DecorationImage(
// //                                   image: NetworkImage(document['url']),
// //                                   fit: BoxFit.cover,
// //                                 ),
// //                                 borderRadius: BorderRadius.circular(10),
// //                               ),
// //                               clipBehavior: Clip.antiAliasWithSaveLayer,
// //                               child: Container(
// //                                 color: Color(0x80000000),
// //                                 child: Center(
// //                                   child: Column(
// //                                     mainAxisAlignment: MainAxisAlignment.center,
// //                                     mainAxisSize: MainAxisSize.min,
// //                                     children: [
// //                                       Text(
// //                                         document['title'] ?? "",
// //                                         style: style,
// //                                       ),
// //                                       Text(
// //                                         document['time'] ?? "",
// //                                         style: style,
// //                                       ),
// //                                       Text(
// //                                         document['postedBy'] ?? "",
// //                                         style: style,
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                             onTap: () {
// //                               Navigator.push(
// //                                 context,
// //                                 MaterialPageRoute(
// //                                   builder: (context) => DetailedScreen(
// //                                     title: document['title'],
// //                                     description: document['add'],
// //                                     url: document['url'],
// //                                     createBy: document['postedBy'],
// //                                     time: document['time'],
// //                                   ),
// //                                 ),
// //                               );
// //                             },
// //                           );
// //                         },
// //                       );
// //                     },
// //                   ).toList(),
// //                 ),
// //               );
// //             },
// //           ),
// //           const Expanded(child: ListCard()),
