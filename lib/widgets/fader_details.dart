import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yamaha_ql_control/io/YamahaConnector.dart';
import 'package:yamaha_ql_control/widgets/fader.dart';

import 'CircleScroll.dart';

class FaderDetails extends StatefulWidget {

  Future<List<dynamic>> completeFuture;
  Fader fader;
  YamahaConnector ql;

  FaderDetails({
    super.key,
    required this.completeFuture,
    required this.fader,
    required this.ql,
  });



  @override
  State<FaderDetails> createState() => _FaderDetailsState();
}

class _FaderDetailsState extends State<FaderDetails> {

  var colors = <Color>[
    Colors.pink,
    Colors.pink,
    Colors.pink,
    Colors.pink,
    Colors.blue.shade900,
    Colors.blue.shade900,
    Colors.blue.shade900,
    Colors.grey,
    Colors.blue,
    Colors.blue,
    Colors.blue,
    Colors.blue,
    Colors.blueAccent.shade700,
    Colors.blueAccent.shade700,
    Colors.blueAccent.shade700,
    Colors.blueAccent.shade700
  ];

  int patchIndexSelected = 0;

  @override
  Widget build(BuildContext context) {
    var dir = MediaQuery.of(context).orientation;
    return FutureBuilder(future: widget.completeFuture, builder: (context, snapshot) {
      if(snapshot.connectionState == ConnectionState.waiting) {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      var mixers = snapshot.data![0] as Map<int, int>;
      var patch = snapshot.data![1] as String;
      var gain = snapshot.data![2] as int;
      return
        Scaffold(
            body:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: 150 + MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.height,
                      child:
                      //CircleScroll(colors[mixers.keys.first], ql, "MIXER:Current/InCh/ToMix/Level ${mixers.keys.first}", mixers![mixers.keys.first]!, -6000, 1000)

                      GridView.count(
                        crossAxisCount: 2,
                        children:
                        mixers.entries.map((e) {
                          return CircleScroll(colors[e.key], widget.ql, "MIXER:Current/InCh/ToMix/Level ${e.key}", (e.value/100).toInt(), -60, 10);
                        }).toList(),),


                    ),
                  ],
                ), SingleChildScrollView(
                scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      ElevatedButton(onPressed: () {
                        showDialog(context: context, builder: (context) {
                          return buildPatchDialog(patch, context, 0);
                        });
                      }, child: Column(
                        children: [
                          Text("Patch"),
                          Text(patch.toUpperCase().replaceAll('"', ""), style: TextStyle(fontSize: 20),),
                        ],
                      )),
                      CircleScroll(Colors.grey, widget.ql, "MIXER:Current/InCh/Port/HA/Gain 0 ${widget.fader.index}", gain, -50, 10),
                      widget.fader.buildFader(widget.ql, context, setState, withEditButton: false)
                    ],
                  ),
                )
              ],
            )
        );

    });
  }

  AlertDialog buildPatchDialog(String patch, BuildContext ctx,int index) {
    var size = MediaQuery.of(ctx).size;
    return AlertDialog(
      title: Text("Patch: $patch"),
      content: SizedBox(
        width: size.width * 0.8,
        height: size.height * 0.8,
        child: Row(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
child:
Column(
  children: [
    TextButton(onPressed: () {
      Navigator.pop(context);
      showDialog(context: context, builder: (context) {
        return buildPatchDialog(patch, context, 0);
      });
    }, child: Text("Input 1 - 16")),
    TextButton(onPressed: () {
      Navigator.pop(context);
      showDialog(context: context, builder: (context) {
        return buildPatchDialog(patch, context, 1);
      });
    }, child: Text("Dante 1 - 16")),
    TextButton(onPressed: () {
      Navigator.pop(context);
      showDialog(context: context, builder: (context) {
        return buildPatchDialog(patch, context, 2);
      });
    }, child: Text("Dante 17 - 32")),
  ],
),
            ),


            SizedBox(width: size.width*0.4,height: size.height*0.77, child:
            GridView.count(crossAxisCount: 4, children: List.generate(16, (i) {
              var txt = index == 0 ? "Input${i+1}" : index == 1 ? "Dante${i+1}" : "Dante${i+17}";
              return ElevatedButton(onPressed: () {
                widget.ql.send("set MIXER:Current/InCh/Patch $index $patchIndexSelected\n");
              }, child: Text(txt),
                //background color
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(txt.toLowerCase() == patch.toLowerCase().replaceAll('"', "") ? Colors.blueAccent.shade200: Colors.white)),
              );
            }),
            )

            )
          ],
        ),
      ),
      actions: [
        ElevatedButton(onPressed: () {
          Navigator.pop(context);
        }, child: Text("OK"))
      ],
    );
  }
}