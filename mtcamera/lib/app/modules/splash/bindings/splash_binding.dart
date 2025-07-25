import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

///启动页的依赖自动注入
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      () => SplashController(),
    );
  }
}
