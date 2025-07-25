import 'package:get/get.dart';
import 'package:mtcamera/app/modules/camera/bindings/camera_binding.dart';
import 'package:mtcamera/app/modules/camera/views/camera_view.dart';
import 'package:mtcamera/app/modules/home/bindings/home_binding.dart';
import 'package:mtcamera/app/modules/home/views/home_view.dart';
import 'package:mtcamera/app/modules/splash/bindings/splash_binding.dart';
import 'package:mtcamera/app/modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  //启动页
  static const INITIAL = Routes.HOME;

  //路由名称集合
  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.CAMERA,
      page: () => CameraView(),
      binding: CameraBinding(),
    ),
  ];
}
