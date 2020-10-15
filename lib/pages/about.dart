import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About"),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
          child: Column(
            children: [
              Image(
                image: AssetImage('assets/img.png'),
                width: 200,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Powered By Wallpaper Abyss",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              FlatButton(
                onPressed: () async {
                  const url = 'https://wall.alphacoders.com';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: Text(
                  "https://wall.alphacoders.com",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "This app is created by Mohammed Ammourie\nfor the purpose pf education.\nfollow me on twitter:",
                style: TextStyle(fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ),
              FlatButton(
                onPressed: () async {
                  const url = 'https://twitter.com/Ammourie99';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: Text(
                  "@Ammourie99",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
