import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class ImageLoad extends StatelessWidget {
  var url="";
  var hight;
  var width;
  var shape;

    ImageLoad({
   @required String url,
   @required double hight,
   @required double width,
      shape=BoxShape.circle,}){
      this.url=url;
      this.hight=hight;
      this.width=width;
      this.shape=shape;
    }

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
        url,
        width:width,
        height:hight,
        fit: BoxFit.cover,
        cache: true,
        shape: shape,
        borderRadius: BorderRadius.circular(5.0),
        loadStateChanged: (ExtendedImageState state) {
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              return CircularProgressIndicator();
              break;
            case LoadState.completed:
              return ExtendedRawImage(
                image: state.extendedImageInfo?.image,
                width:width,
                height:hight,
              );
              break;
            case LoadState.failed:
              return GestureDetector(
                child: IconButton(icon:Icon(Icons.replay,color: Colors.black38,), onPressed: null),
                onTap: () {
                  state.reLoadImage();
                },
              );
              break;
          }
        }
    );
  }
}
