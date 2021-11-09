import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simpleadd/constants/constant.dart';
import 'package:simpleadd/view/detailed_screen.dart';

class MySliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  MySliverAppBar({
    required this.expandedHeight,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: (1 - shrinkOffset / expandedHeight),
          child: Container(
            // color: TisuColors.TisuPrimaryColor,
            color: TisuBackWhire,
          ),
        ),
        Column(
          children: [
            Opacity(
              opacity: (1 - shrinkOffset / expandedHeight),
              child: Shimmer.fromColors(
                  child: const Text(
                    "Recent Post",
                    style: TextStyle(
                      fontFamily: 'Cuprum',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  baseColor: TisuBackWhire,
                  highlightColor: Colors.red),
            ),
            Flexible(
              child: Opacity(
                opacity: (1 - shrinkOffset / expandedHeight),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('notices')
                        .orderBy('createdAt', descending: true)
                        .limit(5)
                        .snapshots(includeMetadataChanges: true),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Center(child: Text("error"));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      var style = const TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold);

                      return Container(
                        height: 200.0,
                        child: CarouselSlider(
                          options: CarouselOptions(
                            height: 180.0,
                            autoPlay: true,
                            enlargeCenterPage: true,
                          ),
                          items: snapshot.data!.docs.map(
                            (DocumentSnapshot document) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return GestureDetector(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 5.0),
                                      decoration: BoxDecoration(
                                        //color: Colors.amber,
                                        image: DecorationImage(
                                          image: NetworkImage(document['url']),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      child: Container(
                                        color: Color(0x80000000),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      document['title'],
                                                      style: style,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "PRICE ",
                                                      style: style,
                                                    ),
                                                    Text(
                                                      document['price'],
                                                      style: style,
                                                    ),
                                                    Text(
                                                      "LKR",
                                                      style: style,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Posted By: ",
                                                      style: style,
                                                    ),
                                                    Text(
                                                      document['postedBy'],
                                                      style: style,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      document['time'],
                                                      style: style,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailedScreen(
                                            title: document['title'],
                                            description: document['add'],
                                            url: document['url'],
                                            createBy: document['postedBy'],
                                            time: document['time'],
                                            price: document['price'],
                                            docId: document.id,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
