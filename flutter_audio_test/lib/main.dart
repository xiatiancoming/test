import 'dart:async';

import 'package:better_audio_picker_plugin/better_audio_picker_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late BetterAudioPickerPlugin audioPickerPlugin;
  late StreamSubscription scanResultStreamSubscription;
  late StreamSubscription pickResultStreamSubscription;

  List<BetterAudioPickerPluginAudioModel> audioList = [];

  @override
  void initState() {
    super.initState();

    audioPickerPlugin = BetterAudioPickerPlugin();
    scanResultStreamSubscription = audioPickerPlugin.scanResultStream.listen((event) {
      print("音频搜索结果：$event");
      setState(() {
        audioList = event;
      });
    });
    pickResultStreamSubscription = audioPickerPlugin.pickResultStream.listen((event) {
      print("音频保存路径：$event");
    });

    Future.delayed(Duration.zero, () async {
      if (await Permission.storage.isGranted) {
        audioPickerPlugin.scanAudio();
      } else if (!(await Permission.storage.isPermanentlyDenied)) {
        final status = await Permission.storage.request();
        if (status == PermissionStatus.granted) {
          audioPickerPlugin.scanAudio();
        } else {
          openAppSettings();
        }
      } else {
        openAppSettings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView.builder(
            itemBuilder: (context, index) {
              final audio = audioList[index];
              return CupertinoButton(
                  child: Text("${audio.name}"),
                  onPressed: () async {
                    final tempDirectory = await getTemporaryDirectory();
                    final tempPath = path.join(tempDirectory.path, audio.name);
                    audioPickerPlugin.pickAudio(uri: audio.uri, path: tempPath);
                  });
            },
            itemCount: audioList.length),
      ),
    );
  }
}