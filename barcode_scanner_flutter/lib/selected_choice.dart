import 'dart:convert';

import 'package:barcode_scanner_flutter/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import 'barcode_scanner_view.dart';

class Choice {
  const Choice({this.title, this.icon});
  final String? title;
  final IconData? icon;
}

const List<Choice> choices = <Choice>[
  Choice(title: 'From Assets', icon: Icons.image),
  Choice(title: 'From Gallery', icon: Icons.image_outlined),
  Choice(title: 'From Camera', icon: Icons.camera),
  Choice(title: 'Scan Barcode', icon: Icons.document_scanner_outlined),
  // const Choice(title: 'Camera', icon: Icons.camera_alt),
  // const Choice(title: 'Setting', icon: Icons.settings),
  // const Choice(title: 'Album', icon: Icons.photo_album),
  // const Choice(title: 'WiFi', icon: Icons.wifi),
];

class SelectCard extends StatefulWidget {
  const SelectCard({Key? key, this.choice}) : super(key: key);
  final Choice? choice;

  @override
  State<SelectCard> createState() => _SelectCardState();
}

class _SelectCardState extends State<SelectCard> {

  @override
  Widget build(BuildContext context) {
   // final TextStyle textStyle = Theme.of(context).textTheme.;
    return GestureDetector(
      onTap: () {
        if (widget.choice!.title == 'From Assets') {
         // _getImageAsset();
          // Navigator.push(context, MaterialPageRoute(builder: (context) => MajorConcern(dataModel: dataModel)));
        } else if(widget.choice!.title == 'From Gallery'){
          // Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPatient()));
        }
        else if(widget.choice!.title == 'From Camera'){
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPatient()));
        }
        else {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const BarcodeScannerView()));
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPatient()));
        }
      },
      child: Card(
          color: Colors.orange,
          child: Center(child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(child: Icon(widget.choice!.icon, size:50.0, color: Colors.black)),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(widget.choice!.title!,),
                ),
              ]
          ),
          )
      ),
    );
  }
  // Future _getImageAsset() async {
  //   final manifestContent = await rootBundle.loadString('AssetManifest.json');
  //   final Map<String, dynamic> manifestMap = json.decode(manifestContent);
  //   final assets = manifestMap.keys
  //       .where((String key) => key.contains('images/'))
  //       .where((String key) =>
  //   key.contains('.jpg') ||
  //       key.contains('.jpeg') ||
  //       key.contains('.png') ||
  //       key.contains('.webp'))
  //       .toList();
  //
  //   if(mounted){
  //     showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return Dialog(
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(30.0)),
  //             child: Padding(
  //               padding: const EdgeInsets.all(16.0),
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   const Text(
  //                     'Select image',
  //                     style: TextStyle(fontSize: 20),
  //                   ),
  //                   ConstrainedBox(
  //                     constraints: BoxConstraints(
  //                         maxHeight: MediaQuery.of(context).size.height * 0.7),
  //                     child: SingleChildScrollView(
  //                       child: Column(
  //                         children: [
  //                           for (final path in assets)
  //                             GestureDetector(
  //                               onTap: () async {
  //                                 Navigator.of(context).pop();
  //                                 _processFile(await getAssetPath(path));
  //                               },
  //                               child: Padding(
  //                                 padding: const EdgeInsets.all(8.0),
  //                                 child: Image.asset(path),
  //                               ),
  //                             ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                   ElevatedButton(
  //                       onPressed: () => Navigator.of(context).pop(),
  //                       child: const Text('Cancel')),
  //                 ],
  //               ),
  //             ),
  //           );
  //         });
  //   }
  //
  // }
  //
  // Future _processFile(String path) async {
  //   setState(() {
  //     _image = File(path);
  //   });
  //   _path = path;
  //   final inputImage = InputImage.fromFilePath(path);
  //   widget.onImage(inputImage);
  // }
}