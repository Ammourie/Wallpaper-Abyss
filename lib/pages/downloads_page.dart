import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
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
          backgroundColor: Color(0xef004d99),
          title: Text("Downloads"),
          centerTitle: true,
        ),
        body: Container(
          color: Color(0x8066b3ff),
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
                        File f = File(downloadedImages[index]["imagePath"]);
                        // Directory tmp =
                        //     await getApplicationDocumentsDirectory();
                        // f.rename(tmp.path);
                        f.delete();
                        var appDir = (await getTemporaryDirectory()).path;
                        new Directory(appDir).delete(recursive: true);
                        // DefaultCacheManager dcm = new DefaultCacheManager();
                        // dcm.emptyCache();
                        Database db = await openDatabase(databasePath);
                        await db.rawDelete(
                            "DELETE FROM Downloads WHERE imageName = ?",
                            [downloadedImages[index]["imageName"]]);
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
                          OpenFile.open(downloadedImages[index]["imagePath"]);
                        },
                        child: ListTile(
                          title: Text(downloadedImages[index]["imageName"]),
                          subtitle: Text(downloadedImages[index]["imagePath"]),
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
