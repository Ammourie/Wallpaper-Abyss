import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:sqflite/sqflite.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class DownloadsPage extends StatelessWidget {
  final List<Map> downloadedImages;
  final String databasePath;
  DownloadsPage(this.downloadedImages, this.databasePath);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, true);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Downloads"),
          centerTitle: true,
        ),
        body: Container(
          child: downloadedImages.length == 0
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "there is no downloads !!!",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: downloadedImages.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(index.toString()),
                      onDismissed: (direction) async {
                        File f = File(
                            "/storage/" + downloadedImages[index]["imagePath"]);

                        f.delete();
                        var tmpDir = (await pp.getTemporaryDirectory()).path;
                        new Directory(tmpDir).delete(recursive: true);

                        Database db = await openDatabase(databasePath);
                        await db.rawDelete(
                            "DELETE FROM Downloads WHERE imageName = ?", [
                          downloadedImages[downloadedImages.length - 1 - index]
                              ["imageName"]
                        ]);
                        db.close();
                      },
                      background: Container(
                        child: Center(
                            child: Text(
                          "Delete",
                          style: TextStyle(fontSize: 30, color: Colors.white),
                        )),
                        color: Colors.red,
                      ),
                      child: GestureDetector(
                        onLongPress: () {
                          print("long fuck");
                        },
                        onTap: () {
                          OpenFile.open("/storage/" +
                              downloadedImages[downloadedImages.length -
                                  1 -
                                  index]["imagePath"]);
                        },
                        child: ListTile(
                          title: Text(downloadedImages[downloadedImages.length -
                              1 -
                              index]["imageName"]),
                          leading: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                              fit: BoxFit.cover,
                              image: FileImage(
                                File(
                                  downloadedImages[downloadedImages.length -
                                      1 -
                                      index]["thumbnailPath"],
                                ),
                              ),
                            )),
                          ),
                          subtitle: Text(downloadedImages[
                                  downloadedImages.length - 1 - index]
                              ["imagePath"]),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
