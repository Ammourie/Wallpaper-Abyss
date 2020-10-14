import 'dart:io';
import 'package:flutter_tags/flutter_tags.dart';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fuck/pages/home.dart';
import 'package:fuck/pages/image_future.dart';
import 'package:sqflite/sqflite.dart';
import '../models/image_info.dart' as pi;
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:path_provider/path_provider.dart' as pp;

class ImageDetails extends StatelessWidget {
  final String imageId;

  const ImageDetails({Key key, this.imageId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Details"),
        backgroundColor: Color(0xEFFF0239),
        centerTitle: true,
      ),
      body: Container(
          child: FutureBuilder<pi.Image_Info>(
        future: ImageFuture(imageId).getData(),
        builder: (context, AsyncSnapshot<pi.Image_Info> snapshot) {
          if (snapshot.hasData) {
            return Container(
              decoration: BoxDecoration(
                color: Color(0xE1FCC4D0),
              ),
              child: Center(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .40,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 25,
                          spreadRadius: 5,
                          color: Colors.black54,
                        ),
                      ],
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(snapshot.data.thumbURL),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Text(
                    (snapshot.data.imageName == "" ||
                            snapshot.data.imageName == null)
                        ? "${imageId + "." + snapshot.data.imgType}"
                        : snapshot.data.imageName,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    child: Tags(
                      itemCount: snapshot.data.tags.length,
                      horizontalScroll: true,
                      spacing: 6,
                      symmetry: false,
                      itemBuilder: (index) {
                        return Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: Color(0x83FF0239),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                          child: FlatButton(
                            child: Text(
                              snapshot.data.tags[index]['name'],
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Home(
                                    tagFlag: true,
                                    tagId: snapshot.data.tags[index]['id'],
                                    tagName: snapshot.data.tags[index]['name'],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  SizedBox(
                    width: 130,
                    child: RaisedButton(
                      color: Color(0x83FF0239),
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(25),
                        ),
                      ),
                      onPressed: () async {
                        if (!(await ph.Permission.storage.isGranted)) {
                          ph.Permission.storage.request();
                        } else {
                          Fluttertoast.showToast(
                            msg: "Downloading",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 3,
                            backgroundColor: Color(0x9AF5ADBC),
                            textColor: Colors.white,
                            fontSize: 14.0,
                          );
                          Directory p = await pp.getExternalStorageDirectory();
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
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.download_outlined,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "${snapshot.data.imgSize.toStringAsFixed(1)} MB",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )),
            );
          }
          return Container(
            decoration: BoxDecoration(
              color: Color(0xE1FCC4D0),
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                  Color(0xE1FF2B59),
                ),
              ),
            ),
          );
        },
      )),
    );
  }
}
