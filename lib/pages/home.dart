import 'package:flutter/material.dart';
import 'downloads_page.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:sqflite/sqflite.dart';
import '../wid/landscape_card.dart';

class Home extends StatefulWidget {
  final Widget card;

  Home({
    Key key,
    this.card,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String dbPath;
  GlobalKey<ScaffoldState> mykey = GlobalKey();
  List<Map> imgQuery;
  bool flag = false;
  bool flag2 = false;
  final String authKey = "070d79a759f80d9a9535411f90c13eee";
  List<String> imageURL = [];
  String userInput = '';
  List<String> imageForDownload = [];
  String searchURL =
      "https://wall.alphacoders.com/api2.0/get.php?auth=070d79a759f80d9a9535411f90c13eee&method=random&page=";
  List<String> imageName = [];
  List<String> imageSize = [];
  int imageRandomPage = 1;
  int imageSearchPage = 1;

  void fetch() async {
    setState(() {
      flag = true;
    });
    // print(imageURL);
  
    try {
      var res;
      print(flag2);
      if (flag2 == false) {
        print(searchURL + imageRandomPage.toString());
        res = await get(searchURL + imageRandomPage.toString());
      } else {
        print(searchURL + imageSearchPage.toString());
        res = await get(searchURL + imageSearchPage.toString());
      }
      var parsed = json.decode(res.body);
      print(parsed);
      // print(parsed);
      for (var i in parsed['wallpapers']) {
        imageURL.add(i['url_thumb']);
        imageSize.add(i['width'].toString() + "x" + i['height'].toString());
        imageName.add(i['id'].toString() + "." + i['file_type'].toString());
        imageForDownload.add(i['url_image']);
      }
  
    } catch (e) {
      print(e);
    }
    setState(() {
      flag = false;
    });
  }

  @override
  void initState() {
    () async {
      var databasesPath = await getDatabasesPath();
      dbPath = databasesPath + "/test.db";
      // await deleteDatabase(dbPath);
      await openDatabase(dbPath, version: 1,
          onCreate: (Database db, int version) async {
        // When creating the db, create the table
        await db.execute(
            'CREATE TABLE Downloads (imageName TEXT PRIMARY KEY, imagePath TEXT)');
      });
    }();
    fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: mykey,
      drawer: buildDrawer(context),
      body: SafeArea(
        child: Column(
          children: [
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(color: Color(0xef004d99)),
                  padding: EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          children: [
                            IconButton(
                                icon: Icon(
                                  Icons.view_headline,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  mykey.currentState.openDrawer();
                                }),
                            Expanded(
                              child: Center(
                                child: AppTitle(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 60,
                        padding: const EdgeInsets.all(5.0),
                        child: TextField(
                          onSubmitted: (String value) {
                            setState(() {
                              flag2 = true;
                              imageForDownload.clear();
                              imageURL.clear();
                              imageName.clear();
                              imageSize.clear();
                              userInput = '';
                              imageSearchPage = 1;
                              userInput = value.replaceAll(" ", "+");
                              searchURL =
                                  "https://wall.alphacoders.com/api2.0/get.php?auth=070d79a759f80d9a9535411f90c13eee&method=search&term=" +
                                      userInput +
                                      "&page=";
                              print(searchURL);

                              // sleep(Duration(seconds: 2));
                              fetch();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "search",
                            prefixIcon: Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      )
                    ],
                  ),
                )
              ],
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Color(0x8066b3ff)),
                child: (flag == true && imageURL.length == 0)
                    ? Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : ListView.builder(
                        // itemExtent: 250.0,
                        itemCount: imageURL.length + 1,
                        itemBuilder: (context, index) {
                          return index == imageURL.length
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    flag == true
                                        ? Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : FlatButton(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                            ),
                                            color: Color(0xef004d99),
                                            child: Padding(
                                              padding: EdgeInsets.all(10.0),
                                              child: Text(
                                                "click to load more",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            onPressed: () {
                                              if (flag2 == false) {
                                                setState(() {
                                                  imageRandomPage =
                                                      imageRandomPage + 1;
                                                });
                                                // print("random");
                                                fetch();
                                              } else {
                                                setState(() {
                                                  imageSearchPage =
                                                      imageSearchPage + 1;
                                                });
                                                fetch();
                                                // print("search" +
                                                //     imgSearchPage.toString());
                                              }
                                            },
                                          ),
                                  ],
                                )
                              : Container(
                                  padding: EdgeInsets.all(5.0),
                                  child: LandscapeCard(
                                      imgURL: imageURL[index],
                                      imgDimensions: imageSize[index],
                                      imgName: imageName[index],
                                      img: imageForDownload[index],
                                      databasePath: dbPath),
                                );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xef004d99),
              ),
              child: ListTile(
                title: AppTitle(),
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    mykey.currentState.openEndDrawer();
                  },
                ),
              ),
            ),
            ListTile(
              onTap: () async {
                Database database = await openDatabase(dbPath);
                imgQuery = await database.rawQuery('SELECT * FROM Downloads');
                Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DownloadsPage(imgQuery, dbPath)),
                ).then((value) {
                  print(value);
                  // value.sort();

                  // for (int i = x.length - 1; i >= 0; i--) {
                  //   print(i);
                  //   x.removeAt(i);
                  // }
                  // print(x);
                });
              },
              title: Text(
                "Downloads",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              leading: Icon(
                Icons.file_download,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppTitle extends StatelessWidget {
  const AppTitle({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      "Wallpaper Abyss",
      style: TextStyle(
          fontSize: 25, fontWeight: FontWeight.w400, color: Colors.white),
    );
  }
}
