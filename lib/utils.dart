import 'package:flutter/cupertino.dart';

ScrollController createLoadMoreController(Function onLoadMore){
  ScrollController controller = ScrollController();
  controller.addListener(() {
    var maxScroll = controller.position.maxScrollExtent;
    var pixel = controller.position.pixels;
    if (maxScroll == pixel) {
      onLoadMore();
    } else {}
  });
  return controller;
}