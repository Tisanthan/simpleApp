import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:simpleadd/constants/constant.dart';
import 'package:simpleadd/view/detailed_screen.dart';
import 'package:simpleadd/view/home_screen.dart';

class ListCard extends StatefulWidget {
  const ListCard({Key? key}) : super(key: key);

  @override
  State<ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<ListCard> {
  Future<bool> _delete(String id) async {
    final db = FirebaseFirestore.instance; //initialice
    await db
        .collection("notices")
        .doc(id)
        .delete()
        .catchError((onError) => print("Error on MyNotices $onError"));

    return true;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double heigh = MediaQuery.of(context).size.height;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notices')
          .orderBy('createdAt', descending: true)
          .snapshots(includeMetadataChanges: true),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("error"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            // return ListTile(
            //   title: Text(snapshot.data!.docs[index]["title"]),
            // );
            return Slidable(
              key: const ValueKey(0),
              actionPane: SlidableDrawerActionPane(),
              //actionExtentRatio: 0.25,
              child: Container(
                padding: const EdgeInsets.only(
                  top: 5,
                ),
                // constraints: BoxConstraints(maxHeight: 200),
                child: Card(
                  shadowColor: primaryColor,
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailedScreen(
                            title: snapshot.data!.docs[index]["title"],
                            description: snapshot.data!.docs[index]['add'],
                            url: snapshot.data!.docs[index]['url'],
                            createBy: snapshot.data!.docs[index]['postedBy'],
                            time: snapshot.data!.docs[index]['time'],
                            price: snapshot.data!.docs[index]['price'],
                          ),
                        ),
                      );
                    },
                    splashColor: primaryColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Stack(
                          children: [
                            SizedBox(
                              width: width - 5,
                              height: heigh * 0.2,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(5.0),
                                    topRight: Radius.circular(5.0)),
                                child: CachedNetworkImage(
                                  imageUrl: snapshot.data!.docs[index]['url'],
                                  fit: BoxFit.cover,
                                  // progressIndicatorBuilder:
                                  //     (context, url, downloadProgress) => SizedBox(
                                  //   height: 10.0,
                                  //   width: 60.0,
                                  //   child: LinearProgressIndicator(
                                  //       value: downloadProgress.progress),
                                  // ),
                                  placeholder: (context, url) => const SizedBox(
                                      width: 100,
                                      height: 10,
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      const SizedBox(
                                    child: Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              snapshot.data!.docs[index]['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const Divider(
                          color: Colors.black,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                snapshot.data!.docs[index]['time'],
                                style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[800]),
                              ),
                              // Container(
                              //   width: 100,
                              //   height: 30,
                              //   child: const Icon(Icons.verified),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                IconSlideAction(
                  caption: 'Delete',
                  color: Colors.red,
                  icon: Icons.delete_forever_rounded,
                  onTap: () async {
                    setState(() {
                      _delete(snapshot.data!.docs[index].id);
                    });
                  },
                ),
              ],
              dismissal: SlidableDismissal(
                child: SlidableDrawerDismissal(),
                onDismissed: (actionType) async {
                  setState(() {
                    _delete(snapshot.data!.docs[index].id);
                  });
                },
              ),
            );
          },
        );
      },
    );
  }
}


// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:simpleadd/constants/constant.dart';
// import 'package:simpleadd/view/detailed_screen.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';

// class ListCard extends StatefulWidget {
//   const ListCard({Key? key}) : super(key: key);

//   @override
//   _ListCardState createState() => _ListCardState();
// }

// class _ListCardState extends State<ListCard> {
//   Future<bool> _delete(String id) async {
//     final db = FirebaseFirestore.instance; //initialice
//     await db
//         .collection("notices")
//         .doc(id)
//         .delete()
//         .catchError((onError) => print("Error on MyNotices $onError"));

//     return true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     double heigh = MediaQuery.of(context).size.height;
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('notices')
//           .orderBy('createdAt', descending: true)
//           .snapshots(includeMetadataChanges: true),
//       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.hasError) {
//           return const Center(child: Text("error"));
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: SizedBox(
//               width: 40,
//               height: 40,
//               child: CircularProgressIndicator(),
//             ),
//           );
//         }

//         return ListView(
//           physics: NeverScrollableScrollPhysics(),
//           shrinkWrap: true,
//           children: snapshot.data!.docs.map((DocumentSnapshot document) {
//             return Container(
//               child: Slidable(
//                 key: const ValueKey(0),
//                 actionPane: SlidableDrawerActionPane(),
//                 //actionExtentRatio: 0.25,
//                 child: Container(
//                   padding: const EdgeInsets.only(
//                     top: 5,
//                   ),
//                   // constraints: BoxConstraints(maxHeight: 200),
//                   child: Card(
//                     shadowColor: primaryColor,
//                     color: Colors.white,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(5.0)),
//                     child: InkWell(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => DetailedScreen(
//                               title: document['title'],
//                               description: document['add'],
//                               url: document['url'],
//                               createBy: document['postedBy'],
//                               time: document['time'],
//                             ),
//                           ),
//                         );
//                       },
//                       splashColor: primaryColor,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: <Widget>[
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: Text(
//                                 document['title'],
//                               ),
//                             ),
//                           ),
//                           const Divider(
//                             color: Colors.black,
//                           ),
//                           Padding(
//                             padding:
//                                 const EdgeInsets.symmetric(horizontal: 8.0),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Text(
//                                   document['time'],
//                                   style: TextStyle(
//                                       fontStyle: FontStyle.italic,
//                                       color: Colors.grey[800]),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 actions: <Widget>[
//                   IconSlideAction(
//                     caption: 'Delete',
//                     color: Colors.red,
//                     icon: Icons.delete_forever_rounded,
//                     onTap: () async {
//                       setState(() {
//                         _delete(document.id);
//                       });
//                     },
//                   ),
//                 ],
//                 dismissal: SlidableDismissal(
//                   child: SlidableDrawerDismissal(),
//                   onDismissed: (actionType) async {
//                     setState(() {
//                       _delete(document.id);
//                     });
//                   },
//                 ),
//               ),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }
// }
