// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

enum MapIconTextPlacement {
  NO_LABEL,
  BOTTOM_CENTER,
  BOTTOM_RIGHT,
  BOTTOM_LEFT,
  CIRCLE_BOTTOM_RIGHT,
  RIGHT_BOTTOM,
  RIGHT_CENTER,
  RIGHT_TOP,
  CIRCLE_TOP_RIGHT,
  TOP_CENTER,
  TOP_RIGHT,
  TOP_LEFT,
  CIRCLE_TOP_LEFT,
  LEFT_TOP,
  LEFT_CENTER,
  LEFT_BOTTOM,
  CIRCLE_BOTTOM_LEFT,
  CENTER_CENTER
}

// Text appearance settings.
class MapIconTextStyle {
  // Label font size.
  final double fontSize;

  // Label color.
  final Color color;

  // Label stroke width.
  final double strokeWidth;

  // Label stroke color.
  final Color strokeColor;

  //    The options for label position relative to the
  //  icon. The position is determined as follows:

  //    The first part of the enum denotes the area
  //  relative to which the label position is defined:
  //  A. "Circle" - means it considers a circle around the marker.
  //  B. An empty string - means it considers a square.

  //    The second part of the enum defines the zone
  //  within the area around the marker.

  //    The third part of the enum determines the label's
  //  placement inside the zone.
  final MapIconTextPlacement textPlacement;

  // Label offset relative to the icon
  final double textOffset;

  const MapIconTextStyle({
    this.fontSize = 8.0,
    this.color = Colors.black,
    this.strokeWidth = 0.4,
    this.strokeColor = Colors.black,
    this.textPlacement = MapIconTextPlacement.BOTTOM_CENTER,
    this.textOffset = 0.0,
  });

  MapIconTextStyle.fromJson(Map<String, dynamic> json)
      : fontSize = json["fontSize"],
        color = Color(json["color"]),
        strokeWidth = json["strokeWidth"],
        strokeColor = Color(json["strokeColor"]),
        textPlacement = MapIconTextPlacement.values
            .firstWhere((e) => e.name == json["textPlacement"]),
        textOffset = json["textOffset"];

  Map<String, dynamic> toJson() => {
        "fontSize": fontSize,
        "color": color.value,
        "strokeWidth": strokeWidth,
        "strokeColor": strokeColor.value,
        "textPlacement": textPlacement.name,
        "textOffset": textOffset,
      };

  MapIconTextStyle copyWith({
    double? fontSize,
    Color? color,
    double? strokeWidth,
    Color? strokeColor,
    MapIconTextPlacement? textPlacement,
    double? textOffset,
  }) {
    return MapIconTextStyle(
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeColor: strokeColor ?? this.strokeColor,
      textPlacement: textPlacement ?? this.textPlacement,
      textOffset: textOffset ?? this.textOffset,
    );
  }
}
