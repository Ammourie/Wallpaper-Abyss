class ImageInfo {
  var imageName="";
  var thumbURL="";
  var imgURL="";
  var imgSize=0.0;
  var imgType="";
  var category="";
  var imageId="";
  void setFromMap(Map wallpaper){
    this.imageName=wallpaper['name'];
    this.thumbURL=wallpaper['url_thumb'];
    this.imgURL=wallpaper['url_image'];
    this.imageId=wallpaper['id'];
    this.imgSize=double.parse(wallpaper["file_size"])/(1024*1024);
    this.imgType=wallpaper["file_type"];
    this.category=wallpaper["category"];
   

  }
}