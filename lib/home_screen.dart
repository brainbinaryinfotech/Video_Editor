import 'dart:developer';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learn_demo_video/animated_screen.dart';
import 'package:learn_demo_video/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:mime/mime.dart';
import 'dart:io';

class VideoEditorScreen extends StatefulWidget {
  const VideoEditorScreen({super.key});

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  @override
  Widget build(BuildContext context) {
    final mediaProvider = Provider.of<MediaProvider>(context);
    ScrollController scrollController1 = ScrollController();

    void scrollToIndex(int index) {
      scrollController1.animateTo(
        index * 50.0,
        duration: const Duration(seconds: 3),
        curve: Easing.standard,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: mediaProvider.clearMedia,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
             await generateVideo(mediaProvider.mediaFiles);
              // createVideo(mediaProvider.mediaFiles);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Video saved to ',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: mediaProvider.mediaFiles.isEmpty
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height / 2,
                      child: const Center(
                        child: Text(
                          "CHOOSE A MEDIA",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController1,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: mediaProvider.mediaFiles.length,
                      itemBuilder: (context, index) {
                        final file = mediaProvider.mediaFiles[index];
                        if (file.path.endsWith('mp4')) {
                          final controller = mediaProvider.controllers[file.path];
                          return controller != null && controller.value.isInitialized
                              ? AspectRatio(
                                  aspectRatio: controller.value.aspectRatio,
                                  child: VideoPlayer(controller),
                                )
                              : Container();
                        } else {
                          return AnimatedImage(
                            imageFile: File(file.path),
                          );
                        }
                      },
                    ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                scrollToIndex(mediaProvider.mediaFiles.length * 4);
              },
              child: const Text('play'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.photo),
                                title: const Text('Pick Images'),
                                onTap: () {
                                  mediaProvider.pickMedia(false);
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.video_library),
                                title: const Text('Pick Videos'),
                                onTap: () {
                                  mediaProvider.pickMedia(true);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                    // _openBottomSheet(context) ;
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future createAndDownloadVideo(List<XFile> mediaFiles) async {
    await requestStoragePermission(); // Request storage permission

    if (mediaFiles.isNotEmpty) {
      String videoPath = mediaFiles.first.path;

      File videoFile = File(videoPath);

      if (videoFile.existsSync()) {
        Directory downloadsDir = Directory('/storage/emulated/0/Download');

        if (!downloadsDir.existsSync()) {
          downloadsDir.createSync(recursive: true);
        }

        String targetPath = '${downloadsDir.path}/output.mp4';

        try {
          await videoFile.copy(targetPath);
          log('Video copied to $targetPath');
        } catch (e) {
          log('Error copying video: $e');
        }
      } else {
        log('Video file not found');
      }
    } else {
      log('No video files available');
    }
  }
}
Future<void> generateVideo(List<XFile> images) async {
  String filterComplex = "";
  String inputs = "";
  int index = 0;

  // Add inputs and scaling
  for (XFile file in images) {
    final mimeType = lookupMimeType(file.path);

    if (mimeType != null && mimeType.startsWith('image/')) {
      inputs += "-loop 1 -t 3 -i ${file.path} ";
      filterComplex += "[$index:v]scale=1280:720,setdar=16/9[v$index];";
    }
    index++;
  }

  // Add fade transitions and overlay
  for (int i = 0; i < images.length - 1; i++) {
    filterComplex += "[v$i]format=pix_fmts=yuva420p,fade=t=out:st=2:d=1:alpha=1[va$i];";
    filterComplex += "[v${i + 1}]format=pix_fmts=yuva420p,fade=t=in:st=0:d=1:alpha=1[vb$i];";
    filterComplex += "[va$i][vb$i]overlay[tmp$i];";
  }

  // Construct the concatenation part
  String concatInputs = "";
  if (images.length > 1) {
    concatInputs = "[tmp${images.length - 2}][v${images.length - 1}]concat=n=2:v=1:a=0[outv]";
  } else {
    concatInputs = "[v0]concat=n=1:v=1:a=0[outv]";
  }
  filterComplex += concatInputs;

  final directory = await getApplicationDocumentsDirectory();
  final String outputPath = '${directory.path}/output.mp4';

  log("Output path: $outputPath");

  String command = "$inputs -filter_complex \"$filterComplex\" -map \"[outv]\" -y $outputPath";

  log("FFmpeg command: $command");

  await FFmpegKit.execute(command).then((session) async {
    final returnCode = await session.getReturnCode();
    final output = await session.getOutput();
    final error = await session.getFailStackTrace();

    if (ReturnCode.isSuccess(returnCode)) {
      log("FFmpeg process completed successfully.");
      bool? isSuccess = await GallerySaver.saveVideo(outputPath);
      if (isSuccess == true) {
        log("Video saved to gallery successfully.");
      } else {
        log("Failed to save video to gallery.");
      }
    } else if (ReturnCode.isCancel(returnCode)) {
      log("FFmpeg process was canceled.");
    } else {
      log("FFmpeg process failed with rc $returnCode");
      log("Output: $output");
      log("Error: $error");
    }
  });
}
// Future<void> generateVideo(List<XFile> images) async {
//   String filterComplex = "";
//   String inputs = "";
//   int index = 0;
//
//   // Add inputs and scaling
//   for (XFile file in images) {
//     final mimeType = lookupMimeType(file.path);
//
//     if (mimeType != null && mimeType.startsWith('image/')) {
//       inputs += "-loop 1 -t 3 -i ${file.path} ";
//       filterComplex += "[$index:v]scale=1280:720,setdar=16/9[v$index];";
//     } else if (mimeType != null && mimeType.startsWith('video/')) {
//       inputs += "-i ${file.path} ";
//       filterComplex += "[$index:v]scale=1280:720,setdar=16/9[v$index];";
//     }
//     index++;
//   }
//
//   // Add fade transitions and overlay
//   for (int i = 0; i < images.length - 1; i++) {
//     filterComplex += "[v$i]format=pix_fmts=yuva420p,fade=t=out:st=2:d=1:alpha=1[va$i];";
//     filterComplex += "[v${i + 1}]format=pix_fmts=yuva420p,fade=t=in:st=0:d=1:alpha=1[vb$i];";
//     filterComplex += "[va$i][vb$i]overlay[overlay$i];";
//   }
//
//   // Construct the concatenation part
//   String concatInputs = "";
//   for (int i = 0; i < images.length - 1; i++) {
//     concatInputs += "[overlay$i]";
//   }
//   concatInputs += "[v${images.length - 1}]";
//
//   filterComplex += concatInputs + "concat=n=${images.length}:v=1:a=0[outv]";
//
//   final directory = await getTemporaryDirectory();
//   final String outputPath = '${directory.path}/output.mp4';
//
//   log("Output path: $outputPath");
//
//
//   String command = "$inputs -filter_complex \"$filterComplex\" -map \"[outv]\" -y $outputPath";
//
//   await FFmpegKit.execute(command).then((session) async {
//     final returnCode = await session.getReturnCode();
//     final output = await session.getOutput();
//     final error = await session.getFailStackTrace();
//
//     if (ReturnCode.isSuccess(returnCode)) {
//       log("FFmpeg process completed successfully.");
//       bool? isSuccess = await GallerySaver.saveVideo(outputPath);
//       if (isSuccess == true) {
//         log(outputPath);
//         log("Video saved to gallery successfully.");
//       } else {
//         log("Failed to save video to gallery.");
//       }
//     } else if (ReturnCode.isCancel(returnCode)) {
//       log("FFmpeg process was canceled.");
//     } else {
//       log("FFmpeg process failed with rc $returnCode");
//       log("Output: $output");
//       log("Error: $error");
//     }
//   });
// }

// Future<void> generateVideo(List<XFile> images) async {
//   String filterComplex = "";
//   String inputs = "";
//   int index = 0;
//
//   for (XFile file in images) {
//
//     final mimeType = lookupMimeType(file.path);
//
//     if (mimeType != null && mimeType.startsWith('image/')) {
//       inputs += "-loop 1 -t 3 -i ${file.path} ";
//       filterComplex += "[$index:v]scale=1280:720,setdar=16/9[v$index];";
//     } else if (mimeType != null && mimeType.startsWith('video/')) {
//       inputs += "-i ${file.path} ";
//       filterComplex += "[$index:v]scale=1280:720,setdar=16/9[v$index];";
//     }
//
//     index++;
//
//   }
//
//   String concatInputs = "";
//
//   for (int i = 0; i < index; i++) {
//     concatInputs += "[v$i]";
//   }
//
//   filterComplex += "${concatInputs}concat=n=$index:v=1:a=0[outv]";
//
//   final directory = await getDownloadsDirectory();
//   final String outputPath = '${directory?.path}/output.mp4';
//
//   log("==========+>>>>>  $outputPath");
//
//   String command = "$inputs -filter_complex \"$filterComplex\" -map \"[outv]\" -y $outputPath";
//
//   await FFmpegKit.execute(command).then((rc) {
//     log("FFmpeg process exited with rc $rc");
//   });
//
//   //   String imageList = "";
//   //   String filterComplex = "";
//   //
//   //   for (int i = 0; i < images.length; i++) {
//   //     imageList += "-loop 1 -t 3 -i ${images[i].path} ";
//   //     filterComplex += "[$i:v]scale=1280:720,setdar=16/9[v$i];";
//   //   }
//   //
//   //   for (int i = 0 ; i < images.length - 1 ; i++) {
//   //     filterComplex += "[$i:v]format=pix_fmts=yuva420p,fade=t=out:st=2:d=1:alpha=1[va$i];";
//   //     filterComplex += "[${i + 1}:v]format=pix_fmts=yuva420p,fade=t=in:st=0:d=20:alpha=1[vb$i];";
//   //     filterComplex += "[va$i][vb$i]overlay[c$i];";
//   //   }
//   //
//   //   String concatInputs = "";
//   //   for (int i = 0; i < images.length; i++) {
//   //     concatInputs += "[v$i]";
//   //   }
//   //
//   //   filterComplex += "${concatInputs}concat=n=${images.length}:v=1:a=0[outv]";
//   //
//   //   final directory = Directory('/storage/emulated/0/Download');
//   //
//   //   final String outputPath = '${directory.path}/output.mp4';
//   //
//   //   log("==========+>>>>   $outputPath");
//   //
//   //   String command = "$imageList -filter_complex \"$filterComplex\" -map \"[outv]\" -y $outputPath";
//   //
//   //   final video = await FFmpegKit.execute(command);
//
// }


Future<void> requestStoragePermission() async {
  PermissionStatus status = await Permission.storage.request();
  if (status != PermissionStatus.granted) {
    log('Storage permission denied');
    return;
  }
}

// Future<String> createVideo(List<XFile> mediaFiles) async {
//   final outputDir = await getDownloadsDirectory();
//   print(outputDir);
//   final outputPath = '${outputDir!.path}/output.mp4';
//   bool hasExisted = await outputDir.exists();
//   if (!hasExisted) {
//     outputDir.create();
//   }
//   final String fileName = 'output.mp4';
//   final File localVideo = File(outputPath);
//   final File copiedVideo = await localVideo.copy('${outputDir.path}/$fileName');
//   await GallerySaver.saveVideo(copiedVideo.path);
//
//   String command = "-y";
//
//   for (var file in mediaFiles) {
//     if (file.path.endsWith('.mp4')) {
//       command += ' -i ${file.path}';
//     } else {
//       command += ' -loop 1 -t 3 -i ${file.path}';
//     }
//   }
//
//   command +=
//       ' -filter_complex "[0:v] [0:a] [1:v] [1:a] concat=n=${mediaFiles.length}:v=1:a=1 [v] [a]" -map "[v]" -map "[a]" $outputPath';
//
//   await FFmpegKit.execute(command);
//   return outputPath;
// }
