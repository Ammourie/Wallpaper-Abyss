import 'dart:io';
import 'package:fuck/mapp.dart';
import 'package:fuck/notifires/settings_notifire.dart';
import 'package:fuck/pages/image.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:path_provider/path_provider.dart' as pp;
import 'package:flutter_downloader/flutter_downloader.dart';

class LandscapeCard extends StatelessWidget {
  final String databasePath;
  final String imgURL;
  final String imgName;
  final String imgDimensions;
  final String img;
  const LandscapeCard({
    Key mykey,
    this.imgURL,
    this.imgName,
    this.imgDimensions,
    this.img,
    this.databasePath,
  }) : super(key: mykey);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageDetails(
              imageId: imgName.substring(0, imgName.indexOf(".")),
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25),
            bottom: Radius.circular(15),
          ),
        ),
        elevation: 5,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 200,
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(imgURL), fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all()),
              // child: Image.asset("assets/testing.png"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    imgDimensions,
                    style: TextStyle(fontSize: 17),
                  ),
                  Text(
                    imgName,
                    style: TextStyle(fontSize: 17),
                  ),
                  IconButton(
                    iconSize: 30,
                    icon: Icon(Icons.file_download),
                    onPressed: () async {
                      return downloadImage(context);
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void downloadImage(BuildContext context) async {
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
      var tmpThumbDir = await pp.getExternalStorageDirectories();
      String thumbTmp = "";
      thumbTmp = tmpThumbDir[0].parent.path + "/cache";
      print(thumbTmp);
      String downloadDir =
          p[0].parent.parent.parent.parent.path + "/Wallpaper Abyss";
      Directory(downloadDir).createSync(recursive: true);
      Directory(thumbTmp).createSync(recursive: true);

      String thumbName = imgName.split(".")[0];
      try {
        var response = await get(imgURL);

        File file = new File(thumbTmp + '/$thumbName');

        file.writeAsBytesSync(response.bodyBytes);

        String taskId = await FlutterDownloader.enqueue(
          url: img,
          savedDir: downloadDir,
          fileName: imgName,
          showNotification: true,
          openFileFromNotification: true,
        );
        ext.add(taskId);
      } catch (e) {
        print(e);
      }
    }
  }
}
