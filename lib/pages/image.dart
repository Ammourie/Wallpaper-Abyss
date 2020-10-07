import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fuck/pages/image_future.dart';
import 'package:sqflite/sqflite.dart';
import '../models/image_info.dart' as pi;
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart' as pp;

class ImageDetails extends StatelessWidget {
  final String imageId;

  const ImageDetails({Key key, this.imageId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Details"),
        centerTitle: true,
      ),
      body: Container(
          child: FutureBuilder<pi.ImageInfo>(
        future: ImageFuture(imageId).getData(),
        builder: (context, AsyncSnapshot<pi.ImageInfo> snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * .40,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(snapshot.data.thumbURL),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  snapshot.data.imageName == ""
                      ? "${imageId + "." + snapshot.data.imgType}"
                      : snapshot.data.imageName,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Size: ${snapshot.data.imgSize.toStringAsFixed(3)} MB",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Category: ${snapshot.data.category}",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                        iconSize: 30,
                        icon: Icon(Icons.file_download),
                        onPressed: () async {
                          if (!(await ph.Permission.storage.isGranted)) {
                            ph.Permission.storage.request();
                          } else {
                            Fluttertoast.showToast(
                              msg: "Downloading",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 3,
                              backgroundColor: Colors.grey,
                              textColor: Colors.white,
                              fontSize: 14.0,
                            );
                            Directory p =
                                await pp.getExternalStorageDirectory();
                            p = p.parent.parent.parent.parent;
                            String dir = p.path + '/Download';
                            try {
                              await FlutterDownloader.enqueue(
                                url: snapshot.data.imgURL,
                                savedDir: dir,
                                fileName: snapshot.data.imageId +
                                    "." +
                                    snapshot.data.imgType,
                                showNotification: true,
                                openFileFromNotification: true,
                              );
                              var databasesPath = await getDatabasesPath();
                              var dbPath = databasesPath + "/test.db";
                              sleep(Duration(seconds: 1));
                              var database = await openDatabase(dbPath);
                              await database.transaction((txn) async {
                                await txn.rawInsert(
                                    'INSERT INTO Downloads(imageName, imagePath) VALUES(?,?)',
                                    [
                                      snapshot.data.imageId +
                                          "." +
                                          snapshot.data.imgType,
                                      dir +
                                          "/" +
                                          snapshot.data.imageId +
                                          "." +
                                          snapshot.data.imgType
                                    ]);
                              });
                            } catch (e) {
                              print("fuck");
                              print(e);
                              //   f.delete();
                            }
                          }
                        })
                  ],
                )
              ],
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      )),
    );
  }
}
