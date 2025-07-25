import 'package:get/get.dart';

import '../controllers/camera_controller.dart';

class CameraBinding extends Bindings {
  @override
  void dependencies() {
    print("✅ CameraBinding.dependencies 被调用");
    Get.lazyPut<CameraController>(() => CameraController());
  }
}
