import 'dart:io';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String type = '';
  double? confi;
  File? file;
  ImagePicker imagePicker = ImagePicker();
  late final imageProcessing;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tflite();
  }

  void pickImage() async {
    XFile? xFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      file = File(xFile.path);
      setState(() {
        file;
      });
      processImage();
    }
  } //TO PICK IMAGE FROM GALERY

  void tflite() async {
    final modelPath = await _getModel('assets/ml/datathon_model.tflite');
    final options =
        LocalLabelerOptions(modelPath: modelPath, confidenceThreshold: 0.7);
    imageProcessing = ImageLabeler(options: options);
  }

  Future<String> _getModel(String assetPath) async {
    if (io.Platform.isAndroid) {
      return 'flutter_assets/$assetPath'; //path to specify
    }
    final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
    await io.Directory(dirname(path)).create(recursive: true);
    final file = io.File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  void processImage() async {
    InputImage inputImage = InputImage.fromFile(file!);
    final List<ImageLabel> labels =
        await imageProcessing.processImage(inputImage);
    for (ImageLabel label in labels) {
      final String text = label.label;
      final double confidence = label.confidence;
      setState(() {
        type = text;
        confi = confidence;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('DATATHON'),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(15),
                child: file != null
                    ? Image.file(file!)
                    : Icon(
                        Icons.image,
                        size: 200,
                      ),
              ),
            ),
            Center(
              child: Container(
                color: Colors.black26,
                child:
                    TextButton(onPressed: pickImage, child: Text('PICK IMAGE')),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Expanded(
              child: Center(
                child: Container(
                  child: Column(
                    children: [
                      Text('DETECTED BRAIN TUMOR :'),
                      Text(type),
                      SizedBox(height: 30),
                      Text('Confidence'),
                      confi != null
                          ? Text(confi!.toStringAsFixed(4).toString())
                          : Text('')
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
