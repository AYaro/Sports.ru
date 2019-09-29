import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:sports/drag.dart';
import 'package:image/image.dart' as CustomImage;
import 'package:http/http.dart';

Future<void> main() async {
  final cameras = await availableCameras();

  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        camera: firstCamera,
      ),
    ),
  );
}

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  File _imageFile;

  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

  var req;
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  List<Widget> items = [];

  Data data = new Data();

  callback(textData) {
    setState(() {
      bool found = false;
      if (data.textItems != null) {
        for (TextData textItem in data.textItems) {
          if (textItem.text == textData.text &&
              textItem.color == textData.color) {
            textItem.offset = textData.offset;
            found = true;
            print("FOUND: " + textItem.offset.dx.toString());
          }
        }
      }
      if (!found) {
        print("NOT FOUND");
        data.addItem(textData.text, textData.offset, textData.color);
      }
    });
  }

  Future<String> getText() async {
    String json;
    try {
      var response = await get(
          'https://us-central1-vk-hack-sports-psj.cloudfunctions.net/mygetTexts');
      json = response.body;
    } catch (e) {
      print(e);
    }
    return json;
  }

  @override
  void initState() {
    super.initState();
    // To display the current output from the camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Future<List<InkWell>> texts() async {
    List<InkWell> ret;
    print("-------");
    await getText().then((value) {
      this.req = value;
      print(value);
    }).catchError((error) {
      print(error);
    });
    for (var text in this.req) {
      ret.add(InkWell(
          onTap: () =>
              setState(() {
                this.items.add(DraggableItem(
                    text: "1-0", color: Color(0xFF0000FF), callback: callback));
              }),
          child: Container(
            margin: const EdgeInsets.all(10.0),
            child: Text('1-0',
                style: TextStyle(
                    fontSize: 26,
                    color: Color(0xFF0000FF),
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.black.withOpacity(0.5))),
          )));
      print(text.toString());
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    sleep(Duration(milliseconds: 1500));
    return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Screenshot(
                controller: screenshotController,
                child:
                Stack(
                    children: <Widget>[
                  ((!_controller.value.isInitialized)
                      ? new Container(
                    color: Color(0xFF9933FF),
                    height:MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,

                  )
                      : Transform.scale(
                      scale: 1 / _controller.value.aspectRatio,
                      child: Center(
                        child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: CameraPreview(_controller)),
                      ))),
                  if (this.items.length > 0) for (var item in this.items) item,
                ])),
            Container(
                height: 40,
                child: FutureBuilder(
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.none &&
                        snapshot.hasData == null) {
                      return Container();
                    }
                    if (snapshot.connectionState == ConnectionState.done) {
                      var js = jsonDecode(snapshot.data);
                      int count = 0;
                      for (var elem in js) {
                        count++;
                      };
                      return ListView.builder(
                        itemCount: count,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return InkWell(
                              onTap: () =>
                                  setState(() {
                                    this.items.add(DraggableItem(
                                        text: js[index]['name'].toString(),
                                        color: Color(js[index]['color']),
                                        callback: callback));
                                  }),
                              child: Container(
                                height: 30,
                                margin: const EdgeInsets.all(5.0),
                                child: Text(js[index]['name'].toString(),
                                    style: TextStyle(
                                        fontSize: 26,
                                        color: Color(js[index]['color']),
                                        fontWeight: FontWeight.bold,
                                        backgroundColor:
                                        Colors.black.withOpacity(0.2))),
                              ));
                        },
                      );
                    }
                    return Container();
                  },
                  future: getText(),
                )),
            Center(
                child: Container(
                  color: Color(0xCC000000),
                  height: 72,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                )),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
            backgroundColor: Color(0xFFFFFFFF),
            child: Icon(Icons.camera),
            onPressed:(){ _imageFile = null;
            screenshotController.capture()
            .then((File image) async {
          setState(() {
            _imageFile = image;
          });
          imgShare(image.readAsBytesSync());
            });
            },

      /*() async {
          try {
            await _initializeControllerFuture;
            final path = join(
              // Store the picture in the temp directory.
              // Find the temp directory using the `path_provider` plugin.
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );

            // Attempt to take a picture and log where it's been saved.
            await _controller.takePicture(path);

            // If the picture was taken, display it on a new screen.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  imagePath: path,
                  data: this.data,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },*/
    ));
  }

  Widget buildCameraView() {
    return Transform.scale(
        scale: 1 / _controller.value.aspectRatio,
        child: Center(
          child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: CameraPreview(_controller)),
        ));
  }

  void imgShare(List<int> imageBytes) {
    _shareImage(imageBytes);
  }

  _shareImage(List<int> imageBytes) async {
    try {
      await Share.file(
          "sports.ru story", "story", imageBytes, 'image/png');
    } catch (e) {
      print('Share error: $e');
    }
  }


}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  String imagePath;
  Data data = new Data();

  DisplayPictureScreen({Key key, this.imagePath, this.data}) : super(key: key);

  CustomImage.Image customImage;

  List<int> imageBytes;

  @override
  Widget build(BuildContext context) {
    if (this.data.textItems != null) {
      for (var dt in this.data.textItems) {
        print(dt.text);
      }
    }
    this.customImage =
        CustomImage.decodeJpg(File(this.imagePath).readAsBytesSync());
    for (int i = 0; i < this.data.textItems.length; i++) {
      print("i= " + i.toString());
      CustomImage.drawString(
          this.customImage,
          CustomImage.arial_24,
          this.data.textItems[i].offset.dx.round(),
          this.data.textItems[i].offset.dy.round(),
          this.data.textItems[i].text,
          color: this.data.textItems[i].color.value);
    }

    File(this.imagePath)
        .writeAsBytesSync(CustomImage.encodeJpg(this.customImage));

    this.imageBytes = File(this.imagePath).readAsBytesSync();

    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
      /*floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.share),
        backgroundColor: Color(0xFFAAAAAA),
        onPressed: imgShare(th),
      ),*/
    );
  }

  void imgShare(List<int> imageBytes) {
    _shareImage(imageBytes);
  }


  _shareImage(List<int> imageBytes) async {
    try {
      await Share.file(
          "sports.ru story", "story", imageBytes, 'image/png');
    } catch (e) {
      print('Share error: $e');
    }
  }
}
