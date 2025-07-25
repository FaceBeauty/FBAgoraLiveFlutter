import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mt_plugin/components/banner_view/banner_view.dart';
import 'package:mt_plugin/data/mt_cache_utils.dart';
import 'package:mt_plugin/file_tools.dart';
import 'package:mt_plugin/mt_plugin.dart';
import 'package:mtcamera/app/routes/app_pages.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app_config.dart';

///主页
class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<HomeView> {
  var hasLoad = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            //设置底部区域背景
            image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("mt_icon/bg_main_home.png"))),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  flex: 4,
                  child: Container(
                    //轮播图
                    child: BannerView([
                      Container(
                        child: Image.asset("mt_icon/banner1.png",
                            fit: BoxFit.cover),
                      ),
                      Container(
                        child: Image.asset("mt_icon/banner2.png",
                            fit: BoxFit.cover),
                      ),
                      Container(
                        child: Image.asset("mt_icon/banner3.png",
                            fit: BoxFit.cover),
                      ),
                      // Container(
                      //   child: Image.asset("mt_icon/banner4.png",
                      //       fit: BoxFit.cover),
                      // ),
                    ]),
                  )),
              Expanded(
                  flex: 5,
                  child: Container(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          // GridView.builder(
                          //   shrinkWrap: true,
                          //   itemCount: 4,
                          //   //去除越界滑动效果
                          //   physics: NeverScrollableScrollPhysics(),
                          //   gridDelegate:
                          //   SliverGridDelegateWithFixedCrossAxisCount(
                          //     crossAxisCount: 2,
                          //     mainAxisSpacing: 10,
                          //     crossAxisSpacing: 10,
                          //     childAspectRatio: 2,
                          //   ),
                          //   //四个功能按钮
                          //   itemBuilder: (context, index) {
                          //     List<_FunctionItem> items = [
                          //       _FunctionItem(
                          //           "mt_icon/icon_home_quick_beauty.png"),
                          //       _FunctionItem(
                          //           "mt_icon/icon_home_face_trim.png"),
                          //       _FunctionItem("mt_icon/icon_home_cute.png"),
                          //       _FunctionItem("mt_icon/icon_home_filter.png")
                          //     ];
                          //     return Container(
                          //       decoration: ShapeDecoration(
                          //           image: DecorationImage(
                          //               image:
                          //               AssetImage(items[index].imageRes),
                          //               fit: BoxFit.cover),
                          //           shape: RoundedRectangleBorder(
                          //               borderRadius:
                          //               BorderRadiusDirectional.circular(
                          //                   4))),
                          //     );
                          //   },
                          // ),
                          SizedBox(height: 58),
                          //拍照按钮
                          GestureDetector(
                            onTap: () {
                              if (hasLoad) {
                                Get.toNamed(Routes.CAMERA);
                              } else {
                                Fluttertoast.showToast(
                                    msg: "未就绪",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              }
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              child: Image.asset(
                                "mt_icon/icon_btn_take_photo.png",
                              ),
                            ),
                          )
                        ],
                      ))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Permission.camera.request();
    Permission.manageExternalStorage.request();
    Permission.storage.request();
    // 初始化SDK
    MtPlugin.initSDK(AppConfig.HT_KEY);
    // 加载ui缓存
    MtCacheUtils.instance.initAllCache();
    getTemporaryDirectory().then((de) {
      hasLoad = FileTools.instance.initPath(de.parent.path);
    });
  }
}

