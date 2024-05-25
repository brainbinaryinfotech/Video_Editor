import 'package:flutter/material.dart';
import 'package:learn_demo_video/home_screen.dart';
import 'package:learn_demo_video/createvideo.dart';
import 'package:learn_demo_video/provider.dart';
import 'package:learn_demo_video/select_media.dart';
import 'package:provider/provider.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // return ChangeNotifierProvider(
    //   create: (_) => MediaProvider(),
    //   child: const MaterialApp(
    //     debugShowCheckedModeBanner: false,
    //     home: VideoEditorScreen(),
    //   ),
    // );}
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:GalleryPickerScreen()

    );


  }
  List<Map<String, dynamic>> items = [
    {'type': 'image', 'path': 'assets/images/Rectangle 1.png', 'opacity': 0.0},
    {'type': 'image', 'path': 'assets/images/image 1 (1).png', 'opacity': 0.0},
    {'type': 'video', 'path': 'assets/images/27.04.2024_16.42.45_REC.mp4', 'opacity': 0.0},
    {'type': 'image', 'path': 'assets/images/Rectangle 4.png', 'opacity': 0.0},
    {'type': 'image', 'path': 'assets/images/Rectangle 3.png', 'opacity': 0.0},
  ];
}








