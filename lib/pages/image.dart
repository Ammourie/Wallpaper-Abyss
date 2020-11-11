import 'dart:io';
import 'package:flutter_tags/flutter_tags.dart';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fuck/notifires/settings_notifire.dart';
import 'package:fuck/pages/home.dart';
import 'package:fuck/pages/image_future.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../mapp.dart';
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
        centerTitle: true,
      ),
      body: Container(
          child: FutureBuilder<pi.Image_Info>(
        future: ImageFuture(imageId).getData(),
        builder: (context, AsyncSnapshot<pi.Image_Info> snapshot) {
          if (snapshot.hasData) {
            return Container(
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
                              color: Theme.of(context).buttonColor,
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
                                      tagName: snapshot.data.tags[index]
                                          ['name'],
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
                      child: Consumer<SettingsNotifire>(
                        builder: (ctx, notifire, _) => RaisedButton(
                          color: Theme.of(context).buttonColor,
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
                                backgroundColor: Theme.of(context).accentColor,
                                textColor: Colors.white,
                                fontSize: 14.0,
                              );
                              var p = await pp.getExternalStorageDirectories();

                              String thumbTmp = "";
                              thumbTmp = p[0].parent.path + "/cache";

                              Directory(thumbTmp).createSync(recursive: true);
                              String downloadDir =
                                  p[0].parent.parent.parent.parent.path +
                                      '/Wallpaper Abyss';
                              Directory(downloadDir)
                                  .createSync(recursive: true);

                              try {
                                var response =
                                    await get(snapshot.data.thumbURL);

                                File file = new File(
                                    thumbTmp + '/${snapshot.data.imageId}');

                                file.writeAsBytesSync(response.bodyBytes);

                                String taskId = await FlutterDownloader.enqueue(
                                  url: snapshot.data.imgURL,
                                  savedDir: downloadDir,
                                  fileName: snapshot.data.imageId +
                                      "." +
                                      snapshot.data.imgType,
                                  showNotification: true,
                                  openFileFromNotification: true,
                                );
                                ext.add(taskId);
                              } catch (e) {
                                print(e);
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
                    ),
                  ])),
            );
          }
          return Container(
            child: Center(
              child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor)),
            ),
          );
        },
      )),
    );
  }
}
