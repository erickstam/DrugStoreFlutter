import 'dart:async';
import 'dart:math';

import 'package:drugstore/paginas/login.screen2.dart';
import 'package:drugstore/utils/global.color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class Splash extends StatelessWidget{
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    Timer(const Duration(seconds: 2), () {
      Get.to(Login2());
    });
    return Scaffold(
      backgroundColor: globalColors.mainColor,
      body: const Center(
        child: Text(
          'DrugStore.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 35,
            fontWeight: FontWeight.bold,
          )
        )
      )
    );
  }
}