import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';


class DraggableItem extends StatefulWidget{

  String text;
  Color color;
  TextData td;
  Function(TextData) callback;

  DraggableItem({Key key, this.text, this.color, this.callback}) : super(key: key);

  @override
  DraggableItemState createState() => DraggableItemState(this.text, this.color);

}


class DraggableItemState extends State<DraggableItem> {

  Offset offset = Offset.zero;

  String text;
  Color color;

  DraggableItemState(String text, Color color){
    this.text = text;
    this.color = color;
  }

  getOffset(){
    return {'x': offset.dy, 'y': offset.dy};
  }

  @override
  Widget build(BuildContext context) {
    var w = Positioned(
        left: offset.dx,
        top: offset.dy,
        child: GestureDetector(
          onPanEnd: (details){
            refresh();
          },
          onPanUpdate: (details){
            setState((){
              offset = Offset(
                  offset.dx + details.delta.dx, offset.dy + details.delta.dy
              );
            });
          },
          child: Container(
            child: Text(this.text, style: TextStyle(fontSize: 26, color: this.color, fontWeight: FontWeight.bold)),
          ),
        ),
      );
    return w;
  }

  void refresh(){
    widget.callback(TextData(this.text, this.offset, this.color));
  }

  @override
  void initState() {
    callbackOnStartup().then((value){
      widget.callback(TextData(this.text, this.offset, this.color));
    });
    super.initState();
  }

  Future callbackOnStartup() async {
    await Future.delayed(Duration(milliseconds: 500));
  }

  @override
  void deactivate() {
    refresh();
    super.deactivate();
  }
}

class TextData{
  String text;
  Offset offset;
  Color color;

  TextData(this.text, this.offset, this.color);
}

class Data{
  List<TextData> textItems;

  Data(){
    textItems = List<TextData>();
  }

  void addItem(String text, Offset offset, Color color){
    textItems.add(TextData(text, offset, color));
  }
}

