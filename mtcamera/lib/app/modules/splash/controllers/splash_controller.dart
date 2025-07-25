import 'package:get/get.dart';

class SplashController extends GetxController {
  //用于倒计时计数
  final count = 5.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  void reduce() => count.value--;
}
