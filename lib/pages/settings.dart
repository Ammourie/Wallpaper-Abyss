import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../notifires/settings_notifire.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("settings"),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                onPressed: () {
                  var notifier =
                      Provider.of<SettingsNotifire>(context, listen: false);
                  notifier.toggleTheme();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Toggle Theme",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Consumer<SettingsNotifire>(
                      builder: (ctx, notifre, _) {
                        return notifre.flag
                            ? Icon(
                                Icons.toggle_off,
                                size: 50,
                                color: Colors.red,
                              )
                            : Icon(
                                Icons.toggle_on,
                                size: 50,
                                color: Colors.blue,
                              );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Divider(),
            SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Download Storage:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "Internal Storage",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
