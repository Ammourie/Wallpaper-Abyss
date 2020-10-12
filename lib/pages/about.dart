import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xef004d99),
        title: Text("About"),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            Card(
              elevation: 0,
              child: Image(
                image: AssetImage('assets/img.png'),
                width: 200,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Powered By Wallpaper Abyss\nhttps://wall.alphacoders.com",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "This app is created by Mohammed Ammourie\nfor the purpose pf education.\n\nfollow me on twitter @Ammourie99",
              style: TextStyle(fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
