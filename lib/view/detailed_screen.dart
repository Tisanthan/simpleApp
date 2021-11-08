import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DetailedScreen extends StatefulWidget {
  final String title, description, createBy, url, time;

  const DetailedScreen(
      {Key? key,
      required this.title,
      required this.description,
      required this.createBy,
      required this.url,
      required this.time})
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
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("title"),
                SizedBox(
                  width: 10,
                ),
                Text(widget.title),
              ],
            ),
            Divider(),
            Column(
              children: [
                Text("Description"),
                SizedBox(
                  width: 10,
                ),
                Text(widget.description),
              ],
            ),
            Divider(),
            CachedNetworkImage(imageUrl: widget.url)
          ],
        ),
      ),
    );
  }
}
