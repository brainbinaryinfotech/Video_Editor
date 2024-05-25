// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
//
// import 'package:learn_demo_video/createvideo.dart';
//
// class MediaSelectionScreen extends StatefulWidget {
//   @override
//   _MediaSelectionScreenState createState() => _MediaSelectionScreenState();
// }
//
// class _MediaSelectionScreenState extends State<MediaSelectionScreen> {
//   final ImagePicker _picker = ImagePicker();
//   List<Map<String, dynamic>> _mediaFiles = [];
//
//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _mediaFiles.add({'type': 'image', 'file': File(pickedFile.path)});
//       });
//     }
//   }
//
//   Future<void> _pickVideo() async {
//     final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _mediaFiles.add({'type': 'video', 'file': File(pickedFile.path)});
//       });
//     }
//   }
//
//   void _navigateToPreview() {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) =>ImageListView(ites: _mediaFiles,)
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Select Media')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: _pickImage,
//               child: Text('Pick Image'),
//             ),
//             ElevatedButton(
//               onPressed: _pickVideo,
//               child: Text('Pick Video'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _navigateToPreview,
//               child: Text('Preview Selected Media'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:learn_demo_video/createvideo.dart';

class GalleryPickerScreen extends StatefulWidget {
  @override
  _GalleryPickerScreenState createState() => _GalleryPickerScreenState();
}

class _GalleryPickerScreenState extends State<GalleryPickerScreen> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> items = [];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        items.add({'type': 'image', 'path': pickedFile.path, 'opacity': 0.0});
      });
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        items.add({'type': 'video', 'path': pickedFile.path, 'opacity': 0.0});
      });
    }
  }

  void _navigateToPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageListView(items: items),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pick Images and Videos')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            ElevatedButton(
              onPressed: _pickVideo,
              child: Text('Pick Video'),
            ),
            ElevatedButton(
              onPressed: _navigateToPreview,
              child: Text('Preview'),
            ),
          ],
        ),
      ),
    );
  }
}
