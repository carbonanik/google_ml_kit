import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool textScanning = false;

  XFile? imageFile;

  String scannedText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Text Recognition example"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (textScanning) const CircularProgressIndicator(),
                  if (!textScanning && imageFile == null)
                    Container(
                      width: 300,
                      height: 300,
                      color: Colors.grey[300]!,
                    ),
                  if (imageFile != null)
                    if (kIsWeb) Image.network(imageFile!.path)
                    else Image.file(File(imageFile!.path)),
                  photoCollectButtons(),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    scannedText,
                    style: const TextStyle(fontSize: 20),
                  )
                ],
              )),
        ),
      ),
    );
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        print(imageFile?.path);
        setState(() {});
        getRecognizedText(pickedImage);
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
      scannedText = "Error occurred while scanning";
      setState(() {});
    }
  }

  void getRecognizedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);

    final textRecognizer = TextRecognizer();

    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    await textRecognizer.close();
    scannedText = "";
    print("scanning completed");
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        print(line.text);
        scannedText = "$scannedText${line.text}\n";
      }
    }
    textScanning = false;
    setState(() {});
  }

  Row photoCollectButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.only(top: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey,
                shadowColor: Colors.grey[400],
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              onPressed: () {
                getImage(ImageSource.gallery);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.image,
                      size: 30,
                    ),
                    Text(
                      "Gallery",
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    )
                  ],
                ),
              ),
            )),
        Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.only(top: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey,
                shadowColor: Colors.grey[400],
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              onPressed: () {
                getImage(ImageSource.camera);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.camera_alt,
                      size: 30,
                    ),
                    Text(
                      "Camera",
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    )
                  ],
                ),
              ),
            )),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
