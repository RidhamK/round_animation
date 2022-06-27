import 'package:flutter/material.dart';
import 'package:get/get.dart';

class getcontroller extends GetxController {
  late AnimationController controller;
  late Animation<double> animation;

  playanim() {
    controller.forward();
  }
}
