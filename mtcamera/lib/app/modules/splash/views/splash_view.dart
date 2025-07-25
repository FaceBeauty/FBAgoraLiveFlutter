import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:get/get.dart';
import 'package:mtcamera/app/routes/app_pages.dart';

import '../controllers/splash_controller.dart';

///启动页
class SplashView extends GetView<SplashController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _ContentView(),
      ),
    );
  }
}

///启动页的内容View
class _ContentView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ContentViewState();
  }
}

class _ContentViewState extends State<_ContentView> {
  @override
  void initState() {
    final SplashController controller = Get.find();
    //计时器
    Timer.periodic(Duration(milliseconds: 1000), (timer) {
      if (controller.count > 0) {
        printInfo(info: "count:${controller.count}");
        controller.reduce();
      } else {
        //导航到主页
        printInfo(info: "页面跳转");
        Get.offNamed(Routes.HOME);
        timer.cancel();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Container(
            alignment: Alignment.center,
            color: Theme.of(context).primaryColor,
            child: Text('LOGO', style: TextStyle(color: Colors.white)),
          ),
        ),
        SizedBox(height: 20),
        Text('FaceBeauty', style: TextStyle(fontWeight: FontWeight.bold))
      ],
    );
  }

  @override
  void dispose() {
    Get.delete<SplashController>();
    super.dispose();
  }
}
