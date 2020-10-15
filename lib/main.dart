import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/services.dart';
import './notifires/settings_notifire.dart';
import 'package:provider/provider.dart';
import 'pages/home.dart';
import 'package:path_provider/path_provider.dart' as pp;
// import 'package:workmanager/workmanager.dart';

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

class MyApp extends StatelessWidget {
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
}
