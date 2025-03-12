import 'package:flutter/material.dart';
import 'package:yamaha_ql_control/widgets/CustomTrackShape.dart';
import 'package:yamaha_ql_control/widgets/fader.dart';

import 'io/YamahaConnector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        sliderTheme: SliderThemeData(
          showValueIndicator: ShowValueIndicator.always,
          valueIndicatorColor: Colors.blueAccent,
          trackShape: CustomTrackShape(),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key,});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  YamahaConnector ql = YamahaConnector("10.0.0.3");

  @override
  void initState() {
    super.initState();
    ql.connect(onConnectionAccomplished: () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ql.connectionEstablished ? (FaderControls(ql: ql)..easyMode = true) : Center(child: CircularProgressIndicator()),
    );
  }
}
