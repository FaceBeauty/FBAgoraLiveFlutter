
import 'package:get/get.dart';

class MTController extends GetxController {

  // //当前底部窗口的显示状态
  // BottomSheetMode currentBottomSheetMode = BottomSheetMode.MODE_SELECT;
  //
  // final mtParameter = MTParameter();
  //
  // void backPop() {
  //   switch (currentBottomSheetMode) {
  //
  //     ///********级页面 ***************
  //     case BottomSheetMode.MODE_SELECT:
  //       Get.back(); //一级页面则关闭
  //       break;
  //
  //     ///*******一级页面 END**********
  //
  //     ///----二级页面则返回一级页面-------
  //     case BottomSheetMode.MODE_MEIYAN:
  //       break;
  //
  //     case BottomSheetMode.MODE_MEIXIN:
  //       break;
  //
  //     case BottomSheetMode.MODE_MENGTU:
  //       break;
  //
  //     case BottomSheetMode.MODE_LVJING:
  //       break;
  //
  //     case BottomSheetMode.MODE_AUTO:
  //       break;
  //
  //     ///---二级页面 end-------------
  //
  //     ///---- 三级页面则返回二级页面 -----
  //     case BottomSheetMode.MODE_MENGTU_DETAIL:
  //       break;
  //
  //     /// --- 三级页面 END---------
  //   }
  // }
  //
  // void showDialog({BottomSheetMode mode = BottomSheetMode.MODE_SELECT}) {
  //   printInfo(info: "bottomSheet:${mode}");
  //
  //   // 非一级界面 关闭之前的
  //   if (Get.isBottomSheetOpen == true && mode.level != 1) {
  //     Get.back();
  //   }
  //
  //   //同步
  //   currentBottomSheetMode = mode;
  //   switch (mode) {
  //     case BottomSheetMode.MODE_SELECT:
  //       Get.bottomSheet(ModeSelectView(MtBeautyPanelState()),
  //           barrierColor: Colors.transparent);
  //       break;
  //
  //     ///*******一级页面 END**********
  //
  //     ///----二级页面则返回一级页面-------
  //     case BottomSheetMode.MODE_MEIYAN:
  //       Get.bottomSheet(MeiYanView(), barrierColor: Colors.transparent);
  //       break;
  //     case BottomSheetMode.MODE_MEIXIN:
  //       Get.bottomSheet(MeiXingView(), barrierColor: Colors.transparent);
  //       break;
  //     case BottomSheetMode.MODE_MENGTU:
  //       Get.bottomSheet(CuteModeView(), barrierColor: Colors.transparent);
  //       break;
  //
  //     case BottomSheetMode.MODE_LVJING:
  //       Get.bottomSheet(FilterView(), barrierColor: Colors.transparent);
  //       break;
  //
  //     case BottomSheetMode.MODE_AUTO:
  //       Get.bottomSheet(QuickMakeUpView(), barrierColor: Colors.transparent);
  //       break;
  //
  //     ///---二级页面 end-------------
  //
  //     ///---- 三级页面则返回二级页面 -----
  //     case BottomSheetMode.MODE_MENGTU_DETAIL:
  //       Get.bottomSheet(StickersView(), barrierColor: Colors.transparent);
  //       break;
  //
  //     /// --- 三级页面 END---------
  //   }
  // }
}
