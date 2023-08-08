import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouFlutter',
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: const MyHomePage(title: 'YouFlutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Enter YouTube URL"),
            TextField(controller: textEditingController, textAlign: TextAlign.center),
            SizedBox(
              height: 16,
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      downloadVideo(true);
                    },
                    child: Text("MP3")),
                ElevatedButton(
                    onPressed: () async {
                      downloadVideo(false);
                    },
                    child: Text("MP4")),
              ],
            )
          ],
        ),
      ),
    );
  }

  void downloadVideo(bool audioOnly) async {
    YoutubeExplode yt = YoutubeExplode();
    var video = await yt.videos.streamsClient.getManifest(textEditingController.text);
    var streamInfo;
    if(audioOnly) {
      streamInfo = video.audioOnly.withHighestBitrate();
    } else {
      streamInfo = video.muxed.withHighestBitrate();
    }
    if(streamInfo != null) {
      var vid = await yt.videos.get(textEditingController.text);
      var title = vid.title.replaceAll(RegExp("[^a-zA-Z0-9 -]"), "");

      var stream = yt.videos.streamsClient.get(streamInfo);

      String? outputFile = await FilePicker.platform.saveFile(dialogTitle: "Save", fileName: "${title}.${audioOnly ? "mp3" : "mp4"}", allowedExtensions: [audioOnly ? "mp3" : "mp4"]);
      if(outputFile == null) {
        yt.close();
        return;
      }
      var file = File(outputFile!);
      var fileStream = file.openWrite();

      // Pipe all the content of the stream into the file.
      await stream.pipe(fileStream);

      // Close the file.
      await fileStream.flush();
      await fileStream.close();
    }
    yt.close();
  }
}
