import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';


class DraggableScreen extends StatefulWidget {
  @override
  DraggableScreenState createState() => DraggableScreenState();
}

class DraggableScreenState extends State<DraggableScreen> {
  // Add two variables to the state class to store the CameraController and
  // the Future.


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Column(
            // draggable widgets here
          ),
          Column(
            // droppable widgets here
          )
        ],
      ),
    );
  }
}




class DraggableItem extends StatelessWidget {

  String text;
  Color color;

  DraggableItem(String text, Color color){
    this.text = text;
    this.color = color;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: Text(this.text, style: TextStyle(fontSize: 26, color: this.color, fontWeight: FontWeight.bold, backgroundColor: Colors.black.withOpacity(0.5))),
    );
  }
}