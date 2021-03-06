import 'dart:ffi';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:simpleadd/constants/constant.dart';
import 'package:simpleadd/view/upload_screen.dart';

class DetailedScreen extends StatefulWidget {
  final String title, description, createBy, url, time, price, docId;

  const DetailedScreen(
      {Key? key,
      required this.title,
      required this.description,
      required this.createBy,
      required this.url,
      required this.time,
      required this.docId,
      required this.price})
      : super(key: key);

  @override
  _DetailedScreenState createState() => _DetailedScreenState();
}

class _DetailedScreenState extends State<DetailedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("detailed"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: 80,
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      // mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          "Title: ",
                          style: TextStyle(fontSize: 20.0, color: primaryColor),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          widget.title,
                          style: const TextStyle(
                              fontSize: 20.0, color: primaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Price:",
                          style: TextStyle(fontSize: 20.0, color: primaryColor),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          widget.price,
                          style: const TextStyle(
                              fontSize: 20.0,
                              color: primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "LKR",
                          style: TextStyle(
                              fontSize: 20.0,
                              color: primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Divider(),
            CachedNetworkImage(imageUrl: widget.url),
            Divider(),
            Container(
              width: double.infinity,
              height: 300,
              child: Card(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text("Description",
                            style:
                                TextStyle(fontSize: 20.0, color: primaryColor)),
                      ],
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(widget.description,
                        style: TextStyle(
                            fontSize: 20.0,
                            color: primaryColor,
                            fontWeight: FontWeight.w300)),
                  ],
                ),
              ),
            ),
            MaterialButton(
                minWidth: 200,
                color: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UploadScreen(
                          addTitle: widget.title,
                          description: widget.description,
                          rurl: widget.url,
                          price: widget.price,
                          docId: widget.docId,
                          edit: true,
                        ),
                      ));
                },
                child: Text("Edit")),
          ],
        ),
      ),
    );
  }
}
