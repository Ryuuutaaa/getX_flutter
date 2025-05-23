import 'package:getx_todolist/app/core/values/icons.dart';
import 'package:getx_todolist/app/core/values/colors.dart';
import 'package:flutter/material.dart';

List<Icon> getIcons() {
  return const [
    Icon(IconData(personIcon, fontFamily: 'MaterialIcons')),
    Icon(IconData(worklcon, fontFamily: 'MaterialIcons')),
    Icon(IconData(movieIcon, fontFamily: 'MaterialIcons')),
    Icon(IconData(sporticon, fontFamily: 'MaterialIcons')),
    Icon(IconData(travelIcon, fontFamily: 'MaterialIcons')),
    Icon(IconData(shoplcon, fontFamily: 'MaterialIcons')),
  ];
}
