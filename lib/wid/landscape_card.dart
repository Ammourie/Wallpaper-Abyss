import 'dart:io';
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
  final String imgSize;
  final String img;
  const LandscapeCard({
    Key mykey,
    this.imgURL,
    this.imgName,
    this.imgSize,
    this.img,
    this.databasePath,
  }) : super(key: mykey);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
          bottom: Radius.circular(15),
        ),
      ),
      elevation: 1,
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
                  imgSize,
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
                    
                    if(! (await ph.Permission.storage.isGranted)){
                    ph.Permission.storage.request();}
                    else {
                      Fluttertoast.showToast(
                      msg: "Downloading",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 3,
                      backgroundColor: Colors.grey,
                      textColor: Colors.white,
                      fontSize: 14.0,
                    );
                    Directory p = await pp.getExternalStorageDirectory();
                    p = p.parent.parent.parent.parent;
                    String dir = p.path + '/Download';
                    // File f = File(p.path + '/Download/' + imgName);
                    // f.createSync(recursive: true);

                    try {
                      await FlutterDownloader.enqueue(
                        url: img,
                        savedDir: dir,
                        fileName: imgName,
                        showNotification: true,
                        openFileFromNotification: true,
                      );
                      sleep(Duration(seconds: 1));
                      var database = await openDatabase(databasePath);
                      await database.transaction((txn) async {
                        await txn.rawInsert(
                            'INSERT INTO Downloads(imageName, imagePath) VALUES(?,?)',
                            [imgName, dir + "/" + imgName]);
                      });
                    } catch (e) {
                      print("fuck");
                      print(e);
                      //   f.delete();
                    }
                    }
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
