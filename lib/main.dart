import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
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
  // Add two variables to the state class to store the CameraController and
  // the Future.
  CameraController _controller;
  Future<void> _initializeControllerFuture;

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

  @override
  Widget build(BuildContext context) {
    sleep(Duration(milliseconds: 500));
    return Scaffold(
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[Center(
                child:((!_controller.value.isInitialized) ? new Container() : buildCameraView()),
          ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                  child: Row(
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.only(right: 10.0),
                          child: Text('1-0', style: TextStyle(fontSize: 26, color: Colors.red, fontWeight: FontWeight.bold, backgroundColor: Colors.black.withOpacity(0.5))),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 10.0),
                          child: Text('Гоооол!', style: TextStyle(fontSize: 26, color: Colors.red, fontWeight: FontWeight.bold, backgroundColor: Colors.black.withOpacity(0.5))),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 10.0),
                          child: Text('Вперед Спартак!', style: TextStyle(fontSize: 26, color: Colors.red, fontWeight: FontWeight.bold, backgroundColor: Colors.black.withOpacity(0.5))),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 10.0),
                          child: Text('Вперед Зенит!', style: TextStyle(fontSize: 26, color: Colors.lightBlue, fontWeight: FontWeight.bold, backgroundColor: Colors.black.withOpacity(0.5))),
                        ),
                      ]
                  )
              ),
          ],),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),

        onPressed: () async {
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
                builder: (context) => DisplayPictureScreen(imagePath: path),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }

  Widget buildCameraView() {
    return
      Transform.scale(
          scale: 1 / _controller.value.aspectRatio,
          child: Center(
            child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: CameraPreview(_controller)),
          ));
  }
}


// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}
