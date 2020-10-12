import 'dart:convert';

import 'package:http/http.dart';
import '../models/image_info.dart';

class ImageFuture {
  final String imageid;

  ImageFuture(this.imageid);

  Future<Image_Info> getData() async {
    print(imageid);
    var res = await get(
        "https://wall.alphacoders.com/api2.0/get.php?auth=070d79a759f80d9a9535411f90c13eee&method=wallpaper_info&id=$imageid");
    var parsed = await json.decode(res.body);
    var img = Image_Info();
    img.setFromMap(parsed['wallpaper'], parsed['tags']);
    print(img.tags);

    return img;
  }
}
