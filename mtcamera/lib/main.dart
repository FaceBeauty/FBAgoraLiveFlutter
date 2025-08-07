import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:mt_plugin/generated/l10n.dart' as S2;
import 'package:mtcamera/generated/l10n.dart';

import 'app/routes/app_pages.dart';

///页面入口
void main() {
  //是否显示布局边界
  // debugPaintSizeEnabled = true;
  runApp(
    GetMaterialApp(
      title: "FaceBeauty",
      theme: ThemeData.light(),
      localizationsDelegates: const [
        S2.S.delegate,
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      //系统无语言环境时候，为英文
      supportedLocales: [
        const Locale('en', ''),
        ...S.delegate.supportedLocales,
        ...S2.S.delegate.supportedLocales
      ],
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
