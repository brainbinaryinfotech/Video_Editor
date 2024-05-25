// // import 'package:flutter/material.dart';
// // import 'package:video_player/video_player.dart';
// //
// // class ImageListView extends StatefulWidget {
// //   @override
// //   _ImageListViewState createState() => _ImageListViewState();
// // }
// //
// // class _ImageListViewState extends State<ImageListView> {
// //   List<Map<String, dynamic>> items = [
// //     {'type': 'image', 'path': 'assets/images/Rectangle 1.png', 'opacity': 0.0},
// //     {'type': 'image', 'path': 'assets/images/image 1 (1).png', 'opacity': 0.0},
// //     {'type': 'video', 'path': 'assets/images/27.04.2024_16.42.45_REC.mp4', 'opacity': 0.0},
// //     {'type': 'image', 'path': 'assets/images/Rectangle 4.png', 'opacity': 0.0},
// //     {'type': 'image', 'path': 'assets/images/Rectangle 3.png', 'opacity': 0.0},
// //   ];
// //
// //   int _currentIndex = 0;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _animateItems();
// //   }
// //
// //   void _animateItems() async {
// //     for (int i = 0; i < items.length; i++) {
// //       await Future.delayed(Duration(seconds: 2));
// //       setState(() {
// //         _currentIndex = i;
// //         items[i]['opacity'] = 1.0;
// //       });
// //       await Future.delayed(Duration(seconds: 1));
// //       if (i < items.length - 1) {
// //         setState(() {
// //           items[i]['opacity'] = 0.0;
// //         });
// //       }
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Animated Media List')),
// //       body: Center(
// //         child: Container(
// //           height: 400,
// //           child: Stack(
// //             children: items.map((item) {
// //               int index = items.indexOf(item);
// //               return AnimatedOpacity(
// //                 opacity: index == _currentIndex ? 1.0 : 0.0,
// //                 duration: Duration(seconds: 3),
// //                 child: _buildItem(item),
// //               );
// //             }).toList(),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildItem(Map<String, dynamic> item) {
// //     if (item['type'] == 'image') {
// //       return Image.asset(item['path']);
// //     } else if (item['type'] == 'video') {
// //       return VideoWidget(videoPath: item['path']);
// //     }
// //     return Container(); // Placeholder if type is not recognized
// //   }
// // }
// //
// // class VideoWidget extends StatelessWidget {
// //   final String videoPath;
// //
// //   VideoWidget({required this.videoPath});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return AspectRatio(
// //       aspectRatio: 16 / 9, // You can adjust aspect ratio as needed
// //       child: VideoPlayerWidget(videoPath: videoPath),
// //     );
// //   }
// // }
// //
// // class VideoPlayerWidget extends StatefulWidget {
// //   final String videoPath;
// //
// //   VideoPlayerWidget({required this.videoPath});
// //
// //   @override
// //   _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
// // }
// //
// // class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
// //   late VideoPlayerController _controller;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _controller = VideoPlayerController.asset(widget.videoPath)
// //       ..initialize().then((_) {
// //         setState(() {});
// //         _controller.play();
// //       });
// //   }
// //
// //   @override
// //   void dispose() {
// //     super.dispose();
// //     _controller.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return _controller.value.isInitialized
// //         ? VideoPlayer(_controller)
// //         : Center(child: CircularProgressIndicator());
// //   }
// }
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ImageListView extends StatefulWidget {
  final List<Map<String, dynamic>> items;

  const ImageListView({super.key, required this.items});
  @override
  _ImageListViewState createState() => _ImageListViewState();
}

class _ImageListViewState extends State<ImageListView> {



  int _currentIndex = 0;

  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _animateItems();
  }

  void _animateItems() async {
    for (int i = 0; i <  widget.items.length; i++) {
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        _currentIndex = i;
        widget.items[i]['opacity'] = 1.0;
      });

      if ( widget.items[i]['type'] == 'video') {
        await _playVideo( widget.items[i]['path']);
      } else {
        await Future.delayed(Duration(seconds: 1));
      }

      if (i <  widget.items.length - 1) {
        setState(() {
          widget.items[i]['opacity'] = 0.0;
        });
      }
    }
  }

  Future<void> _playVideo(String videoPath) async {
    _videoController = VideoPlayerController.asset(videoPath)
      ..initialize().then((_) {
        setState(() {});
        _videoController.play();
      });

    await _videoController.play();
    await Future.delayed(Duration(seconds: _videoController.value.duration.inSeconds));
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Animated Media List')),
      body: Center(
        child: Stack(
          children:  widget.items.map((item) {
            int index =  widget.items.indexOf(item);
            return AnimatedOpacity(
              opacity: index == _currentIndex ? 1.0 : 0.0,
              duration: item['type'] == 'video'?const Duration(seconds: 5):Duration(seconds: 2),
              child: Container(width: double.infinity,height: 400,
                  child: _buildItem(item)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildItem(Map<String, dynamic> item) {
    if (item['type'] == 'image') {
      return Image.file(File(item['path']));
    } else if (item['type'] == 'video') {
      return VideoWidget(videoPath: item['path']);
    }
    return Container(); // Placeholder if type is not recognized
  }
}

class VideoWidget extends StatelessWidget {
  final String videoPath;

  VideoWidget({required this.videoPath});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9, // You can adjust aspect ratio as needed
      child: VideoPlayerWidget(videoPath: videoPath),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;

  VideoPlayerWidget({required this.videoPath});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? VideoPlayer(_controller)
        : Center(child: CircularProgressIndicator());
  }
}



// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:video_player/video_player.dart';
// import 'dart:io';
//
// class ImageListView extends StatefulWidget {
//   @override
//   _ImageListViewState createState() => _ImageListViewState();
// }
//
// class _ImageListViewState extends State<ImageListView> {
//   final ImagePicker _picker = ImagePicker();
//   List<Map<String, dynamic>> items = [];
//   int _currentIndex = 0;
//   VideoPlayerController? _videoController;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _videoController?.dispose();
//     super.dispose();
//   }
//
//   Future<void> _pickMedia(ImageSource source, String type) async {
//     XFile? pickedFile;
//     if (type == 'image') {
//       pickedFile = await _picker.pickImage(source: source);
//     } else if (type == 'video') {
//       pickedFile = await _picker.pickVideo(source: source);
//     }
//
//     if (pickedFile != null) {
//       setState(() {
//         items.add({'type': type, 'path': pickedFile!.path, 'opacity': 0.0});
//       });
//     }
//   }
//
//   void _animateItems() async {
//     for (int i = 0; i < items.length; i++) {
//       await Future.delayed(Duration(seconds: 2));
//       setState(() {
//         _currentIndex = i;
//         items[i]['opacity'] = 1.0;
//       });
//
//       if (items[i]['type'] == 'video') {
//         await _playVideo(items[i]['path']);
//       } else {
//         await Future.delayed(Duration(seconds: 1));
//       }
//
//       if (i < items.length - 1) {
//         setState(() {
//           items[i]['opacity'] = 0.0;
//         });
//       }
//     }
//   }
//
//   Future<void> _playVideo(String videoPath) async {
//     _videoController?.dispose();
//     _videoController = VideoPlayerController.file(File(videoPath))
//       ..initialize().then((_) {
//         setState(() {});
//         _videoController?.play();
//       });
//
//     await _videoController?.play();
//     await Future.delayed(Duration(seconds: _videoController?.value.duration.inSeconds ?? 0));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Animated Media List')),
//       body: Column(
//         children: [
//           ElevatedButton(
//             onPressed: () => _pickMedia(ImageSource.gallery, 'image'),
//             child: Text("Pick Image from Gallery"),
//           ),
//           ElevatedButton(
//             onPressed: () => _pickMedia(ImageSource.gallery, 'video'),
//             child: Text("Pick Video from Gallery"),
//           ),
//           ElevatedButton(
//             onPressed: _animateItems,
//             child: Text("Preview Animation"),
//           ),
//           Expanded(
//             child: Center(
//               child: Container(
//                 height: 400,
//                 child: Stack(
//                   children: items.map((item) {
//                     int index = items.indexOf(item);
//                     return AnimatedOpacity(
//                       opacity: index == _currentIndex ? 1.0 : 0.0,
//                       duration: Duration(seconds: 3),
//                       child: _buildItem(item),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildItem(Map<String, dynamic> item) {
//     if (item['type'] == 'image') {
//       return Image.file(File(item['path']));
//     } else if (item['type'] == 'video') {
//       return VideoWidget(videoPath: item['path']);
//     }
//     return Container(); // Placeholder if type is not recognized
//   }
// }
//
// class VideoWidget extends StatelessWidget {
//   final String videoPath;
//
//   VideoWidget({required this.videoPath});
//
//   @override
//   Widget build(BuildContext context) {
//     return AspectRatio(
//       aspectRatio: 16 / 9, // You can adjust aspect ratio as needed
//       child: VideoPlayerWidget(videoPath: videoPath),
//     );
//   }
// }
//
// class VideoPlayerWidget extends StatefulWidget {
//   final String videoPath;
//
//   VideoPlayerWidget({required this.videoPath});
//
//   @override
//   _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
// }
//
// class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
//   late VideoPlayerController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.file(File(widget.videoPath))
//       ..initialize().then((_) {
//         setState(() {});
//         _controller.play();
//       });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return _controller.value.isInitialized
//         ? VideoPlayer(_controller)
//         : Center(child: CircularProgressIndicator());
//   }
// }
