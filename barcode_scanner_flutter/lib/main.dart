import 'dart:convert';
import 'dart:io';

import 'package:barcode_scanner_flutter/painter/barcode_detector_painter.dart';
import 'package:barcode_scanner_flutter/selected_choice.dart';
import 'package:barcode_scanner_flutter/utils.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';

import 'barcode_scanner_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? _image;
  String? _path;
  ImagePicker? _imagePicker;

  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
  }

  List<Choice> choices = <Choice>[
    const Choice(title: 'From Assets', icon: Icons.image),
    const Choice(title: 'From Gallery', icon: Icons.image_outlined),
    const Choice(title: 'From Camera', icon: Icons.camera),
    const Choice(title: 'Scan Barcode', icon: Icons.document_scanner_outlined),
    // const Choice(title: 'Camera', icon: Icons.camera_alt),
    // const Choice(title: 'Setting', icon: Icons.settings),
    // const Choice(title: 'Album', icon: Icons.photo_album),
    // const Choice(title: 'WiFi', icon: Icons.wifi),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bar Code Scanner App'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _image != null
                      ? SizedBox(
                          height: 400,
                          width: 400,
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              Image.file(_image!),
                            ],
                          ),
                        )
                  :Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        height: 250,
                        width: 250,
                        child: Image.asset('assets/images/1.png')),
                  ),
                      // : const Icon(
                      //     Icons.image,
                      //     size: 300,
                      //     color: Colors.blue,
                      //   ),
                  if (_image != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('${_path == null ? '' : 'Image path: $_path'}\n\n${_text ?? ''}'),
                    ),
                  GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 8.0,
                      shrinkWrap: true,
                      children: List.generate(4, (index) {
                        return Center(
                            child: GestureDetector(
                          onTap: () {
                            if (choices[index].title == 'From Assets') {
                              _getImageAsset();
                            } else if (choices[index].title == 'From Gallery') {
                              _getImage(ImageSource.gallery);
                            } else if (choices[index].title == 'From Camera') {
                              _getImage(ImageSource.camera);
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const BarcodeScannerView()));
                            }
                          },
                          child: Card(
                              color: Colors.orange,
                              child: Center(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                                  Expanded(child: Icon(choices[index].icon, size: 50.0, color: Colors.black)),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 20.0),
                                    child: Text(
                                      choices[index].title!,
                                    ),
                                  ),
                                ]),
                              )),
                        ));
                      })),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _getImage(ImageSource source) async {
    // setState(() {
    //   _image = null;
    //   _path = null;
    // });
    final pickedFile = await _imagePicker?.pickImage(source: source);
    if (pickedFile != null) {
      print('object not null');
      _processFile(pickedFile.path);
    }else{
      print('object is null');
    }
  }

  Future _getImageAsset() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final assets = manifestMap.keys
        .where((String key) => key.contains('images/'))
        .where((String key) => key.contains('.jpg') || key.contains('.jpeg') || key.contains('.png') || key.contains('.webp'))
        .toList();

    if (mounted) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select image',
                      style: TextStyle(fontSize: 20),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            for (final path in assets)
                              GestureDetector(
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  _processFile(await getAssetPath(path));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(path),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  ],
                ),
              ),
            );
          });
    }
  }

  Future _processFile(String path) async {
    setState(() {
      _image = File(path);
    });
    _path = path;
    final inputImage = InputImage.fromFilePath(path);
    _processImage(inputImage);
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final barcodes = await _barcodeScanner.processImage(inputImage);
    if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
      final painter = BarcodeDetectorPainter(
        barcodes,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      String text = 'Barcodes found: ${barcodes.length}\n\n';
      for (final barcode in barcodes) {
        text += 'Barcode: ${barcode.rawValue}\n\n';
      }
      _text = text;
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}

class CustomCard extends StatelessWidget {
  final String _label;
  final Widget _viewPage;
  final bool featureCompleted;

  const CustomCard(this._label, this._viewPage, {super.key, this.featureCompleted = true});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        tileColor: Theme.of(context).primaryColor,
        title: Text(
          _label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          if (!featureCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This feature has not been implemented yet')));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => _viewPage));
          }
        },
      ),
    );
  }
}
