import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/services.dart';
import 'package:fuck/mapp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import './notifires/settings_notifire.dart';
import 'package:provider/provider.dart';
import 'pages/home.dart';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterDownloader.initialize(
      debug: false // optional: set false to disable printing logs to console
      );
  Directory tmp = await pp.getExternalStorageDirectory();
  File f = new File("${tmp.path}/.nomedia");
  f.createSync(recursive: true);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    _bindBackgroundIsolate();

    FlutterDownloader.registerCallback(downloadCallback);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Theme.of(context).accentColor,
    // ));
    return ChangeNotifierProvider(
      create: (_) => SettingsNotifire()..init(),
      child: Consumer<SettingsNotifire>(builder: (context, notifier, _) {
        return MaterialApp(
          theme: notifier.flag ? notifier.theme1 : notifier.theme2,
          home: Home(
            tagFlag: false,
          ),
        );
      }),
    );
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) async {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      if (status == DownloadTaskStatus.complete && ext.contains(id)) {
        print("problem");
        var res = await FlutterDownloader.loadTasksWithRawQuery(
            query: "select * from task where task_id='$id'");
        var task = res[0];
        SharedPreferences sp = await SharedPreferences.getInstance();
        bool storageflag = sp.getBool("storageLocation");
        String finalDir;
        var t = await pp.getExternalStorageDirectories();

        String thumbDir = t[0].parent.path + "/.thumbnails";
        if (!storageflag) {
          finalDir = t[0].parent.parent.parent.parent.path + '/Wallpaper Abyss';
        } else {
          finalDir = t[1].path + '/Wallpaper Abyss';
        }
        print(task.savedDir);
        File src = File(task.savedDir + "/${task.filename}");
        src.createSync(recursive: true);
        File des = File(finalDir + "/${task.filename}");
        await des.create(recursive: true);
        var data = await src.readAsBytes();
        await des.writeAsBytes(data);
        await src.delete();
        var databasesPath = await getDatabasesPath();
        String dbPath = databasesPath + "/test.db";
        var database = await openDatabase(dbPath);
        await database.transaction((txn) async {
          await txn.rawInsert(
              'INSERT INTO Downloads(imageName, imagePath,thumbnailPath) VALUES(?,?,?)',
              [
                task.filename,
                finalDir.substring(9) + "/" + task.filename,
                "$thumbDir/${task.filename.split(".")[0]}"
              ]);
        });
        ext.remove(id);

        DefaultCacheManager manager = new DefaultCacheManager();
        manager.emptyCache(); //clears all data in cache.
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }
}
