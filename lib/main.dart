import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Store/Bindings/initialbinding.dart';
import 'Store/Extras/approutes/route_name.dart';
import 'Store/Extras/approutes/routes.dart';
import 'Store/services/shared_pref.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => SharedPreferencesService().init());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Family Mart',
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialBinding: InitialBinding(),
      initialRoute: RouteName.splash,
      getPages: AppRoutes.routes,
    );
  }
}
