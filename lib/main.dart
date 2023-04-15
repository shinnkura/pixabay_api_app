import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PixabayPage(),
    );
  }
}

class PixabayPage extends StatefulWidget {
  const PixabayPage({super.key});

  @override
  State<PixabayPage> createState() => _PixabayPageState();
}

class _PixabayPageState extends State<PixabayPage> {
  List hits = [];

  Future<void> fetchImages(String text) async {
    Response response = await Dio().get(
        'https://pixabay.com/api/?key=34147694-8671a7a4acc324b144c637be7&q=$text&image_type=photo&per_page=200');
    hits = response.data['hits'];
    setState(() {});
    print(hits);
  }

  @override
  void initState() {
    super.initState();
    fetchImages('花');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextFormField(
            initialValue: '花',
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
            ),
            onFieldSubmitted: (text) {
              fetchImages(text);
            },
          ),
        ),
        body: GridView.builder(
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemCount: hits.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> hit = hits[index];
            return InkWell(
              onTap: () async {
                Response response = await Dio().get(hit['webformatURL'],
                    options: Options(responseType: ResponseType.bytes));

                Directory dir = await getTemporaryDirectory();
                File file = await File('${dir.path}/image.png')
                    .writeAsBytes(response.data);

                Share.shareFiles([file.path]);
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    hit['previewURL'],
                    fit: BoxFit.cover,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                        color: Colors.white,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 14,
                            ),
                            Text('${hit['likes']}'),
                          ],
                        )),
                  ),
                ],
              ),
            );
          },
        ));
  }
}
