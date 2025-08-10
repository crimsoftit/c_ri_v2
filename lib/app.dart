import 'package:c_ri/bindings/general_bindings.dart';
import 'package:c_ri/common/widgets/loaders/default_loader.dart';
import 'package:c_ri/main.dart';
import 'package:c_ri/utils/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:c_ri/routes/app_routes.dart';

class App extends StatelessWidget {
  const App({super.key});

  // --- This widget is the root of your application.
  // --- use this class to configure themes, initial bindings, animations, etc. ----
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: true,
      themeMode: ThemeMode.system,
      theme: CAppTheme.lightTheme,
      darkTheme: CAppTheme.darkTheme,
      initialBinding: CGeneralBindings(),
      navigatorKey: globalNavigatorKey,
      getPages: CAppRoutes.pages,

      // -- show loader or circular progress indicator as AuthRepo decides on the relevant screen to load --

      home: const DefaultLoaderScreen(),
    );
  }
}
