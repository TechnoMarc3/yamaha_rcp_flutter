import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:yamaha_ql_control/io/YamahaConnector.dart';
import 'package:yamaha_ql_control/widgets/CircleScroll.dart';

import 'fader_details.dart';

class FaderControls extends StatefulWidget {
  final YamahaConnector ql;
  bool easyMode = false;
  FaderControls({
    super.key,
    required this.ql,
  });

  @override
  State<FaderControls> createState() => FaderControlsState();
}

class FaderControlsState extends State<FaderControls> {
  int faderPage = 1;
  List<Fader> faders = [];
  List<Fader> displayedFaders = [];

  @override
  void initState() {
    super.initState();
    initAndLoadFaders();
  /*
    faders = [
      Fader("Pult 1", 0, -740),
      Fader("funk 1", 1, -740),
    ];


    displayedFaders = faders;
    widget.ql.savedFaders = faders;
    */

  }

  void initAndLoadFaders() async {
    for (int i = 0; i < 32; i++) {
      String name = await widget.ql.getFaderName(i);
      double intensity = await widget.ql.getFaderIntensity(i);
      bool activation = await widget.ql.getFaderActivation(i);
      int gain = await widget.ql.getChannelGain(i);
      debugPrint("Channel id $i has gain $gain");
      faders.add(Fader(name, i, intensity.toDouble())..activated = activation);
    }
    setState(() {});
    //addpostframecallback
    displayedFaders = faders.sublist(0, 16);
    widget.ql.savedFaders = faders;
    debugPrint("easy mode is ${widget.easyMode}");
    if (widget.easyMode) {
      displayedFaders = faders
          .where((e) => e.name == "Pult 2" || e.name == "funk 1")
          .toList();
    }
    var n = await widget.ql.getPatchForIndex(12);
    debugPrint("Patch 12: $n");
  }

  @override
  Widget build(BuildContext context) {
    //return grid of faders
    debugPrint(faders.toString());
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            widget.easyMode
                ? Column(
                    children: [
                      Text(
                        "Funktionsübersicht",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.44,
                              child: Row(
                                children: [
                                  ElevatedButton(
                                      onPressed: null,
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.orange)),
                                      child: Text("ON", style: TextStyle(color: Colors.blue.shade900),)),
                                  Text(
                                      "Mikrofon ist an, kann durch ein weiteres Tippen deaktiviert werden"),
                                ],
                              )),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.44,
                              child: Row(
                                children: [
                                  ElevatedButton(
                                      onPressed: null,
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.grey)),
                                      child: Text("ON", style: TextStyle(color: Colors.blue.shade900),)),
                                  Text(
                                      "Mikrofon ist aus, kann durch ein weiteres Tippen aktiviert werden"),
                                ],
                              )),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.44,
                              child: Row(
                                children: [
                                  ElevatedButton(
                                      onPressed: null,
                                      child: Text(" ++ Lauter ++ ", style: TextStyle(color: Colors.blue.shade900),)),
                                  Text("Mikrofon wird etwas lauter gestellt"),
                                ],
                              )),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.44,
                              child: Row(
                                children: [
                                  ElevatedButton(
                                      onPressed: null,
                                      child: Text(" -- Leiser -- ", style: TextStyle(color: Colors.blue.shade900),)),
                                  Text("Mikrofon wird etwas leiser gestellt"),
                                ],
                              )),
                        ],
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (faderPage == 1) return;
                            faderPage--;
                            displayedFaders = faders.sublist(0, 16);
                          });
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: (faderPage == 1) ? Colors.grey : Colors.black,
                        ),
                      ),
                      Text('Faders (Seite $faderPage)'),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (faderPage == 2) return;
                            faderPage++;
                            displayedFaders = faders.sublist(17, 32);
                          });
                        },
                        icon: Icon(
                          Icons.arrow_forward,
                          color: (faderPage == 2) ? Colors.grey : Colors.black,
                        ),
                      ),
                    ],
                  ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (Fader f in displayedFaders)
                    f.build(widget.easyMode, widget.ql, context, setState)
                ],
              ),
            )
          ],
        ));
  }
}

class Fader {
  String name = "";
  int index = 0;
  double intensity = 0;
  bool activated = false;
  String description = "";
  Function(void Function())? updateFunction;

  Fader(this.name, this.index, this.intensity) {
    switch (name) {
      case "Pult 2":
        description =
            "Dieses **feste Mikrofon** ist direkt am **Rednerpult** installiert und wird aktiviert, wenn man am Pult spricht. Es ist darauf ausgelegt, **nicht berührt** zu werden, um eine optimale Klangqualität zu gewährleisten. Bitte vermeiden Sie es, das Mikrofon zu verstellen oder zu berühren, um Störgeräusche zu minimieren.";
      case "funk 1":
        description =
            "Dieses **kabellose Mikrofon** kann frei im Raum bewegt werden und eignet sich ideal für **Publikumsfragen**. Es ermöglicht den Teilnehmern, ohne Einschränkungen durch Kabel ihre Fragen zu stellen und sich aktiv an Diskussionen zu beteiligen.";
      default:
        description = "";
    }
  }

  Widget buildExtendedFaderConfig(int index, YamahaConnector ql, BuildContext ctx, Function(void Function()) setState) {
    var completeFuture = Future.wait([ql.getMixersForIndex(index), ql.getPatchForIndex(index), ql.getChannelGain(index)]);

    return FaderDetails(completeFuture: completeFuture, ql: ql, fader: this,);
  }

  Widget buildFader(YamahaConnector ql, BuildContext ctx,
      Function(void Function()) setState, {bool withEditButton = true}) {
    this.updateFunction = setState;
    return SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.9,
        width: 120,
        child: Card(
            child: Column(
          children: [
            Text(name),
            Text(intensity.toInt().toString()),
            withEditButton ?
            ElevatedButton(onPressed: () {
              Navigator.push(ctx, MaterialPageRoute(builder: (context) {
                return buildExtendedFaderConfig(index, ql, ctx, setState);
              }));
            }, child: Text("Edit")) : Container(),
            ElevatedButton(
                onPressed: () {
                  activated = !activated;
                  setState(() {
                    ql.send(
                        "set MIXER:Current/InCh/Fader/On $index 0 ${activated ? 1 : 0}\n");
                  });
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        activated ? Colors.orange : Colors.grey)),
                child: Text("ON")),
            Stack(
              children: [
                RotatedBox(
                    quarterTurns: 3,
                    child: SizedBox(
                        width: MediaQuery.of(ctx).size.height * 0.58,
                        child:
                            Slider(
                              min: -6000,
                              max: 1000,
                              value: max(intensity, -6000),
                              onChangeEnd: (value) {},
                              onChanged: (double value) {
                                setState(() {
                                  intensity = value;
                                  update(name, index, intensity);
                                  ql.send(
                                      "set MIXER:Current/InCh/Fader/Level $index 0 ${intensity.toInt()}\n");
                                });
                              },
                            ))),

                        for (int i = 0; i <= 14; i++)
                          Positioned(
                            top: i*(MediaQuery.of(ctx).size.height * 0.58)/14,
                            left: 40,
                            child: Container(
                              width: 2,
                              height: (MediaQuery.of(ctx).size.height * 0.58)/14,
                              color: i % 2 == 0 ? Colors.black : Colors.grey,
                            ),
                          ),


                          for (int i = 0; i <= 14; i++)
                            Positioned(
                              top: (i*(MediaQuery.of(ctx).size.height * 0.58)/14)-10.5,
                              left: 70,
                              child: SizedBox(
                                width: 40,
                                height:  (MediaQuery.of(ctx).size.height * 0.58)/14,
                                child: Text((1000 - (i)*500).toString()),
                              ),
                            ),
                       ]),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    intensity = -32768;
                    update(name, index, intensity);
                    ql.send(
                        "set MIXER:Current/InCh/Fader/Level $index 0 ${intensity.toInt()}\n");
                  });
                },
                child: Text("-Infinity")),
          ],
        )));
  }

  Widget build(bool isEasy, YamahaConnector ql, BuildContext ctx,
      Function(void Function()) setState) {
    if (isEasy) {
      return buildAccessibleFader(ql, ctx, setState);
    } else {
      return buildFader(ql, ctx, setState);
    }
  }

  Widget buildAccessibleFader(YamahaConnector ql, BuildContext ctx,
      Function(void Function()) setState) {
    this.updateFunction = setState;
    return SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.78,
        child: Card(
            child: Row(
          children: [
            Column(children: [
              Text(name),
              Text(intensity.toInt().toString()),
              ElevatedButton(
                  onPressed: () {
                    intensity += 100;
                    setState(() {
                      update(name, index, intensity);
                      ql.send(
                          "set MIXER:Current/InCh/Fader/Level $index 0 ${intensity.toInt()}\n");
                    });
                  },
                  child: Text(" ++  Lauter ++ ")),
              RotatedBox(
                  quarterTurns: 3,
                  child: SizedBox(
                    width: MediaQuery.of(ctx).size.height * 0.5,
                    child: Slider(
                      min: -6000,
                      max: 1000,
                      value: max(intensity, -6000),
                      onChangeEnd: (value) {},
                      onChanged: null,
                    ),
                  )),
              ElevatedButton(
                  onPressed: () {
                    intensity -= 100;
                    setState(() {
                      update(name, index, intensity);
                      ql.send(
                          "set MIXER:Current/InCh/Fader/Level $index 0 ${intensity.toInt()}\n");
                    });
                  },
                  child: Text(" -- Leiser -- ")),
              ElevatedButton(
                  onPressed: () {
                    activated = !activated;
                    setState(() {
                      ql.send(
                          "set MIXER:Current/InCh/Fader/On $index 0 ${activated ? 1 : 0}\n");
                    });
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          activated ? Colors.orange : Colors.grey)),
                  child: Text("ON")),
            ]),
            SizedBox(
              width: MediaQuery.of(ctx).size.width * 0.33,
              child: Column(
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 30, color: Colors.red),
                  ),
                  MarkdownBody(
                    data: description,
                    styleSheet: MarkdownStyleSheet(),
                  )
                ],
              ),
            )
          ],
        )));
  }

  void update(String name, int index, double intensity) {
    //if name == "" dont update, also for 0 values in int
    if (name != "") this.name = name;
    if (index != 0) this.index = index;
    if (intensity != 0) this.intensity = intensity;
  }

  void forceUpdate(String name, int index, int faderPage, double intensity) {
    this.name = name;
    this.index = index;
    this.intensity = intensity;
    debugPrint("Force updated fader $name");
  }

  void updateInternal(double? newIntensity, String? newName) {
    debugPrint(
        "Updating fader $name with intensity $newIntensity and name $newName");
    if (newIntensity != null) intensity = newIntensity * 100;
    if (newName != null) name = newName;
    this.updateFunction?.call(() {});
  }
}

/*
ElevatedButton(onPressed: () async{
          Socket s = await Socket.connect("10.0.0.3",49280);
          s.write('set MIXER:Current/InCh/Fader/Level 31 0 -4500 ');
          s.listen((data) {
            debugPrint(utf8.decode(data));
          });
      }, child: Text("mit Tonpult verbinden")),
 */
