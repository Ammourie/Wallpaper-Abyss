import 'package:flutter/material.dart';
import 'package:fuck/pages/settings.dart';
import 'downloads_page.dart';
import 'dart:convert';
import 'about.dart';
import 'package:http/http.dart';
import 'package:sqflite/sqflite.dart';
import '../wid/landscape_card.dart';

// ignore: must_be_immutable
class Home extends StatefulWidget {
  bool tagFlag;
  final String tagId;
  final String tagName;
  Home({
    Key key,
    this.tagFlag,
    this.tagId,
    this.tagName,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var textController = new TextEditingController();

  String dbPath;
  GlobalKey<ScaffoldState> mykey = GlobalKey();
  List<Map> imgQuery;
  bool searchFlag = false;
  bool randomFlag = false;
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
  int imageTagPage = 1;

  void fetch() async {
    setState(() {
      searchFlag = true;
    });
    searchURL = widget.tagFlag == true
        ? "https://wall.alphacoders.com/api2.0/get.php?auth=070d79a759f80d9a9535411f90c13eee&method=tag&id=${widget.tagId}&page=$imageTagPage"
        : searchURL;
    try {
      var res;
      print(randomFlag);
      if (widget.tagFlag == true) {
        res = await get(searchURL);
      } else {
        if (randomFlag == false) {
          print(searchURL + imageRandomPage.toString());
          res = await get(searchURL + imageRandomPage.toString());
        } else {
          print(searchURL + imageSearchPage.toString());
          res = await get(searchURL + imageSearchPage.toString());
        }
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
      searchFlag = false;
    });
  }

  @override
  void initState() {
    () async {
      setState(() {
        textController.text =
            widget.tagFlag == true ? widget.tagName.toString() : "";
      });
      var databasesPath = await getDatabasesPath();
      dbPath = databasesPath + "/test.db";
      // await deleteDatabase(dbPath);
      await openDatabase(dbPath, version: 1,
          onCreate: (Database db, int version) async {
        // When creating the db, create the table
        await db.execute(
            'CREATE TABLE Downloads (imageName TEXT PRIMARY KEY, imagePath TEXT,thumbnailPath TEXT)');
      });
    }();
    fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      backgroundColor: Theme.of(context).canvasColor,
      key: mykey,
      drawer: buildDrawer(context),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.elliptical(80, 20),
                        bottomLeft: Radius.elliptical(80, 20),
                      ),
                    ),
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
                            controller: textController,
                            onSubmitted: (String value) {
                              setState(() {
                                randomFlag = true;
                                imageForDownload.clear();
                                imageURL.clear();
                                imageName.clear();
                                imageSize.clear();
                                imageSearchPage = 1;
                                widget.tagFlag = false;
                                textController.text = value;
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
                              contentPadding: EdgeInsets.all(10),
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
                  child: (searchFlag == true && imageURL.length == 0)
                      ? Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor)),
                          ),
                        )
                      : ListView.builder(
                          // itemExtent: 250.0,
                          itemCount: imageURL.length + 1,
                          itemBuilder: (context, index) {
                            return index == imageURL.length
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      searchFlag == true
                                          ? Center(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    new AlwaysStoppedAnimation<
                                                            Color>(
                                                        Theme.of(context)
                                                            .primaryColor),
                                              ),
                                            )
                                          : FlatButton(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
                                              ),
                                              color:
                                                  Theme.of(context).buttonColor,
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
                                                if (widget.tagFlag == true) {
                                                  setState(() {
                                                    imageTagPage =
                                                        imageTagPage + 1;
                                                  });
                                                  fetch();
                                                } else {
                                                  if (randomFlag == false) {
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
      ),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Wallpaper Abyss"),
        ),
        body: Container(
          child: Column(
            children: [
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
                  Icons.download_outlined,
                  size: 35,
                ),
              ),
              ListTile(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsPage(),
                    )),
                title: Text(
                  "settings",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                leading: Icon(
                  Icons.settings,
                  size: 36,
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutPage(),
                    ),
                  );
                },
                title: Text(
                  "about",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                leading: Icon(
                  Icons.info_outline,
                  size: 36,
                ),
              ),
            ],
          ),
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
