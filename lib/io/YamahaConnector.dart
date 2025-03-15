import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../widgets/fader.dart';

class YamahaConnector {
 String ip;
 int port = 49280;
 //50000;
 Socket? connectedSocket;
 Stream<dynamic>? dataStream;
 List<Fader> savedFaders = [];
 bool connectionEstablished = kDebugMode;
 //true;

 YamahaConnector(this.ip);

  void connect({ Function? onConnectionAccomplished }) async {
    connectedSocket = await Socket.connect(ip, port);
    dataStream = connectedSocket?.transform(utf8.decoder.cast()).transform(const LineSplitter().cast()).asBroadcastStream();
    connectionEstablished = true;
    onConnectionAccomplished?.call();
    dataStream?.listen((event) {
      debugPrint("Received: $event");
    });

  }

  void _socketReconnect() {
    connectedSocket?.destroy();
    connect();
  }

  void send(String message) async{
    connectedSocket?.write(message);

  }
  
  //getfadername
  Future<String> getFaderName(int index) async{
    send("get MIXER:Current/InCh/Label/Name $index 0 \n");
    Completer<String> completer = Completer();
    dataStream?.listen((event) {
      if(!event.contains("MIXER:Current/InCh/Label/Name ")) return;
      var s = event as String;
      var name = event.substring(event.indexOf('"')+1, event.lastIndexOf('"'));
      debugPrint("Received name: $name");
      if(completer.isCompleted) {
        completer = Completer();
      }
      if(savedFaders.length == 32) {
        var index = int.parse(s.split(" ")[3]);
        savedFaders[index].updateInternal(null, name);
      }


      completer.complete(name);
    });
    return completer.future;

  }

  Future<int> getChannelGain(int index) {
    if(kDebugMode) {
      Completer<int> c = Completer();

      c.complete( -5);
      return c.future;
    }
    send("get MIXER:Current/InCh/Port/HA/Gain $index 0\n");
    Completer<int> completer = Completer();
    dataStream?.listen((event) {
      if(!event.contains("MIXER:Current/InCh/Port/HA/Gain")) return;
      var s = event as String;
      var gain = int.parse(s.split(" ").last);
      debugPrint("Received gain: $gain");
      if(completer.isCompleted) {
        completer = Completer();
      }
      completer.complete(gain);
    });
    return completer.future;
  }

  Future<bool> getFaderActivation(int index) async{
    send("get MIXER:Current/InCh/Fader/On $index 0\n");
    //TODO: might be wrong
    Completer<bool> completer = Completer();
    dataStream?.listen((event) {
      if(!event.contains("MIXER:Current/InCh/Fader/On")) return;
      var s = event as String;
      var activation = s.split(" ")[s.split(" ").length-2] == "1";
      debugPrint("Received activation: $activation");
      if(completer.isCompleted) {
        completer = Completer();
      }
      completer.complete(activation);
    });
    return completer.future;
  }

  Future<Map<int, int>> getMixersForIndex(int index) {
    Completer<Map<int, int>> completer = Completer();
    if(kDebugMode) {
      completer.complete( Map.fromIterable(List.generate(16, (index) => index), value: (index) => 0));
      return completer.future;
    }
    Map<int, int> mixers = {};
    dataStream?.listen((event) {
      if(!event.contains("MIXER:Current/InCh/ToMix/Level")) return;
      var s = event as String;
      var i = int.parse(s.split(" ")[s.split(" ").length-2]);
      var level = int.parse(s.split(" ").last);
      debugPrint("Received mixer: $i $level");
      mixers[i] = level;
      if(mixers.keys.length == 16) {
        if(completer.isCompleted) {
          completer = Completer();
        }
        completer.complete(mixers);
      }
    });
    for(var i = 0; i<16;i++) {
      send("get MIXER:Current/InCh/ToMix/Level $index $i\n");
    }
    return completer.future;
  }

  Future<String> getPatchForIndex(int index) {
    Completer<String> completer = Completer();
if(kDebugMode) {
  completer.complete("DANTE 1");
  return completer.future;
}

    send("get MIXER:Current/InCh/Patch $index 0\n");

    dataStream?.listen((event) {
      if(!event.contains("MIXER:Current/InCh/Patch")) return;
      var s = event as String;
      var patch = s.split(" ").last;
      debugPrint("Received patch: $patch");
      if(completer.isCompleted) {
        completer = Completer();
      }
      completer.complete(patch);
    });
    return completer.future;
  }

  //treshold: MIXER:Current/InCh/Dyna1 _ Dyna2/Threshold $index



  Future<double> getFaderIntensity(int index) async{
    Completer<double> completer = Completer();
    if(kDebugMode) {
      completer.complete(-740 );
      return completer.future;
    }
    send("get MIXER:Current/InCh/Fader/Level $index 0\n");

   dataStream?.listen((event) {
     var s = event as String;
      if(!event.contains("MIXER:Current/InCh/Fader/Level")) return;
     try{
       var intensity = double.parse(event.split(" ").last.replaceAll('"', ""));
       if(completer.isCompleted) {
         completer = Completer();
       }

       var index = int.parse(s.split(" ")[3]);
       if(savedFaders.length == 32) {

         savedFaders[index].updateInternal(intensity, null);
       }

       completer.complete(intensity);
     }catch(e){
       if(completer.isCompleted) {
         completer = Completer();
       }
       completer.completeError(e);
     }

    });
    return completer.future;
  }

}