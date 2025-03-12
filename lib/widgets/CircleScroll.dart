import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:yamaha_ql_control/Extensions.dart';
import 'package:yamaha_ql_control/io/YamahaConnector.dart';

class CircleScroll extends StatefulWidget {
  Color color;
  YamahaConnector ql;
  String qlName;
  int value;
  int min;
  int max;


  CircleScroll(this.color, this.ql, this.qlName, this.value, this.min, this.max);

  @override
  State<CircleScroll> createState() => _CircleScrollState();


}

class _CircleScrollState extends State<CircleScroll> {

    @override
    Widget build(BuildContext context) {
      //first a circle
      return Card(
          child:
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(width: 150,
              height: 150,child:
                  SfRadialGauge(
                    animationDuration: 150,
                      axes: <RadialAxis>[
                        RadialAxis(minimum: widget.min.toDouble(), maximum: widget.max.toDouble(), axisLineStyle: AxisLineStyle(color: widget.color),ranges: <GaugeRange>[
                          GaugeRange(
                              startValue: 0,
                              endValue: (widget.max - widget.min)/7,
                              startWidth: 10,
                              color: widget.color,
                              endWidth: 10),
                          GaugeRange(
                              startValue: (widget.max - widget.min)/7,
                              endValue: 3*(widget.max - widget.min)/7,
                              startWidth: 10,
                              color: widget.color,
                              endWidth: 10),
                          GaugeRange(
                              startValue: 3*(widget.max - widget.min)/7,
                              endValue: 5*(widget.max - widget.min)/7,
                              color: widget.color,
                              startWidth: 10,
                              endWidth: 10),
                          GaugeRange(
                              startValue: 5*(widget.max - widget.min)/7,
                              color: widget.color,
                              endValue: widget.max.toDouble(),
                              startWidth: 10,
                              endWidth: 10)
                        ], pointers: <GaugePointer>[
                          NeedlePointer(value: (widget.value).toDouble(), enableAnimation: true,
                            enableDragging: true,
                            onValueChanged: (e) {
                            debugPrint("Value changed to ${e.toInt()}");
                            setState(() {
                              widget.value = e.toInt();
                              widget.ql.send("set ${widget.qlName} ${widget.value}");
                            });
                          },)
                        ], annotations: <GaugeAnnotation>[
                          GaugeAnnotation(
                              widget: Container(
                                  child:  Text(widget.value.toString(),
                                      style: TextStyle(
                                          fontSize: 20))),
                              angle: 90,
                              positionFactor: 0.5)
                        ])
                      ]),
              ),
            ],
          )
      );

    }

}